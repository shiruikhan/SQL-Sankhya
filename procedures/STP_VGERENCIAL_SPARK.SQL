create or replace PROCEDURE STP_VGERENCIAL_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_VGERENCIAL_SPARK
  Descrição      : Realiza a transferência de produtos entre empresas, para 
                   fins de controle gerencial de vendas.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/10/2023
  Última Revisão : 02/07/2025
  Melhorias      : Validação de empresa origem, controle de estoque e séries, refatorado.
==============================================================================*/

    -- Constantes de operação
    C_CODTIPOPER       CONSTANT NUMBER := 700;
    C_CODEMPSAI        CONSTANT NUMBER := 1;
    C_CODEMPENT        CONSTANT NUMBER := 501;
    C_CODLOCAL_ORIGEM  CONSTANT NUMBER := 109;
    C_CODPARC_DEFAULT  CONSTANT NUMBER := 3;

    -- Parâmetros internos
    PARAM_DTTRANSF     DATE;
    PARAM_NUNOTA       NUMBER;

    -- Variáveis de controle
    P_MAXNUNOTA        NUMBER;
    P_NUMNOTATOP       NUMBER;
    P_DHTIPOPER        DATE;

    -- Variáveis de validação
    V_EXISTS           NUMBER;
    V_CODEMP_ORIGEM    TGFCAB.CODEMP%TYPE;
    V_SERIE_EXISTS     NUMBER;
    V_DUPLICIDADE      TGFCAB.AD_NUNOTATRAN%TYPE;


    -- Variáveis do cursor
    CURSOR CURSOR_ITENS IS
        SELECT I.SEQUENCIA, I.CODPROD, I.CODVOL, I.QTDNEG
          FROM TGFITE I
         INNER JOIN TGFEST E ON I.CODPROD = E.CODPROD 
                             AND E.CODEMP = C_CODEMPSAI
                             AND E.CODLOCAL = C_CODLOCAL_ORIGEM
         WHERE I.NUNOTA = PARAM_NUNOTA
           AND E.ESTOQUE >= I.QTDNEG;

    V_SEQUENCIA        TGFITE.SEQUENCIA%TYPE;
    V_CODPROD          TGFITE.CODPROD%TYPE;
    V_CODVOL           TGFITE.CODVOL%TYPE;
    V_QTDNEG           TGFITE.QTDNEG%TYPE;

