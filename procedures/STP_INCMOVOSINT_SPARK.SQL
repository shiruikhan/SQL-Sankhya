create or replace PROCEDURE "STP_INCMOVOSINT_SPARK" (P_CODUSU NUMBER, P_IDSESSAO VARCHAR2, P_QTDLINHAS NUMBER, P_MENSAGEM OUT VARCHAR2) AS
    FIELD_NUMOS         NUMBER;
    FIELD_ID            NUMBER;
    P_CODEMPSAI         CONSTANT NUMBER := 1;
    P_CODTIPOPER        NUMBER;
    P_CODLOCALORIG      NUMBER;
    P_CODCENCUS         NUMBER;
    P_ATUALESTOQUE      NUMBER;
    P_TIPMOV            VARCHAR2(1);
    P_OBSERVACAO        VARCHAR2(4000);
    P_MAXNUNOTA         NUMBER;
    P_NUMNOTATOP        NUMBER;
    P_DHTIPOPER         DATE;
    P_SETOR             AD_OSINTERNA.SETOR%TYPE;

/*==============================================================================
  Nome do Script : STP_INCMOVOSINT_SPARK
  Descrição      : Realiza a movimentação de materiais proveniente de consumo
                   em operações de atendimento das O.S. Internas.
                   SETOR = 'T': consumo do TI (TOP 515, local 115, CC 20300).
                   SETOR = 'M': solicitação do PCM (TOP 400, local 101, CC 20600).
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 05/09/2025
  Última Revisão : 31/03/2026
==============================================================================*/

BEGIN
    FIELD_NUMOS := ACT_INT_FIELD(P_IDSESSAO, 1, 'NUMOS');
    FIELD_ID    := ACT_INT_FIELD(P_IDSESSAO, 1, 'ID');

    -- Identifica o setor da O.S. para determinar os parâmetros da movimentação
    SELECT SETOR INTO P_SETOR
      FROM AD_OSINTERNA
     WHERE NUMOS = FIELD_NUMOS;

    IF P_SETOR = 'T' THEN
        P_CODTIPOPER   := 515;
        P_CODLOCALORIG := 115;
        P_CODCENCUS    := 20300;
        P_ATUALESTOQUE := -1;
        P_TIPMOV       := 'Q';
        P_OBSERVACAO   := 'MOVIMENTAÇÃO DE CONSUMO DO TI REFERENTE À O.S. INTERNA ' || FIELD_NUMOS;

    ELSIF P_SETOR = 'M' THEN
        P_CODTIPOPER   := 400;
        P_CODLOCALORIG := 101;
        P_CODCENCUS    := 20600;
        P_ATUALESTOQUE := 0;
        P_TIPMOV       := 'J';
        P_OBSERVACAO   := 'SOLICITAÇÃO DO PCM REFERENTE O.S. INTERNA NR' || FIELD_NUMOS;

    ELSE
        P_MENSAGEM := 'Setor "' || P_SETOR || '" não suportado por esta procedure.';
        RETURN;
    END IF;

    -- Determinar novo número de nota
    SELECT NVL(MAX(NUNOTA), 0) + 1 INTO P_MAXNUNOTA FROM TGFCAB;

    -- Determinar novo número único do tipo de operação
    SELECT NVL(MAX(ULTCOD), 0) + 1 INTO P_NUMNOTATOP
      FROM TGFNUM
     WHERE ARQUIVO LIKE '%' || P_CODTIPOPER || '%';

    -- Obter data da última alteração do tipo de operação
    SELECT MAX(DHALTER) INTO P_DHTIPOPER
      FROM TGFTOP
     WHERE CODTIPOPER = P_CODTIPOPER;

    -- Inserir nota
    INSERT INTO TGFCAB (NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, CODEMPNEGOC, CODPARC, RATEADO, CODVEICULO, CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA, DHTIPVENDA, CODVEND, COMISSAO, CODMOEDA, CODOBSPADRAO, VLRSEG, VLRICMSSEG, VLRDESTAQUE, VLRJURO, VLRVENDOR, VLROUTROS, VLREMB, VLRICMSEMB, VLRDESCSERV,
        IPIEMB, TIPIPIEMB, VLRDESCTOT, VLRDESCTOTITEM, VLRFRETE, ICMSFRETE, BASEICMSFRETE, TIPFRETE, VLRNOTA, CODPARCTRANSP, QTDVOL, PENDENTE, BASEICMS, VLRICMS, BASEIPI, VLRIPI, ISSRETIDO, BASEISS, VLRISS, APROVADO, STATUSNOTA, IRFRETIDO, VLRIRF, DTALTER, CODPARCDEST, VLRSUBST, BASESUBSTIT, CODPROJ, NUMCONTRATO, BASEINSS,
        VLRINSS, VLRREPREDTOT, PERCDESC, CODPARCREMETENTE, CODPARCCONSIGNATARIO, CODPARCREDESPACHO, CODNAT, TROCO, CODUSUCOMPRADOR, CIF_FOB, OBSERVACAO, CODUSU, CODUSUINC)
    VALUES (P_MAXNUNOTA, P_CODEMPSAI, P_CODCENCUS, 0, SYSDATE, P_CODEMPSAI, 3, 'N', 0, P_CODTIPOPER, P_DHTIPOPER, P_TIPMOV, 0,
        (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0, 0, 'N', 0, 0,
        0, 0, 'N', 0, 0, 'S', 'L', 'N', 0, SYSDATE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'S', P_OBSERVACAO, P_CODUSU, P_CODUSU);

    -- Inserir itens
    INSERT INTO TGFITE (NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CODCFO, QTDNEG, QTDENTREGUE, QTDCONFERIDA, VLRUNIT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST, PENDENTE, CODVOL, ATUALESTOQUE, RESERVA, STATUSNOTA, CODVEND, CODEXEC, FATURAR, VLRREPRED, VLRDESCBONIF, PERCDESC)
    SELECT P_MAXNUNOTA, I.ID, P_CODEMPSAI, I.CODPROD, P_CODLOCALORIG, 0, I.QTD, 0, 0,
        NVL(OBTEMCUSTO_SPARK(I.CODPROD, 'S', P_CODEMPSAI, 'S', P_CODLOCALORIG, 'N', NULL, SYSDATE, 1), 0.01),
        0, 0, 0, 0, 0, 0, 0, 0, 'N', I.CODVOL, P_ATUALESTOQUE, 'N', 'L', 0, 0, 'S', 0, 0, 0
      FROM AD_TGSIOSI I
     WHERE I.NUMOS = FIELD_NUMOS;

    -- Atualizar Ordem de Serviço com número da nota gerada
    UPDATE AD_TGSIOSI
       SET NUNOTA = P_MAXNUNOTA
     WHERE NUMOS = FIELD_NUMOS;

    -- Atualizar controle de número do tipo de operação
    UPDATE TGFNUM
       SET ULTCOD = P_NUMNOTATOP
     WHERE ARQUIVO LIKE '%' || P_CODTIPOPER || '%';

    P_MENSAGEM := 'Movimentação realizada com sucesso! Valide o número único ' || P_MAXNUNOTA;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        P_MENSAGEM := 'O.S. ' || FIELD_NUMOS || ' não encontrada em AD_OSINTERNA.';
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro: ' || SQLERRM;
END;
