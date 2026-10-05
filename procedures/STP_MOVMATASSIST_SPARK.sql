CREATE OR REPLACE PROCEDURE STP_MOVMATASSIST_SPARK (
    P_CODUSU    NUMBER,        -- Código do usuário logado
    P_IDSESSAO  VARCHAR2,      -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,        -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM  OUT VARCHAR2   -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_MOVMATASSIST_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Automatiza a movimentação interna de estoque das O.S. de
                   conserto da assistência externa (AD_SPKCAE). Para cada O.S.
                   selecionada, em duas etapas:
                   1) Transferência: gera nota de transferência (TOP 708)
                      levando os componentes consumidos no conserto
                      (AD_SPKICAE) do local 201 para o local do parceiro
                      (TGFPAR.AD_CODLOCAL);
                   2) Consumo: gera nota de saída (TOP 503) baixando os mesmos
                      itens do local do parceiro.
                   Resultado líquido: o saldo do parceiro volta ao que era e o
                   local 201 fica reduzido pelo consumo.
                   É gerada 1 nota de consumo e 1 de transferência por O.S.
                   (rastreabilidade). Tudo numa única transação: qualquer erro
                   desfaz a execução inteira (nenhuma nota fica pela metade).

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução (usado por ACT_INT_FIELD)
                   P_QTDLINHAS  — quantidade de O.S. selecionadas em AD_SPKCAE
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Tabelas        : AD_SPKCAE    -- leitura (CODPARC, NUNOTADESC, NUNOTATRF) e atualização (NUNOTADESC, NUNOTATRF)
                   AD_SPKICAE   -- leitura dos componentes da O.S. (CODPROD, QTDMOV, CODVOL)
                   TGFPAR       -- leitura do local do parceiro (AD_CODLOCAL)
                   TGFLOC       -- validação da existência do local
                   TGFEST       -- leitura de saldo (validação prévia)
                   TGFPRO       -- unidade padrão do produto
                   TGFTOP       -- leitura de DHALTER das TOPs 503 e 708
                   TGFTPV       -- leitura de DHALTER do tipo de negociação 0
                   TGFCAB       -- inserção das notas
                   TGFITE       -- inserção dos itens
  Tabela de Log  : AD_LOG_ERROS

  Dependencias   : SNK_GET_NUNOTA (function nativa Sankhya)
                   OBTEMCUSTO_SPARK (function)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 30/09/2026
  Última Revisão : 30/09/2026 — Criação
                   05/10/2026 — Inversão da ordem: transferência (TOP 708)
                   passa a ser gerada antes do consumo (TOP 503)
                   05/10/2026 — Correção do log de erro: OPERACAO limitada a
                   10 caracteres (AD_LOG_ERROS.OPERACAO é VARCHAR2(10));
                   mensagem de erro passa a trazer a linha de origem (backtrace)
                   e o motivo, se a gravação do log falhar
                   05/10/2026 — Transferência: espelho -N só é inserido se o
                   banco não o gerou ao inserir a saída (ORA-00001 em TGFITE_I06)

  Observações    : - Movimento interno, não fiscal: NUMNOTA = 0 nas duas notas,
                     sem impostos, sem TGFSER (componentes simples, sem série),
                     sem TGFFIN.
                   - Valores fixos por definição de negócio: CODEMP = 1,
                     CODCENCUS = 30400, local de origem da reposição = 201,
                     TOP de consumo = 503, TOP de transferência = 708.
                     (Empresa 1 porque é a empresa das notas 503/708 reais e do
                     saldo em TGFEST; o 501 é usado apenas no financeiro.)
                   - CODPARC das notas = AD_SPKCAE.CODPARC (parceiro da O.S.).
                   - Idempotência: se qualquer O.S. selecionada já tiver
                     NUNOTADESC ou NUNOTATRF preenchido, a execução inteira é
                     abortada. AD_SPKICAE.NUNOTAMOV pertence a outro fluxo e
                     não é lido nem alterado aqui.
                   - Parceiro sem AD_CODLOCAL (nulo/zero) ou com local
                     inexistente em TGFLOC: aborta com mensagem.
                   - Validação de saldo antes de cada nota (saldo disponível =
                     ESTOQUE - RESERVADO em TGFEST, por produto, somando
                     itens repetidos). Sem saldo: aborta informando produto,
                     local, saldo e quantidade necessária. O saldo é lido
                     O.S. a O.S., então considera o que as O.S. anteriores da
                     mesma execução já movimentaram. Como a transferência
                     é gerada antes do consumo, a validação do consumo já
                     enxerga o saldo reposto no local do parceiro.
                   - Custo unitário: OBTEMCUSTO_SPARK (custo médio, por
                     empresa e local); nulo ou zero vira 0,01. Na transferência
                     o custo é sempre o do local 201, nas duas pontas.
                   - Transferência segue a estrutura real da TOP 708: item de
                     sequência N no local 201 (ATUALESTOQUE = -1) e item
                     espelho de sequência -N no local do parceiro
                     (ATUALESTOQUE = +1), mesmo produto e quantidade.
                     AD_CODLOCALDEST do cabeçalho = local do parceiro.
                   - Sequência dos itens = posição por IDCOMP (1..N), não o
                     próprio IDCOMP, para que o espelho -N sempre exista.