BEGIN
    -- Busca dos parâmetros da sessão
    PARAM_DTTRANSF := ACT_DTA_PARAM(P_IDSESSAO, 'DTTRANSF');
    PARAM_NUNOTA   := ACT_INT_PARAM(P_IDSESSAO, 'NUNOTA');

    -- Validação de existência da nota
    SELECT COUNT(*) INTO V_EXISTS FROM TGFCAB WHERE NUNOTA = PARAM_NUNOTA;
    IF V_EXISTS = 0 THEN
        P_MENSAGEM := 'Nota de origem não encontrada.';
        RETURN;
    END IF;
    
    -- Validação de duplicidade
    SELECT AD_NUNOTATRAN INTO V_DUPLICIDADE FROM TGFCAB WHERE NUNOTA = PARAM_NUNOTA;
    IF V_DUPLICIDADE IS NOT NULL THEN
        P_MENSAGEM := 'Transferência já foi realizada anteriormente para esta nota.';
        RETURN;
    END IF;

    -- Validação de empresa origem
    SELECT CODEMP INTO V_CODEMP_ORIGEM FROM TGFCAB WHERE NUNOTA = PARAM_NUNOTA;
    IF V_CODEMP_ORIGEM != C_CODEMPENT THEN
        P_MENSAGEM := 'Operação não permitida. A nota de origem não pertence à empresa 501.';
        RETURN;
    END IF;

    -- Validação de existência de séries
    SELECT COUNT(*) INTO V_SERIE_EXISTS FROM TGFSER WHERE NUNOTA = PARAM_NUNOTA;
    IF V_SERIE_EXISTS = 0 THEN
        P_MENSAGEM := 'Nota de origem não possui séries vinculadas. Operação cancelada.';
        RETURN;
    END IF;

    -- Validação de itens com estoque suficiente
    OPEN CURSOR_ITENS;
    FETCH CURSOR_ITENS INTO V_SEQUENCIA, V_CODPROD, V_CODVOL, V_QTDNEG;
    IF CURSOR_ITENS%NOTFOUND THEN
        P_MENSAGEM := 'Nenhum item com estoque disponível para transferência.';
        CLOSE CURSOR_ITENS;
        RETURN;
    END IF;
    CLOSE CURSOR_ITENS;

    -- Preparação dos valores para cabeçalho da nota
    SELECT MAX(NUNOTA) + 1 INTO P_MAXNUNOTA FROM TGFCAB;
    SELECT MAX(ULTCOD) + 1 INTO P_NUMNOTATOP FROM TGFNUM WHERE ARQUIVO LIKE '%700%';
    SELECT MAX(DHALTER) INTO P_DHTIPOPER FROM TGFTOP WHERE CODTIPOPER = C_CODTIPOPER;

    -- Inserção do cabeçalho da nova nota
    INSERT INTO TGFCAB (
        NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, CODEMPNEGOC, CODPARC, RATEADO, CODVEICULO,
        CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA, DHTIPVENDA, CODVEND, COMISSAO, CODMOEDA,
        CODOBSPADRAO, VLRSEG, VLRICMSSEG, VLRDESTAQUE, VLRJURO, VLRVENDOR, VLROUTROS, VLREMB,
        VLRICMSEMB, VLRDESCSERV, IPIEMB, TIPIPIEMB, VLRDESCTOT, VLRDESCTOTITEM, VLRFRETE,
        ICMSFRETE, BASEICMSFRETE, TIPFRETE, VLRNOTA, CODPARCTRANSP, QTDVOL, PENDENTE, BASEICMS,
        VLRICMS, BASEIPI, VLRIPI, ISSRETIDO, BASEISS, VLRISS, APROVADO, STATUSNOTA, IRFRETIDO,
        VLRIRF, DTALTER, CODPARCDEST, VLRSUBST, BASESUBSTIT, CODPROJ, NUMCONTRATO, BASEINSS,
        VLRINSS, VLRREPREDTOT, PERCDESC, CODPARCREMETENTE, CODPARCCONSIGNATARIO, CODPARCREDESPACHO,
        CODNAT, TROCO, CODUSUCOMPRADOR, CIF_FOB, OBSERVACAO, CODUSU, CODUSUINC,  AD_CODLOCALDEST) 
    VALUES (
        P_MAXNUNOTA, C_CODEMPSAI, 0, P_NUMNOTATOP, PARAM_DTTRANSF, C_CODEMPENT, C_CODPARC_DEFAULT, 'N', 0,
        C_CODTIPOPER, P_DHTIPOPER, 'T', 0, (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0),
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0, 0, 'N', 0, 0, 0,
        0, 'N', 0, 0, 'S', 'L', 'N', 0, SYSDATE, 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'S',
        'TRANSFERENCIA ENTRE EMPRESAS REALIZADA PARA VENDA GERENCIAL', P_CODUSU, P_CODUSU, C_CODLOCAL_ORIGEM);

    -- Processamento dos itens
    OPEN CURSOR_ITENS;
    LOOP
        FETCH CURSOR_ITENS INTO V_SEQUENCIA, V_CODPROD, V_CODVOL, V_QTDNEG;
        EXIT WHEN CURSOR_ITENS%NOTFOUND;

        INSERT INTO TGFITE (
            NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CODCFO, QTDNEG, 
            QTDENTREGUE, QTDCONFERIDA, VLRUNIT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, 
            VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST, PENDENTE, CODVOL, ATUALESTOQUE, 
            RESERVA, STATUSNOTA, CODVEND, CODEXEC, FATURAR, VLRREPRED, VLRDESCBONIF, 
            PERCDESC
        ) VALUES (
            P_MAXNUNOTA, V_SEQUENCIA, C_CODEMPSAI, V_CODPROD, C_CODLOCAL_ORIGEM, 0, V_QTDNEG, 
            0, 0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0, 'N', V_CODVOL, -1, 'N', 'L', 
            0, 0, 'S', 0, 0, 0
        );

        INSERT INTO TGFSER (
            NUNOTA, CODPROD, SEQUENCIA, SERIE, ATUALESTOQUE, CODUSU, DTALTER
        )
        SELECT P_MAXNUNOTA, S.CODPROD, S.SEQUENCIA, S.SERIE, -1, S.CODUSU, S.DTALTER
          FROM TGFSER S
         WHERE S.NUNOTA = PARAM_NUNOTA AND S.CODPROD = V_CODPROD;

        INSERT INTO TGFSER (
            NUNOTA, CODPROD, SEQUENCIA, SERIE, ATUALESTOQUE, CODUSU, DTALTER
        )
        SELECT P_MAXNUNOTA, S.CODPROD, -S.SEQUENCIA, S.SERIE, 1, S.CODUSU, S.DTALTER
          FROM TGFSER S
         WHERE S.NUNOTA = PARAM_NUNOTA AND S.CODPROD = V_CODPROD;

    END LOOP;
    CLOSE CURSOR_ITENS;

    UPDATE TGFNUM SET ULTCOD = P_NUMNOTATOP WHERE ARQUIVO LIKE '%700%';

    -- Atualiza a nota de origem com referência à nova nota
    UPDATE TGFCAB SET AD_NUNOTATRAN = P_MAXNUNOTA WHERE NUNOTA = PARAM_NUNOTA;

    P_MENSAGEM := 'Transferência concluída com sucesso! Apenas itens com estoque foram inseridos.';

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao executar a transferência: ' || SQLERRM;
END;