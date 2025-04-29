create or replace PROCEDURE STP_RESERVA_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_RESERVA_SPARK
  Descrição      : Realiza a reserva de produtos no estoque, criando uma nota 
                   de transferência para o local de reserva.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 11/12/2023
  Última Revisão : 29/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/

    -- Parâmetros auxiliares
    PARAM_DTTRANSF     DATE;
    PARAM_NUNOTA       NUMBER;
    P_CODTIPOPER       NUMBER := 716;
    P_CODEMPSAI        NUMBER := 1;
    P_CODEMPENT        NUMBER := 1;
    P_MAXNUNOTA        NUMBER;
    P_NUCONFATUAL      NUMBER;
    P_NUMNOTATOP       NUMBER;
    P_DHTIPOPER        DATE;

BEGIN
    -- Recupera parâmetros da sessão
    PARAM_DTTRANSF := ACT_DTA_PARAM(P_IDSESSAO, 'DTTRANSF');
    PARAM_NUNOTA   := ACT_INT_PARAM(P_IDSESSAO, 'NUNOTA');

    -- Geração de nova NUNOTA (nota de transferência)
    SELECT MAX(NUNOTA) + 1
      INTO P_MAXNUNOTA
      FROM TGFCAB;

    -- Recupera número de conferência da nota original
    SELECT NUCONFATUAL
      INTO P_NUCONFATUAL
      FROM TGFCAB
     WHERE NUNOTA = PARAM_NUNOTA;

    -- Recupera número de nota de operação
    SELECT MAX(ULTCOD) + 1
      INTO P_NUMNOTATOP
      FROM TGFNUM
     WHERE ARQUIVO LIKE '%716%';

    -- Recupera data de alteração da TOP
    SELECT MAX(DHALTER)
      INTO P_DHTIPOPER
      FROM TGFTOP
     WHERE CODTIPOPER = P_CODTIPOPER;

    -- Insere a nova nota de transferência (TGFCAB)
    INSERT INTO TGFCAB (
        NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, CODEMPNEGOC, CODPARC, RATEADO,
        CODVEICULO, CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA, DHTIPVENDA, CODVEND,
        COMISSAO, CODMOEDA, CODOBSPADRAO, VLRSEG, VLRICMSSEG, VLRDESTAQUE, VLRJURO,
        VLRVENDOR, VLROUTROS, VLREMB, VLRICMSEMB, VLRDESCSERV, IPIEMB, TIPIPIEMB,
        VLRDESCTOT, VLRDESCTOTITEM, VLRFRETE, ICMSFRETE, BASEICMSFRETE, TIPFRETE,
        VLRNOTA, CODPARCTRANSP, QTDVOL, PENDENTE, BASEICMS, VLRICMS, BASEIPI, VLRIPI,
        ISSRETIDO, BASEISS, VLRISS, APROVADO, /*STATUSNOTA,*/ IRFRETIDO, VLRIRF,
        DTALTER, CODPARCDEST, VLRSUBST, BASESUBSTIT, CODPROJ, NUMCONTRATO, BASEINSS, 
        VLRINSS, VLRREPREDTOT, PERCDESC, CODPARCREMETENTE, CODPARCCONSIGNATARIO, 
        CODPARCREDESPACHO, CODNAT, TROCO, CODUSUCOMPRADOR, CIF_FOB, OBSERVACAO, 
        CODUSU, CODUSUINC, AD_CODLOCALDEST)
    VALUES (
        P_MAXNUNOTA, P_CODEMPSAI, 0, 0, PARAM_DTTRANSF, P_CODEMPENT, 3, 'N', 0, 
        P_CODTIPOPER, P_DHTIPOPER, 'T', 0, (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0),
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0,0, 'N', 0, 0,
        0, 0, 'N',  0, 0, 'S',/* 'L', */'N', 0, SYSDATE, 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 'S', 'TRANSFERENCIA DE ESTOQUE PARA RESERVA', P_CODUSU, P_CODUSU, 197);

    -- Insere os itens da nota (TGFITE)
    INSERT INTO TGFITE (
        NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CODCFO,
        QTDNEG, QTDENTREGUE, QTDCONFERIDA, VLRUNIT, VLRCUS, BASEIPI,
        VLRIPI, BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST,
        PENDENTE, CODVOL, ATUALESTOQUE, RESERVA, STATUSNOTA, CODVEND,
        CODEXEC, FATURAR, VLRREPRED, VLRDESCBONIF, PERCDESC
    )
    SELECT 
        P_MAXNUNOTA, SEQUENCIA, P_CODEMPSAI, I.CODPROD, 197, 0,
        I.QTDNEG, 0, 0, 0.01, 0, 0,
        0, 0, 0, 0, 0, 0,
        'N', I.CODVOL, -1, 'N', 'L', 0,
        0, 'S', 0, 0, 0
    FROM TGFITE I
    WHERE I.NUNOTA = PARAM_NUNOTA;

    -- Insere os números de série negativos e positivos (TGFSER)
    INSERT INTO TGFSER (
        NUNOTA, CODPROD, SEQUENCIA, SERIE, ATUALESTOQUE, CODUSU, DTALTER
    )
    SELECT P_MAXNUNOTA, S.CODPROD, S.SEQUENCIA, S.SERIE, -1, S.CODUSU, S.DTALTER
    FROM TGFSER S
    WHERE S.NUNOTA = PARAM_NUNOTA;

    INSERT INTO TGFSER (
        NUNOTA, CODPROD, SEQUENCIA, SERIE, ATUALESTOQUE, CODUSU, DTALTER
    )
    SELECT P_MAXNUNOTA, S.CODPROD, -S.SEQUENCIA, S.SERIE, 1, S.CODUSU, S.DTALTER
    FROM TGFSER S
    WHERE S.NUNOTA = PARAM_NUNOTA;

    -- Atualiza status e conferência
    UPDATE TGFCAB SET LIBCONF = 'S' WHERE NUNOTA = P_MAXNUNOTA;
    UPDATE TGFCAB SET STATUSNOTA = 'L' WHERE NUNOTA = P_MAXNUNOTA;

    -- Atualiza último número de nota de operação
    UPDATE TGFNUM SET ULTCOD = P_NUMNOTATOP WHERE ARQUIVO LIKE '%716%';

    -- Retorno de mensagem
    IF P_MAXNUNOTA IS NOT NULL THEN
        P_MENSAGEM := 'Transferência realizada com Sucesso! A reserva foi realizada e já está confirmada. Nº único: ' || P_MAXNUNOTA;
    ELSE
        P_MENSAGEM := 'Erro na transferência!';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro na execução da procedure: ' || SQLERRM;
END;