==============================================================================*/

    V_CODEMP        CONSTANT NUMBER := 1;
    V_CODCENCUS     CONSTANT NUMBER := 30400;
    V_CODLOCALORIG  CONSTANT NUMBER := 201;
    V_TOP_CONSUMO   CONSTANT NUMBER := 503;
    V_TOP_TRANSF    CONSTANT NUMBER := 708;

    E_REGRA         EXCEPTION;
    V_MSG_REGRA     VARCHAR2(4000);

    TYPE T_NUMOS_TAB   IS TABLE OF AD_SPKCAE.NUMOS%TYPE   INDEX BY PLS_INTEGER;
    TYPE T_CODPARC_TAB IS TABLE OF AD_SPKCAE.CODPARC%TYPE INDEX BY PLS_INTEGER;
    TYPE T_LOCAL_TAB   IS TABLE OF TGFPAR.AD_CODLOCAL%TYPE INDEX BY PLS_INTEGER;

    V_NUMOS_SEL     T_NUMOS_TAB;
    V_CODPARC_SEL   T_CODPARC_TAB;
    V_LOCAL_SEL     T_LOCAL_TAB;

    V_NUMOS_ATUAL   AD_SPKCAE.NUMOS%TYPE;
    V_CODPARC       AD_SPKCAE.CODPARC%TYPE;
    V_NUNOTADESC    AD_SPKCAE.NUNOTADESC%TYPE;
    V_NUNOTATRF     AD_SPKCAE.NUNOTATRF%TYPE;
    V_CODLOCAL      TGFPAR.AD_CODLOCAL%TYPE;

    V_QTD_LOCAL     PLS_INTEGER;
    V_QTD_ITENS     PLS_INTEGER;
    V_QTD_INVALIDOS PLS_INTEGER;
    V_QTD_ESPELHO   PLS_INTEGER;

    V_NUNOTA_DESC   TGFCAB.NUNOTA%TYPE;
    V_NUNOTA_TRF    TGFCAB.NUNOTA%TYPE;
    V_QTD_OS        PLS_INTEGER := 0;
    V_DETALHE       VARCHAR2(4000);
    V_SQLERRM       VARCHAR2(4000);
    V_BACKTRACE     VARCHAR2(4000);
    V_ERRO_LOG      VARCHAR2(4000);

    -- Interrompe a execução por regra de negócio (mensagem ao usuário, sem log de erro)
    PROCEDURE LEVANTA_REGRA(P_TEXTO VARCHAR2) IS
    BEGIN
        V_MSG_REGRA := P_TEXTO;
        RAISE E_REGRA;
    END LEVANTA_REGRA;

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_NUNOTA        NUMBER,
        P_ERR_CODE      NUMBER,
        P_ERR_MSG       VARCHAR2,
        P_ERR_BACKTRACE VARCHAR2,
        P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'STP_MOVMATASSIST_SPARK', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Falha ao gravar o log não pode mascarar o erro original; é anexada à mensagem final
            V_ERRO_LOG := SQLERRM;
    END LOG_ERRO;

    -- Confere o saldo disponível de cada produto da O.S. no local informado
    PROCEDURE VALIDA_SALDO(
        P_NUMOS     NUMBER,
        P_CODLOCAL  NUMBER,
        P_ETAPA     VARCHAR2
    ) IS
        V_SALDO NUMBER;
    BEGIN
        FOR R_ITEM IN (
            SELECT  ITE.CODPROD
                   ,PRO.DESCRPROD
                   ,SUM(ITE.QTDMOV) AS QTD
              FROM  AD_SPKICAE ITE
                    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
             WHERE  ITE.NUMOS = P_NUMOS
             GROUP BY ITE.CODPROD, PRO.DESCRPROD
             ORDER BY ITE.CODPROD
        ) LOOP
            -- SUM sempre devolve 1 linha: sem registro em TGFEST o saldo é 0
            SELECT  NVL(SUM(EST.ESTOQUE - NVL(EST.RESERVADO, 0)), 0)
              INTO  V_SALDO
              FROM  TGFEST EST
             WHERE  EST.CODEMP   = V_CODEMP
               AND  EST.CODLOCAL = P_CODLOCAL
               AND  EST.CODPROD  = R_ITEM.CODPROD
               AND  EST.CONTROLE = ' '
               AND  EST.TIPO     = 'P'
               AND  EST.CODPARC  = 0;

            IF V_SALDO < R_ITEM.QTD THEN
                LEVANTA_REGRA('Saldo insuficiente para ' || P_ETAPA || ' da O.S. ' || P_NUMOS ||
                    ': produto ' || R_ITEM.CODPROD || ' - ' || R_ITEM.DESCRPROD ||
                    ' no local ' || P_CODLOCAL || ' (saldo disponível ' || V_SALDO ||
                    ', necessário ' || R_ITEM.QTD || '). Nenhuma nota foi gerada nesta execução.');
            END IF;
        END LOOP;
    END VALIDA_SALDO;

    -- Insere o cabeçalho (TGFCAB) de uma nota interna de estoque
    PROCEDURE INSERE_CABECALHO(
        P_NUNOTA        NUMBER,
        P_CODTIPOPER    NUMBER,
        P_TIPMOV        VARCHAR2,
        P_CODPARC       NUMBER,
        P_OBSERVACAO    VARCHAR2,
        P_CODLOCALDEST  NUMBER
    ) IS
        V_DHTIPOPER TGFTOP.DHALTER%TYPE;
    BEGIN
        SELECT MAX(DHALTER) INTO V_DHTIPOPER FROM TGFTOP WHERE CODTIPOPER = P_CODTIPOPER;

        IF V_DHTIPOPER IS NULL THEN
            LEVANTA_REGRA('Tipo de operação ' || P_CODTIPOPER || ' não encontrado em TGFTOP.');
        END IF;

        INSERT INTO TGFCAB (
            NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, CODEMPNEGOC, CODPARC, RATEADO, CODVEICULO,
            CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA, DHTIPVENDA, CODVEND, COMISSAO, CODMOEDA,
            CODOBSPADRAO, VLRSEG, VLRICMSSEG, VLRDESTAQUE, VLRJURO, VLRVENDOR, VLROUTROS, VLREMB,
            VLRICMSEMB, VLRDESCSERV, IPIEMB, TIPIPIEMB, VLRDESCTOT, VLRDESCTOTITEM, VLRFRETE,
            ICMSFRETE, BASEICMSFRETE, TIPFRETE, VLRNOTA, CODPARCTRANSP, QTDVOL, PENDENTE, BASEICMS,
            VLRICMS, BASEIPI, VLRIPI, ISSRETIDO, BASEISS, VLRISS, APROVADO, STATUSNOTA, IRFRETIDO,
            VLRIRF, DTALTER, CODPARCDEST, VLRSUBST, BASESUBSTIT, CODPROJ, NUMCONTRATO, BASEINSS,
            VLRINSS, VLRREPREDTOT, PERCDESC, CODPARCREMETENTE, CODPARCCONSIGNATARIO, CODPARCREDESPACHO,
            CODNAT, TROCO, CODUSUCOMPRADOR, CIF_FOB, OBSERVACAO, CODUSU, CODUSUINC, AD_CODLOCALDEST
        ) VALUES (
            P_NUNOTA, V_CODEMP, V_CODCENCUS, 0, TRUNC(SYSDATE), V_CODEMP, P_CODPARC, 'N', 0,
            P_CODTIPOPER, V_DHTIPOPER, P_TIPMOV, 0, (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0), 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 'N', 0, 0, 0,
            0, 0, 'S', 0, 0, 0, 'N', 0,
            0, 0, 0, 'N', 0, 0, 'S', 'L', 'N',
            0, SYSDATE, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 'S', P_OBSERVACAO, P_CODUSU, P_CODUSU, P_CODLOCALDEST
        );
    END INSERE_CABECALHO;

    -- Insere os itens (TGFITE) da O.S. numa nota, no local e sentido informados.
    -- P_SINALSEQ = 1 gera sequências 1..N; -1 gera o espelho -1..-N.
    PROCEDURE INSERE_ITENS(
        P_NUNOTA        NUMBER,
        P_NUMOS         NUMBER,
        P_CODLOCAL      NUMBER,
        P_CODLOCALCUSTO NUMBER,
        P_SINALSEQ      NUMBER,
        P_ATUALESTOQUE  NUMBER
    ) IS
    BEGIN
        INSERT INTO TGFITE (
            NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CODCFO, QTDNEG, QTDENTREGUE, QTDCONFERIDA,
            VLRUNIT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST, PENDENTE,
            CODVOL, ATUALESTOQUE, RESERVA, STATUSNOTA, CODVEND, CODEXEC, FATURAR, VLRREPRED, VLRDESCBONIF, PERCDESC
        )
        SELECT  P_NUNOTA
               ,P_SINALSEQ * ROW_NUMBER() OVER (ORDER BY ITE.IDCOMP)
               ,V_CODEMP
               ,ITE.CODPROD
               ,P_CODLOCAL
               ,0
               ,ITE.QTDMOV
               ,0
               ,0
               ,NVL(NULLIF(OBTEMCUSTO_SPARK(ITE.CODPROD, 'S', V_CODEMP, 'S', P_CODLOCALCUSTO, 'N', NULL, SYSDATE, 1), 0), 0.01)
               ,0, 0, 0, 0, 0, 0, 0, 0
               ,'N'
               ,NVL(ITE.CODVOL, PRO.CODVOL)
               ,P_ATUALESTOQUE
               ,'N'
               ,'L'
               ,0
               ,0
               ,'S'
               ,0
               ,0
               ,0
          FROM  AD_SPKICAE ITE
                INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
         WHERE  ITE.NUMOS = P_NUMOS;
    END INSERE_ITENS;

