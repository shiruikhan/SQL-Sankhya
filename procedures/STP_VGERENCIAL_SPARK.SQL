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
  Última Revisão : 29/04/2025
  Melhorias      : Padronização, tratamento de exceções, legibilidade e lógica
==============================================================================*/

    -- Parâmetros internos
    PARAM_DTTRANSF     DATE;
    PARAM_NUNOTA       NUMBER;

    -- Constantes de operação
    P_CODTIPOPER       NUMBER := 700;
    P_CODEMPSAI        NUMBER := 1;
    P_CODEMPENT        NUMBER := 501;

    -- Variáveis de controle
    P_MAXNUNOTA        NUMBER;
    P_NUMNOTATOP       NUMBER;
    P_DHTIPOPER        DATE;

    -- Variáveis do cursor
    CURSOR CURSOR_ITENS IS
        SELECT I.SEQUENCIA, I.CODPROD, I.CODVOL, I.QTDNEG
          FROM TGFITE I
         INNER JOIN TGFEST E ON I.CODPROD = E.CODPROD 
                             AND E.CODEMP = P_CODEMPSAI 
                             AND E.CODLOCAL = 109
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

    -- Preparação dos valores para cabeçalho da nota
    SELECT MAX(NUNOTA) + 1 INTO P_MAXNUNOTA FROM TGFCAB;
    SELECT MAX(ULTCOD) + 1 INTO P_NUMNOTATOP FROM TGFNUM WHERE ARQUIVO LIKE '%700%';
    SELECT MAX(DHALTER) INTO P_DHTIPOPER FROM TGFTOP WHERE CODTIPOPER = P_CODTIPOPER;

    -- Inserção do cabeçalho da nova nota de transferência
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
        P_MAXNUNOTA, P_CODEMPSAI, 0, P_NUMNOTATOP, PARAM_DTTRANSF, P_CODEMPENT, 3, 'N', 0,
        P_CODTIPOPER, P_DHTIPOPER, 'T', 0, (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0),
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0,0, 'N', 0, 0, 0,
        0, 'N',  0, 0, 'S', 'L', 'N', 0, SYSDATE, 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'S',
        'TRANSFERENCIA ENTRE EMPRESAS REALIZADA PARA VENDA GERENCIAL', P_CODUSU, P_CODUSU, 109);	

    -- Processamento dos itens
    OPEN CURSOR_ITENS;
    LOOP
        FETCH CURSOR_ITENS INTO V_SEQUENCIA, V_CODPROD, V_CODVOL, V_QTDNEG;
        EXIT WHEN CURSOR_ITENS%NOTFOUND;

        -- Inserção do item
        INSERT INTO TGFITE (
            NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CODCFO, QTDNEG, 
            QTDENTREGUE, QTDCONFERIDA, VLRUNIT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, 
            VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST, PENDENTE, CODVOL, ATUALESTOQUE, 
            RESERVA, STATUSNOTA, CODVEND, CODEXEC, FATURAR, VLRREPRED, VLRDESCBONIF, 
            PERCDESC
        ) VALUES (
            P_MAXNUNOTA, V_SEQUENCIA, P_CODEMPSAI, V_CODPROD, 109, 0, V_QTDNEG, 
            0, 0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0, 'N', V_CODVOL, -1, 'N', 'L', 
            0, 0, 'S', 0, 0, 0
        );

        -- Inserção das séries com ajuste de estoque negativo
        INSERT INTO TGFSER (
            NUNOTA, CODPROD, SEQUENCIA, SERIE, ATUALESTOQUE, CODUSU, DTALTER
        )
        SELECT P_MAXNUNOTA, S.CODPROD, S.SEQUENCIA, S.SERIE, -1, S.CODUSU, S.DTALTER
          FROM TGFSER S
         WHERE S.NUNOTA = PARAM_NUNOTA
           AND S.CODPROD = V_CODPROD;

        -- Inserção das séries com ajuste de estoque positivo
        INSERT INTO TGFSER (
            NUNOTA, CODPROD, SEQUENCIA, SERIE, ATUALESTOQUE, CODUSU, DTALTER
        )
        SELECT P_MAXNUNOTA, S.CODPROD, -S.SEQUENCIA, S.SERIE, 1, S.CODUSU, S.DTALTER
          FROM TGFSER S
         WHERE S.NUNOTA = PARAM_NUNOTA
           AND S.CODPROD = V_CODPROD;

    END LOOP;
    CLOSE CURSOR_ITENS;

    -- Atualiza o controle de numeração
    UPDATE TGFNUM SET ULTCOD = P_NUMNOTATOP WHERE ARQUIVO LIKE '%700%';

    -- Mensagem de retorno
    P_MENSAGEM := 'Transferência concluída com sucesso! Apenas itens com estoque foram inseridos.';

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao executar a transferência: ' || SQLERRM;
        -- Possível log de erro futuro: INSERT INTO LOG_ERROS ...
END;