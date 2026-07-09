CREATE OR REPLACE PROCEDURE STP_CORRIGENOTAPROD_SPARK (
    P_DIAS        NUMBER   DEFAULT 7,    -- Janela de varredura (dias) das conferências finalizadas
    P_IDIPROC     NUMBER   DEFAULT NULL, -- Restringe a verificação a uma OP específica (opcional)
    P_ATUALIZAEST VARCHAR2 DEFAULT 'S'   -- S = ajusta TGFEST no mesmo delta corrigido no item PA
) AS
/*==============================================================================
  Nome do Script : STP_CORRIGENOTAPROD_SPARK
  Tipo           : Procedure
  Descrição      : Verifica se cada conferência de produção finalizada
                   (TPRCONF.STATUS = 'F', séries consolidadas em AD_TPRCOI)
                   gerou corretamente a SUA nota de produção (TGFCAB/TGFITE/
                   TGFSER, TOP 800) e corrige as divergências. O serviço nativo
                   do Sankhya que lança a nota após o apontamento está instável;
                   esta rotina atua como rede de segurança, executada de forma
                   recorrente por agendador externo.

                   A conciliação é POR CONFERÊNCIA (NUCONF): cada conferência
                   deve ter seu próprio lançamento em TGFCAB — conferências de
                   dia/hora diferentes não podem compartilhar a mesma nota. A
                   nota de uma conferência é localizada pelas séries que ela
                   conferiu (TGFSER.SERIE = AD_TPRCOI.CODBARRA) dentro das
                   notas TOP 800 não canceladas da mesma OP.

                   Conferido : nº de séries (códigos de barras) do produto
                               acabado (PA) em AD_TPRCOI da conferência
                               (TPRCONF -> TPRIATV -> IDIPROC; PA = TPRIPA).
                   Lançado   : TGFITE.QTDNEG do PA na nota da conferência.

                   Correções aplicadas (idempotentes, por conferência):
                   1. Nota ausente (nenhuma série da conferência lançada) ->
                      cria nota exclusiva da conferência com DTNEG/HRMOV da
                      finalização (campos de configuração copiados da última
                      nota de produção válida, usada como modelo), item PA em
                      TGFITE e séries em TGFSER.
                   2. Séries faltantes -> insere em TGFSER, na nota da
                      conferência, as séries de AD_TPRCOI ainda ausentes nas
                      notas da OP.
                   3. Quantidade divergente (a menor OU a maior) -> corrige
                      TGFITE.QTDNEG do item PA para coincidir com o total de
                      séries lançadas na nota (cria o item se não existir);
                      o estoque é ajustado pelo mesmo delta, positivo ou
                      negativo. Séries em excesso em TGFSER não são excluídas.

                   Como o item PA tem ATUALESTOQUE = 1 e a nota é gravada já
                   confirmada (PENDENTE = 'N'), o estoque do PA (TGFEST) é
                   ajustado pelo mesmo delta corrigido — comportamento
                   controlado pelo parâmetro P_ATUALIZAEST.

  Parâmetros     : P_DIAS        — janela de varredura em dias (default 7);
                                   conferências com séries consolidadas dentro
                                   da janela são verificadas
                   P_IDIPROC     — verifica somente a OP informada (opcional)
                   P_ATUALIZAEST — S/N: ajusta TGFEST no delta corrigido (default S)
  Tabelas        : TPRCONF, TPRIATV, TPRIPROC, TPRIPA, AD_TPRCOI, TPRCOI (leitura)
                   TGFCAB, TGFITE, TGFSER, TGFEST (leitura/escrita)
                   TGFTOP, TGFPRO (leitura)
                   AD_CORRNOTAPROD (auditoria das correções)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : AD_CORRNOTAPROD (tables/AD_CORRNOTAPROD.SQL);
                   AD_TPRCOI alimentada pela TRG_INC_UPD_TPRCONF_SPARK
  Uso            : Execução recorrente por agendador externo:
                     BEGIN STP_CORRIGENOTAPROD_SPARK(); END;
                   ou manual, para uma OP específica:
                     BEGIN STP_CORRIGENOTAPROD_SPARK(P_IDIPROC => 1234); END;

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 09/07/2026
  Última Revisão : Julho/2026 — Removido o parâmetro de carência (P_CARENCIAMIN);
                   o controle de cadência passa a ser do agendador externo.
                   Julho/2026 — Conciliação por conferência (NUCONF): cada
                   conferência passa a ter sua própria nota em TGFCAB (nota
                   localizada pelas séries conferidas); quantidade a menor em
                   TGFITE é corrigida para coincidir com o conferido; coluna
                   NUCONF adicionada à auditoria AD_CORRNOTAPROD.
                   Julho/2026 — Quantidade a maior também passa a ser corrigida:
                   QTDNEG é reduzida para coincidir com as séries conferidas
                   (tipo DIVERG_NEGATIVA descontinuado; ajuste registrado como
                   QTD_AJUSTADA com delta negativo).
                   Julho/2026 — LOG_ERRO blindado: valores truncados nos
                   tamanhos das colunas de AD_LOG_ERROS (OPERACAO é
                   VARCHAR2(10) e estourava com ORA-12899, fazendo o log
                   falhar em silêncio e ocultar o erro real).
                   Julho/2026 — Segunda guarda no INSERT de TGFSER: série já
                   existente na nota de destino sob qualquer CODPROD/SEQUENCIA
                   não é reinserida (evita ORA-00001 em PK_TGFSER); auditoria
                   SERIE_INCLUIDA passa a gravar o QTDLANC real (antes NULL,
                   violando NOT NULL em AD_CORRNOTAPROD).

  Observações    : Premissas assumidas (validar antes de implantar):
                   - O serviço nativo grava TGFCAB.IDIPROC na nota de produção
                     (elo OP -> nota). Conferir com:
                       SELECT NUNOTA, IDIPROC FROM TGFCAB
                        WHERE CODTIPOPER = 800 AND ROWNUM <= 10
                        ORDER BY NUNOTA DESC;
                   - PA serializado: 1 código de barras em AD_TPRCOI = 1 unidade.
                   - Constantes fixas do fluxo atual: TOP 800, TIPMOV 'F',
                     local de estoque do PA 109 (mesmos valores da nota gerada
                     pelo serviço — ver exemplos/TGFCAB.sql e TGFITE.sql).
                   - A nota criada contém apenas o item do PA + séries. Os itens
                     de matéria-prima da nota original têm ATUALESTOQUE = 0 e
                     valores zerados (sem efeito de estoque); não são recriados.
                   - Correções são feitas por DML direto (sem passar pela camada
                     de negócio do Sankhya), portanto validações de TOP/impostos
                     não são reexecutadas — adequado apenas a esta TOP interna.
                   - Cada conferência é confirmada (COMMIT) individualmente;
                     erro em uma conferência é registrado em AD_LOG_ERROS e não
                     interrompe as demais.
                   - Os INSERTs em TGFSER disparam a TRG_INC_TGFSER_SPARK
                     (cadastro em TGFBAR e limpeza de CODBARRA no local 108
                     para a TOP 800) — mesmo efeito do lançamento pelo serviço.
                   - Notas antigas que agrupem séries de mais de uma conferência
                     (lançamentos anteriores a esta revisão) são reconhecidas
                     como a nota de cada conferência envolvida e apenas
                     completadas; a separação retroativa deve ser manual.
==============================================================================*/

    -- Constantes do fluxo de produção (espelham a nota gerada pelo serviço nativo)
    V_CODTIPOPER  CONSTANT TGFCAB.CODTIPOPER%TYPE   := 800;  -- TOP da nota de produção
    V_CODLOCAL_PA CONSTANT TGFITE.CODLOCALORIG%TYPE := 109;  -- Local de estoque do PA
    V_CODUSU      CONSTANT NUMBER                   := 0;    -- Usuário das correções automáticas

    V_NUNOTA       TGFCAB.NUNOTA%TYPE;
    V_NUNOTAMODELO TGFCAB.NUNOTA%TYPE;
    V_CODEMP       TGFCAB.CODEMP%TYPE;
    V_NUMNOTA      TGFCAB.NUMNOTA%TYPE;
    V_DHTIPOPER    TGFCAB.DHTIPOPER%TYPE;
    V_QTDLANC      NUMBER;
    V_QTDSER       NUMBER;
    V_DELTA        NUMBER;
    V_SERINCL      NUMBER;
    V_SEQPA        TGFITE.SEQUENCIA%TYPE;

    -- Conferências finalizadas com séries consolidadas na janela de varredura;
    -- processadas em ordem cronológica para gerar as notas na sequência correta
    CURSOR C_CONF IS
        SELECT  CNF.NUCONF
               ,ATV.IDIPROC
               ,IPA.CODPRODPA
               ,COUNT(DISTINCT COI.CODBARRA) AS QTDCONF
               ,MAX(COI.DTINCLUSAO)          AS DHCONF
        FROM    AD_TPRCOI COI
                INNER JOIN TPRCONF  CNF  ON CNF.NUCONF    = COI.NUCONF
                INNER JOIN TPRIATV  ATV  ON ATV.IDIATV    = CNF.IDIATV
                INNER JOIN TPRIPROC PROC ON PROC.IDIPROC  = ATV.IDIPROC
                INNER JOIN TPRIPA   IPA  ON IPA.IDIPROC   = ATV.IDIPROC
                                        AND IPA.CODPRODPA = COI.CODPROD
        WHERE   CNF.STATUS       = 'F'
        AND     PROC.STATUSPROC <> 'C'
        AND     (ATV.IDIPROC = P_IDIPROC OR P_IDIPROC IS NULL)
        GROUP BY CNF.NUCONF
                ,ATV.IDIPROC
                ,IPA.CODPRODPA
        HAVING  MAX(COI.DTINCLUSAO) >= TRUNC(SYSDATE) - P_DIAS
        ORDER BY MAX(COI.DTINCLUSAO);

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
        -- Trunca nos tamanhos das colunas de AD_LOG_ERROS (OPERACAO é
        -- VARCHAR2(10)!) para o registro do log nunca falhar por ORA-12899
        INSERT INTO AD_LOG_ERROS (
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'STP_CORRIGENOTAPROD_SPARK', SUBSTR(P_OPERACAO, 1, 10), P_NUNOTA,
            P_ERR_CODE, SUBSTR(P_ERR_MSG, 1, 4000),
            SUBSTR(P_ERR_BACKTRACE, 1, 4000), SUBSTR(P_CALL_STACK, 1, 4000)
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

    -- Grava a auditoria da correção em AD_CORRNOTAPROD (na mesma transação,
    -- para ser desfeita junto com a correção em caso de erro)
    PROCEDURE REGISTRA_CORRECAO(
        P_TIPO       VARCHAR2,
        P_NUCONF     NUMBER,
        P_IDIPROC_OP NUMBER,
        P_NUNOTA     NUMBER,
        P_CODPRODPA  NUMBER,
        P_QTDCONF    NUMBER,
        P_QTDLANC    NUMBER,
        P_QTDCORR    NUMBER,
        P_DESCR      VARCHAR2
    ) IS
        V_NUCORR NUMBER;
    BEGIN
        SELECT NVL(MAX(NUCORR), 0) + 1 INTO V_NUCORR FROM AD_CORRNOTAPROD;
        INSERT INTO AD_CORRNOTAPROD (
            NUCORR, NUCONF, IDIPROC, NUNOTA, CODPRODPA,
            QTDCONF, QTDLANC, QTDCORR, TIPOCORR, DESCRICAO, DHCORR
        ) VALUES (
            V_NUCORR, P_NUCONF, P_IDIPROC_OP, P_NUNOTA, P_CODPRODPA,
            P_QTDCONF, P_QTDLANC, P_QTDCORR, P_TIPO, P_DESCR, SYSDATE
        );
    END REGISTRA_CORRECAO;

    -- Ajusta o estoque do PA (TGFEST) no delta corrigido, espelhando o
    -- ATUALESTOQUE = 1 do item da nota de produção
    PROCEDURE ATUALIZA_ESTOQUE(
        P_CODPROD NUMBER,
        P_CODEMP  NUMBER,
        P_QTD     NUMBER
    ) IS
    BEGIN
        IF NVL(P_ATUALIZAEST, 'N') <> 'S' OR NVL(P_QTD, 0) = 0 THEN
            RETURN;
        END IF;

        UPDATE  TGFEST
        SET     ESTOQUE = NVL(ESTOQUE, 0) + P_QTD
        WHERE   CODEMP   = P_CODEMP
        AND     CODPROD  = P_CODPROD
        AND     CODLOCAL = V_CODLOCAL_PA
        AND     CONTROLE = ' '
        AND     CODPARC  = 0
        AND     TIPO     = 'P';

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO TGFEST (
                CODEMP, CODPROD, CODLOCAL, CONTROLE, CODPARC, TIPO,
                ESTOQUE, RESERVADO
            ) VALUES (
                P_CODEMP, P_CODPROD, V_CODLOCAL_PA, ' ', 0, 'P',
                P_QTD, 0
            );
        END IF;
    END ATUALIZA_ESTOQUE;

    -- Insere o item do PA na nota (mesmos valores do item gerado pelo
    -- serviço nativo — ver exemplos/TGFITE.sql)
    PROCEDURE INSERE_ITEM_PA(
        P_NUNOTA_ITE NUMBER,
        P_SEQ        NUMBER,
        P_CODEMP     NUMBER,
        P_CODPROD    NUMBER,
        P_QTD        NUMBER
    ) IS
        V_CODVOL TGFPRO.CODVOL%TYPE;
    BEGIN
        BEGIN
            SELECT  PRO.CODVOL
            INTO    V_CODVOL
            FROM    TGFPRO PRO
            WHERE   PRO.CODPROD = P_CODPROD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CODVOL := 'UN';
        END;

        INSERT INTO TGFITE (
            NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CONTROLE,
            USOPROD, CODCFO, QTDNEG, QTDENTREGUE, QTDCONFERIDA, VLRUNIT,
            VLRTOT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, VLRICMS, VLRDESC,
            BASESUBSTIT, VLRSUBST, ALIQICMS, PENDENTE, CODVOL, CODTRIB,
            ATUALESTOQUE, RESERVA, STATUSNOTA, CODVEND, CODEXEC, FATURAR,
            VLRREPRED, VLRDESCBONIF, PERCDESC, ALIQICMSRED, CODPARCEXEC,
            CUSTO, BASESUBSTSEMRED, CODUSU, DTALTER, SOLCOMPRA,
            ATUALESTTERC, PRODUTONFE
        ) VALUES (
            P_NUNOTA_ITE, P_SEQ, P_CODEMP, P_CODPROD, V_CODLOCAL_PA, ' ',
            'V', 0, P_QTD, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 'N', V_CODVOL, 0,
            1, 'N', 'L', 0, 0, 'S',
            0, 0, 0, 0, 0,
            0, 0, V_CODUSU, SYSDATE, 'N',
            'N', TO_CHAR(P_CODPROD)
        );
    END INSERE_ITEM_PA;

BEGIN

    FOR R_CONF IN C_CONF LOOP
        BEGIN
            SAVEPOINT SP_CONF;

            ---------------------------------------------------------------------------
            -- 1. Localiza a nota DESTA conferência: a nota TOP 800 não cancelada
            --    da OP que contém as séries conferidas (a que tiver mais séries,
            --    em caso de fragmentação)
            ---------------------------------------------------------------------------
            BEGIN
                SELECT  NUNOTA
                INTO    V_NUNOTA
                FROM    (
                            SELECT  SER.NUNOTA
                            FROM    TGFSER SER
                                    INNER JOIN TGFCAB CAB ON CAB.NUNOTA = SER.NUNOTA
                            WHERE   CAB.IDIPROC    = R_CONF.IDIPROC
                            AND     CAB.CODTIPOPER = V_CODTIPOPER
                            AND     NVL(CAB.STATUSNOTA, 'L') <> 'C'
                            AND     SER.CODPROD    = R_CONF.CODPRODPA
                            AND     SER.SERIE IN (SELECT COI.CODBARRA
                                                    FROM AD_TPRCOI COI
                                                   WHERE COI.NUCONF = R_CONF.NUCONF)
                            GROUP BY SER.NUNOTA
                            ORDER BY COUNT(*) DESC
                                    ,SER.NUNOTA DESC
                        )
                WHERE   ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_NUNOTA := NULL;
            END;

            IF V_NUNOTA IS NULL THEN

                ---------------------------------------------------------------------------
                -- 2. Nenhuma série desta conferência foi lançada: cria a nota
                --    EXCLUSIVA da conferência, com data/hora da finalização
                --    (configuração copiada da última nota de produção válida)
                ---------------------------------------------------------------------------
                SELECT  MAX(CAB.NUNOTA)
                INTO    V_NUNOTAMODELO
                FROM    TGFCAB CAB
                WHERE   CAB.CODTIPOPER = V_CODTIPOPER
                AND     CAB.TIPMOV     = 'F'
                AND     NVL(CAB.STATUSNOTA, 'L') <> 'C';

                IF V_NUNOTAMODELO IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20091,
                        'STP_CORRIGENOTAPROD_SPARK - Nenhuma nota de produção (TOP '
                        || V_CODTIPOPER || ') encontrada para usar como modelo. Conferência: '
                        || R_CONF.NUCONF || ' / OP: ' || R_CONF.IDIPROC);
                END IF;

                SELECT  NVL(MAX(NUNOTA), 0) + 1
                INTO    V_NUNOTA
                FROM    TGFCAB;

                SELECT  NVL(MAX(NUMNOTA), 0) + 1
                INTO    V_NUMNOTA
                FROM    TGFCAB
                WHERE   CODTIPOPER = V_CODTIPOPER;

                SELECT  MAX(DHALTER)
                INTO    V_DHTIPOPER
                FROM    TGFTOP
                WHERE   CODTIPOPER = V_CODTIPOPER;

                INSERT INTO TGFCAB (
                    NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, DTFATUR,
                    DTENTSAI, DTMOV, HRMOV, CODEMPNEGOC, CODPARC, RATEADO,
                    CODVEICULO, CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA,
                    DHTIPVENDA, CODVEND, COMISSAO, CODMOEDA, VLRSEG,
                    VLRICMSSEG, VLRDESTAQUE, VLRJURO, VLRVENDOR, VLROUTROS,
                    VLREMB, VLRICMSEMB, VLRDESCSERV, IPIEMB, TIPIPIEMB,
                    VLRDESCTOT, VLRDESCTOTITEM, VLRFRETE, ICMSFRETE,
                    BASEICMSFRETE, TIPFRETE, CIF_FOB, VLRNOTA, QTDVOL,
                    PENDENTE, BASEICMS, VLRICMS, BASEIPI, VLRIPI, ISSRETIDO,
                    BASEISS, VLRISS, APROVADO, STATUSNOTA, CODUSU,
                    IRFRETIDO, VLRIRF, DTALTER, VLRSUBST, BASESUBSTIT,
                    CODPROJ, NUMCONTRATO, BASEINSS, VLRINSS, VLRREPREDTOT,
                    PERCDESC, CODNAT, TROCO, CODUSUINC, IDIPROC, OBSERVACAO
                )
                SELECT  V_NUNOTA, MDL.CODEMP, MDL.CODCENCUS, V_NUMNOTA
                       ,TRUNC(R_CONF.DHCONF), TRUNC(R_CONF.DHCONF)
                       ,TRUNC(R_CONF.DHCONF), TRUNC(R_CONF.DHCONF)
                       ,TO_CHAR(R_CONF.DHCONF, 'HH24MISS')
                       ,MDL.CODEMPNEGOC, MDL.CODPARC, 'N'
                       ,MDL.CODVEICULO, MDL.CODTIPOPER, V_DHTIPOPER
                       ,MDL.TIPMOV, MDL.CODTIPVENDA
                       ,MDL.DHTIPVENDA, 0, 0, 0, 0
                       ,0, 0, 0, 0, 0
                       ,0, 0, 0, 0, MDL.TIPIPIEMB
                       ,0, 0, 0, 0
                       ,0, MDL.TIPFRETE, MDL.CIF_FOB, 0, R_CONF.QTDCONF
                       ,'N', 0, 0, 0, 0, 'N'
                       ,0, 0, 'S', 'L', V_CODUSU
                       ,'N', 0, SYSDATE, 0, 0
                       ,MDL.CODPROJ, 0, 0, 0, 0
                       ,0, MDL.CODNAT, 0, V_CODUSU, R_CONF.IDIPROC
                       ,'NOTA DE PRODUCAO GERADA AUTOMATICAMENTE PELA STP_CORRIGENOTAPROD_SPARK - OP '
                        || R_CONF.IDIPROC || ' - CONFERENCIA ' || R_CONF.NUCONF
                FROM    TGFCAB MDL
                WHERE   MDL.NUNOTA = V_NUNOTAMODELO;

                SELECT  MAX(CODEMP)
                INTO    V_CODEMP
                FROM    TGFCAB
                WHERE   NUNOTA = V_NUNOTAMODELO;

                V_SEQPA := 1;
                INSERE_ITEM_PA(V_NUNOTA, V_SEQPA, V_CODEMP, R_CONF.CODPRODPA, R_CONF.QTDCONF);
                ATUALIZA_ESTOQUE(R_CONF.CODPRODPA, V_CODEMP, R_CONF.QTDCONF);

                REGISTRA_CORRECAO('NOTA_CRIADA', R_CONF.NUCONF, R_CONF.IDIPROC,
                    V_NUNOTA, R_CONF.CODPRODPA, R_CONF.QTDCONF, 0, R_CONF.QTDCONF,
                    'Lançamento ausente para a conferência ' || R_CONF.NUCONF
                    || '; nota exclusiva criada com ' || R_CONF.QTDCONF
                    || ' unidade(s) do PA a partir da nota modelo ' || V_NUNOTAMODELO);

            ELSE
                SELECT  MAX(CODEMP)
                INTO    V_CODEMP
                FROM    TGFCAB
                WHERE   NUNOTA = V_NUNOTA;

                SELECT  MIN(ITE.SEQUENCIA)
                INTO    V_SEQPA
                FROM    TGFITE ITE
                WHERE   ITE.NUNOTA  = V_NUNOTA
                AND     ITE.CODPROD = R_CONF.CODPRODPA;
            END IF;

            ---------------------------------------------------------------------------
            -- 3. Inclui na nota da conferência as séries dela ainda ausentes em
            --    TGFSER (guarda contra duplicidade em qualquer nota da OP)
            ---------------------------------------------------------------------------
            INSERT INTO TGFSER (
                NUNOTA, CODPROD, SEQUENCIA, SERIE,
                ATUALESTOQUE, TIPCONTEST, CODUSU, DTALTER
            )
            SELECT  V_NUNOTA
                   ,SER_CONF.CODPROD
                   ,NVL(V_SEQPA, 1)
                   ,SER_CONF.CODBARRA
                   ,1, 'N', V_CODUSU, SYSDATE
            FROM    (
                        SELECT  DISTINCT COI.CODPROD
                               ,COI.CODBARRA
                        FROM    AD_TPRCOI COI
                        WHERE   COI.NUCONF  = R_CONF.NUCONF
                        AND     COI.CODPROD = R_CONF.CODPRODPA
                    ) SER_CONF
            WHERE   NOT EXISTS (
                        SELECT  1
                        FROM    TGFSER SER
                                INNER JOIN TGFCAB CB2 ON CB2.NUNOTA = SER.NUNOTA
                        WHERE   CB2.IDIPROC    = R_CONF.IDIPROC
                        AND     CB2.CODTIPOPER = V_CODTIPOPER
                        AND     NVL(CB2.STATUSNOTA, 'L') <> 'C'
                        AND     SER.CODPROD    = SER_CONF.CODPROD
                        AND     SER.SERIE      = SER_CONF.CODBARRA
                    )
            -- Série já presente na nota de destino sob QUALQUER produto/
            -- sequência não entra de novo (evita ORA-00001 em PK_TGFSER
            -- quando a série foi gravada com outro CODPROD/SEQUENCIA)
            AND     NOT EXISTS (
                        SELECT  1
                        FROM    TGFSER SER2
                        WHERE   SER2.NUNOTA = V_NUNOTA
                        AND     SER2.SERIE  = SER_CONF.CODBARRA
                    );

            V_SERINCL := SQL%ROWCOUNT;

            ---------------------------------------------------------------------------
            -- 4. Ajusta a quantidade do item PA: QTDNEG deve coincidir com o
            --    total de séries lançadas na nota da conferência, corrigindo
            --    tanto a menor (delta positivo) quanto a maior (delta negativo)
            ---------------------------------------------------------------------------
            SELECT  COUNT(*)
            INTO    V_QTDSER
            FROM    TGFSER SER
            WHERE   SER.NUNOTA  = V_NUNOTA
            AND     SER.CODPROD = R_CONF.CODPRODPA;

            SELECT  NVL(SUM(ITE.QTDNEG), 0)
            INTO    V_QTDLANC
            FROM    TGFITE ITE
            WHERE   ITE.NUNOTA  = V_NUNOTA
            AND     ITE.CODPROD = R_CONF.CODPRODPA;

            IF V_SERINCL > 0 THEN
                REGISTRA_CORRECAO('SERIE_INCLUIDA', R_CONF.NUCONF, R_CONF.IDIPROC,
                    V_NUNOTA, R_CONF.CODPRODPA, R_CONF.QTDCONF, V_QTDLANC, V_SERINCL,
                    V_SERINCL || ' série(s) da conferência ' || R_CONF.NUCONF
                    || ' incluída(s) em TGFSER na nota ' || V_NUNOTA);
            END IF;

            V_DELTA := V_QTDSER - V_QTDLANC;

            IF V_DELTA <> 0 THEN

                IF V_SEQPA IS NOT NULL THEN
                    UPDATE  TGFITE
                    SET     QTDNEG  = QTDNEG + V_DELTA
                           ,DTALTER = SYSDATE
                    WHERE   NUNOTA    = V_NUNOTA
                    AND     SEQUENCIA = V_SEQPA;
                ELSE
                    -- Sem item PA na nota só ocorre com delta positivo
                    -- (QTDLANC > 0 implica item existente)
                    SELECT  NVL(MAX(SEQUENCIA), 0) + 1
                    INTO    V_SEQPA
                    FROM    TGFITE
                    WHERE   NUNOTA = V_NUNOTA;

                    INSERE_ITEM_PA(V_NUNOTA, V_SEQPA, V_CODEMP, R_CONF.CODPRODPA, V_DELTA);
                END IF;

                ATUALIZA_ESTOQUE(R_CONF.CODPRODPA, V_CODEMP, V_DELTA);

                REGISTRA_CORRECAO('QTD_AJUSTADA', R_CONF.NUCONF, R_CONF.IDIPROC,
                    V_NUNOTA, R_CONF.CODPRODPA, R_CONF.QTDCONF, V_QTDLANC, V_DELTA,
                    'QTDNEG do item PA (sequência ' || V_SEQPA || ') da nota '
                    || V_NUNOTA || ' corrigida de ' || V_QTDLANC || ' para '
                    || V_QTDSER || ' para coincidir com as séries conferidas');

            END IF;

            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO SP_CONF;
                LOG_ERRO('VERIFCONF', V_NUNOTA, SQLCODE,
                         'Conferencia ' || R_CONF.NUCONF || ' / OP '
                         || R_CONF.IDIPROC || ' - ' || SQLERRM,
                         DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                         DBMS_UTILITY.FORMAT_CALL_STACK);
        END;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO('GERAL', NULL,
                 SQLCODE, SQLERRM,
                 DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                 DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20090,
            'STP_CORRIGENOTAPROD_SPARK - Erro na verificação das notas de produção: '
            || SQLERRM);
END STP_CORRIGENOTAPROD_SPARK;
/