BEGIN
    IF NVL(P_QTDLINHAS, 0) = 0 THEN
        LEVANTA_REGRA('Selecione ao menos uma O.S. para movimentar o estoque.');
    END IF;

    ---------------------------------------------------------------------------
    -- 1. Valida todas as O.S. selecionadas antes de gerar qualquer nota
    ---------------------------------------------------------------------------
    FOR I IN 1..P_QTDLINHAS LOOP
        V_NUMOS_ATUAL := ACT_INT_FIELD(P_IDSESSAO, I, 'NUMOS');

        BEGIN
            SELECT  CODPARC, NUNOTADESC, NUNOTATRF
              INTO  V_CODPARC, V_NUNOTADESC, V_NUNOTATRF
              FROM  AD_SPKCAE
             WHERE  NUMOS = V_NUMOS_ATUAL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                LEVANTA_REGRA('O.S. ' || V_NUMOS_ATUAL || ' não encontrada em AD_SPKCAE.');
        END;

        IF V_NUNOTADESC IS NOT NULL OR V_NUNOTATRF IS NOT NULL THEN
            LEVANTA_REGRA('A O.S. ' || V_NUMOS_ATUAL || ' já teve a movimentação de estoque gerada (consumo: ' ||
                NVL(TO_CHAR(V_NUNOTADESC), '-') || ', transferência: ' || NVL(TO_CHAR(V_NUNOTATRF), '-') ||
                '). Nenhuma nota foi gerada nesta execução.');
        END IF;

        IF V_CODPARC IS NULL THEN
            LEVANTA_REGRA('A O.S. ' || V_NUMOS_ATUAL || ' não possui parceiro (CODPARC) informado.');
        END IF;

        BEGIN
            SELECT  AD_CODLOCAL
              INTO  V_CODLOCAL
              FROM  TGFPAR
             WHERE  CODPARC = V_CODPARC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                LEVANTA_REGRA('Parceiro ' || V_CODPARC || ' da O.S. ' || V_NUMOS_ATUAL || ' não encontrado em TGFPAR.');
        END;

        IF NVL(V_CODLOCAL, 0) = 0 THEN
            LEVANTA_REGRA('O parceiro ' || V_CODPARC || ' da O.S. ' || V_NUMOS_ATUAL ||
                ' não possui local de estoque no cadastro (TGFPAR.AD_CODLOCAL). Cadastre o local e tente novamente.');
        END IF;

        -- COUNT sempre devolve 1 linha
        SELECT COUNT(*) INTO V_QTD_LOCAL FROM TGFLOC WHERE CODLOCAL = V_CODLOCAL;

        IF V_QTD_LOCAL = 0 THEN
            LEVANTA_REGRA('O local ' || V_CODLOCAL || ' cadastrado no parceiro ' || V_CODPARC ||
                ' (O.S. ' || V_NUMOS_ATUAL || ') não existe em TGFLOC.');
        END IF;

        SELECT COUNT(*) INTO V_QTD_ITENS FROM AD_SPKICAE WHERE NUMOS = V_NUMOS_ATUAL;

        IF V_QTD_ITENS = 0 THEN
            LEVANTA_REGRA('A O.S. ' || V_NUMOS_ATUAL || ' não possui componentes (AD_SPKICAE) para movimentar.');
        END IF;

        SELECT  COUNT(*)
          INTO  V_QTD_INVALIDOS
          FROM  AD_SPKICAE
         WHERE  NUMOS = V_NUMOS_ATUAL
           AND  (CODPROD IS NULL OR NVL(QTDMOV, 0) <= 0);

        IF V_QTD_INVALIDOS > 0 THEN
            LEVANTA_REGRA('A O.S. ' || V_NUMOS_ATUAL || ' possui ' || V_QTD_INVALIDOS ||
                ' componente(s) sem produto ou com quantidade zerada/negativa (AD_SPKICAE.QTDMOV).');
        END IF;

        V_NUMOS_SEL(I)   := V_NUMOS_ATUAL;
        V_CODPARC_SEL(I) := V_CODPARC;
        V_LOCAL_SEL(I)   := V_CODLOCAL;
    END LOOP;

    ---------------------------------------------------------------------------
    -- 2. Gera, por O.S.: transferência (TOP 708) e nota de consumo (TOP 503)
    ---------------------------------------------------------------------------
    FOR I IN 1..P_QTDLINHAS LOOP
        V_NUMOS_ATUAL := V_NUMOS_SEL(I);
        V_CODPARC     := V_CODPARC_SEL(I);
        V_CODLOCAL    := V_LOCAL_SEL(I);

        -- 2.1 Reposição: transferência do local 201 para o local do parceiro
        VALIDA_SALDO(V_NUMOS_ATUAL, V_CODLOCALORIG, 'a reposição');

        V_NUNOTA_TRF := SNK_GET_NUNOTA;

        INSERE_CABECALHO(
            P_NUNOTA       => V_NUNOTA_TRF,
            P_CODTIPOPER   => V_TOP_TRANSF,
            P_TIPMOV       => 'T',
            P_CODPARC      => V_CODPARC,
            P_OBSERVACAO   => 'REPOSIÇÃO DO LOCAL ' || V_CODLOCAL || ' (ASSISTÊNCIA EXTERNA) REFERENTE À O.S. ' || V_NUMOS_ATUAL,
            P_CODLOCALDEST => V_CODLOCAL
        );

        -- Saída do 201 (sequências 1..N)
        INSERE_ITENS(
            P_NUNOTA        => V_NUNOTA_TRF,
            P_NUMOS         => V_NUMOS_ATUAL,
            P_CODLOCAL      => V_CODLOCALORIG,
            P_CODLOCALCUSTO => V_CODLOCALORIG,
            P_SINALSEQ      => 1,
            P_ATUALESTOQUE  => -1
        );

        -- Entrada no local do parceiro (espelho -1..-N). O banco pode gerar o
        -- espelho sozinho ao inserir a saída (ORA-00001 em TGFITE_I06 quando
        -- o espelho era inserido por aqui): só insere se ele não existir.
        SELECT COUNT(*) INTO V_QTD_ESPELHO
          FROM TGFITE
         WHERE NUNOTA = V_NUNOTA_TRF AND SEQUENCIA < 0;

        IF V_QTD_ESPELHO = 0 THEN
            INSERE_ITENS(
                P_NUNOTA        => V_NUNOTA_TRF,
                P_NUMOS         => V_NUMOS_ATUAL,
                P_CODLOCAL      => V_CODLOCAL,
                P_CODLOCALCUSTO => V_CODLOCALORIG,
                P_SINALSEQ      => -1,
                P_ATUALESTOQUE  => 1
            );
        ELSE
            SELECT COUNT(*) INTO V_QTD_ITENS FROM AD_SPKICAE WHERE NUMOS = V_NUMOS_ATUAL;

            IF V_QTD_ESPELHO <> V_QTD_ITENS THEN
                LEVANTA_REGRA('Transferência da O.S. ' || V_NUMOS_ATUAL || ': o banco gerou ' || V_QTD_ESPELHO ||
                    ' item(ns) de entrada, mas a O.S. possui ' || V_QTD_ITENS ||
                    ' componente(s). Nenhuma nota foi gerada nesta execução.');
            END IF;

            -- Garante que a entrada fique no local do parceiro
            UPDATE TGFITE
               SET CODLOCALORIG = V_CODLOCAL
             WHERE NUNOTA       = V_NUNOTA_TRF
               AND SEQUENCIA    < 0
               AND CODLOCALORIG <> V_CODLOCAL;
        END IF;

        -- 2.2 Consumo: baixa do local do parceiro
        VALIDA_SALDO(V_NUMOS_ATUAL, V_CODLOCAL, 'o consumo');

        V_NUNOTA_DESC := SNK_GET_NUNOTA;

        INSERE_CABECALHO(
            P_NUNOTA       => V_NUNOTA_DESC,
            P_CODTIPOPER   => V_TOP_CONSUMO,
            P_TIPMOV       => 'Q',
            P_CODPARC      => V_CODPARC,
            P_OBSERVACAO   => 'MOVIMENTAÇÃO DE CONSUMO DA ASSISTÊNCIA EXTERNA REFERENTE À O.S. ' || V_NUMOS_ATUAL,
            P_CODLOCALDEST => NULL
        );

        INSERE_ITENS(
            P_NUNOTA        => V_NUNOTA_DESC,
            P_NUMOS         => V_NUMOS_ATUAL,
            P_CODLOCAL      => V_CODLOCAL,
            P_CODLOCALCUSTO => V_CODLOCAL,
            P_SINALSEQ      => 1,
            P_ATUALESTOQUE  => -1
        );

        -- 2.3 Marca a O.S. (idempotência)
        UPDATE AD_SPKCAE
           SET NUNOTADESC = V_NUNOTA_DESC
              ,NUNOTATRF  = V_NUNOTA_TRF
         WHERE NUMOS = V_NUMOS_ATUAL;

        V_QTD_OS := V_QTD_OS + 1;

        IF NVL(LENGTH(V_DETALHE), 0) < 3000 THEN
            V_DETALHE := V_DETALHE || CHR(10) || 'O.S. ' || V_NUMOS_ATUAL ||
                ': transferência ' || V_NUNOTA_TRF || ' / consumo ' || V_NUNOTA_DESC;
        END IF;
    END LOOP;

    COMMIT;

    P_MENSAGEM := 'Movimentação realizada com sucesso para ' || V_QTD_OS || ' O.S.' || V_DETALHE;

EXCEPTION
    WHEN E_REGRA THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, V_MSG_REGRA);
    WHEN OTHERS THEN
        V_SQLERRM   := SQLERRM;
        V_BACKTRACE := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        ROLLBACK;
        LOG_ERRO(
            P_OPERACAO      => SUBSTR('OS ' || V_NUMOS_ATUAL, 1, 10),
            P_NUNOTA        => NVL(V_NUNOTA_TRF, V_NUNOTA_DESC),
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => V_SQLERRM,
            P_ERR_BACKTRACE => V_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20002, SUBSTR(
            'Erro em STP_MOVMATASSIST_SPARK (O.S. ' || V_NUMOS_ATUAL || '): ' || V_SQLERRM ||
            ' | Origem: ' || REPLACE(V_BACKTRACE, CHR(10), ' ') ||
            CASE WHEN V_ERRO_LOG IS NOT NULL THEN ' | Falha ao gravar AD_LOG_ERROS: ' || V_ERRO_LOG END,
            1, 2000));
END STP_MOVMATASSIST_SPARK;
