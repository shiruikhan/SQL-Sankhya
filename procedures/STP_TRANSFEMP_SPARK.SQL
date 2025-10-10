CREATE OR REPLACE PROCEDURE STP_TRANSFEMP_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_TRANSFEMP_SPARK
  Descrição      : Realiza a transferência de produtos entre empresas, para 
                   acerto de estoque e controle de inventário.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 20/03/2023
  Última Revisão : 07/10/2025
  Melhorias      : Padronização; tratamento robusto de exceções (SAVEPOINT e EXCEPTION_INIT para TRG_INC_TGFITE);
                   correção de PK em TGFITE (SEQUENCIA com ROW_NUMBER); melhoria de legibilidade e lógica
==============================================================================*/

    -- Parâmetros de datas
    PARAM_DTTRANSF   DATE;
    PARAM_DTBALANCO  DATE;

    -- Parâmetros da operação
    P_CODTIPOPER     NUMBER := 709;
    P_CODEMPSAI      NUMBER := 501;
    P_CODEMPENT      NUMBER := 1;
    P_MAXNUNOTA      NUMBER;
    P_NUMNOTATOP     NUMBER;
    P_DHTIPOPER      DATE;
    -- Exceção específica levantada pelo trigger TRG_INC_TGFITE
    e_trigger_tgfite EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_trigger_tgfite, -20101);
    -- Contexto atual da execução para mensagens detalhadas
    v_context        VARCHAR2(100);

BEGIN
    SAVEPOINT sp_transfemp;
    v_context := 'Recupera parâmetros de data';
    -- Recupera parâmetros de data
    PARAM_DTTRANSF  := ACT_DTA_PARAM(P_IDSESSAO, 'DTTRANSF');
    PARAM_DTBALANCO := ACT_DTA_PARAM(P_IDSESSAO, 'DTBALANCO');

    -- Gera número único da nota
    SELECT NVL(MAX(NUNOTA), 0) + 1
      INTO P_MAXNUNOTA
      FROM TGFCAB;

    -- Recupera último código para nota top
    SELECT ULTCOD + 1
      INTO P_NUMNOTATOP
      FROM TGFNUM
     WHERE ARQUIVO LIKE '%709%';

    -- Recupera data/hora de alteração da operação
    SELECT MAX(DHALTER)
      INTO P_DHTIPOPER
     FROM TGFTOP
     WHERE CODTIPOPER = P_CODTIPOPER;

    v_context := 'Insere cabeçalho da nota';
    -- Insere cabeçalho da nota
    INSERT INTO TGFCAB (
		NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, CODEMPNEGOC, CODPARC,
		RATEADO, CODVEICULO, CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA,
		DHTIPVENDA, CODVEND, COMISSAO, CODMOEDA, CODOBSPADRAO, VLRSEG,
		VLRICMSSEG, VLRDESTAQUE, VLRJURO, VLRVENDOR, VLROUTROS, VLREMB,
		VLRICMSEMB, VLRDESCSERV, IPIEMB, TIPIPIEMB, VLRDESCTOT, VLRDESCTOTITEM,
		VLRFRETE, ICMSFRETE, BASEICMSFRETE, TIPFRETE, VLRNOTA, CODPARCTRANSP,
		QTDVOL, PENDENTE, BASEICMS, VLRICMS, BASEIPI, VLRIPI, ISSRETIDO,
		BASEISS, VLRISS, APROVADO, STATUSNOTA, IRFRETIDO, VLRIRF, DTALTER,
		CODPARCDEST, VLRSUBST, BASESUBSTIT, CODPROJ, NUMCONTRATO, BASEINSS,
		VLRINSS, VLRREPREDTOT, PERCDESC, CODPARCREMETENTE, CODPARCCONSIGNATARIO,
		CODPARCREDESPACHO, CODNAT, TROCO, CODUSUCOMPRADOR, CIF_FOB, OBSERVACAO,
		CODUSU, CODUSUINC,  AD_CODLOCALDEST)
	VALUES (
		P_MAXNUNOTA, P_CODEMPSAI, 0, 0, PARAM_DTTRANSF, P_CODEMPENT, 3, 'N',
		0, P_CODTIPOPER, P_DHTIPOPER, 'T', 0, 
		(SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0), 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0,0, 'N',
		0, 0, 0, 0, 'N',  0, 0, 'S', 'L', 'N', 0, SYSDATE, 0, 0, 0, 0, 0 ,0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 'S',
		'TRANSFERENCIA ENTRE EMPRESAS REALIZADA PELO DASH TRANSFERENCIA ENTRE EMPRESAS',
		P_CODUSU, P_CODUSU, 101);

    v_context := 'Insere itens da nota';
    -- Insere itens da nota conforme saldo negativo
    INSERT INTO TGFITE (
        NUNOTA, SEQUENCIA, CODEMP, CODPROD, CONTROLE, CODLOCALORIG, CODCFO, QTDNEG,
        QTDENTREGUE, QTDCONFERIDA, VLRUNIT, VLRCUS, BASEIPI, VLRIPI,
        BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST, PENDENTE,
        CODVOL, ATUALESTOQUE, RESERVA, STATUSNOTA, CODVEND, CODEXEC,
        FATURAR, VLRREPRED, VLRDESCBONIF, PERCDESC
    )
    SELECT
        P_MAXNUNOTA,
        ROW_NUMBER() OVER (ORDER BY CTE.CODPROD DESC, CTE.CONTROLE DESC),
        P_CODEMPSAI,
        CTE.CODPROD,
        CTE.CONTROLE,
        101,
        0,
        CASE 
            WHEN -CTE.QTDEST <= (
                SELECT NVL(SUM(E.QTDEST), 0)
                  FROM TGFCTE E
                 WHERE E.CODPROD = CTE.CODPROD
                   AND E.CODEMP = 501
                   AND E.QTDEST > 0
                   AND E.CODLOCAL = 101
                   AND NVL(E.CONTROLE, ' ') = NVL(CTE.CONTROLE, ' ')
                   AND E.DTCONTAGEM = PARAM_DTBALANCO
            ) THEN -CTE.QTDEST
            ELSE (
                -CTE.QTDEST + (
                    CTE.QTDEST + (
                        SELECT NVL(SUM(E.QTDEST), 0)
                          FROM TGFCTE E
                         WHERE E.CODPROD = CTE.CODPROD
                           AND E.CODEMP = 501
                           AND E.QTDEST > 0
                           AND E.CODLOCAL = 101
                           AND NVL(E.CONTROLE, ' ') = NVL(CTE.CONTROLE, ' ')
                           AND E.DTCONTAGEM = PARAM_DTBALANCO
                    )
                )
            )
        END,
        0, 0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0,
        'N', CTE.CODVOL, -1, 'N', 'L', 0, 0, 'S', 0, 0, 0
    FROM
        TGFCTE CTE
        JOIN TGFPRO PRO ON CTE.CODPROD = PRO.CODPROD
    WHERE
        TRUNC(CTE.DTCONTAGEM) = PARAM_DTBALANCO
        AND PRO.USOPROD IN ('V','T','M','R','E','P','O')
        AND CTE.QTDEST < 0
        AND CTE.CODEMP = 1
        AND CTE.CODLOCAL = 101
        AND (
            SELECT NVL(SUM(E.QTDEST), 0)
              FROM TGFCTE E
             WHERE E.CODPROD = CTE.CODPROD
               AND E.CODEMP = 501
               AND E.CODLOCAL = 101
               AND NVL(E.CONTROLE, ' ') = NVL(CTE.CONTROLE, ' ')
               AND E.DTCONTAGEM = PARAM_DTBALANCO
        ) > 0;

    v_context := 'Atualiza numerador da TOP';
    -- Atualiza numerador da TOP
    UPDATE TGFNUM
       SET ULTCOD = P_NUMNOTATOP
     WHERE ARQUIVO LIKE '%709%';

    -- Mensagem final
    IF P_MAXNUNOTA > 0 THEN
        P_MENSAGEM := 'Transferência realizada com Sucesso! O pedido já está confirmado, porém lembre-se de realizar uma validação no nr único ' || P_MAXNUNOTA;
    ELSE
        P_MENSAGEM := 'Erro na transferência!';
    END IF;

EXCEPTION
    WHEN e_trigger_tgfite THEN
        ROLLBACK TO sp_transfemp;
        P_MENSAGEM := 'Falha na validação de item (TRG_INC_TGFITE): ' || SUBSTR(SQLERRM, 1, 3500);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO sp_transfemp;
        P_MENSAGEM := 'Dados não encontrados durante ' || NVL(v_context, 'execução') || '. Detalhe: ' || SUBSTR(SQLERRM, 1, 3500);
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO sp_transfemp;
        P_MENSAGEM := 'Conflito de numeração/índice durante ' || NVL(v_context, 'execução') || '. Detalhe: ' || SUBSTR(SQLERRM, 1, 3500);
    WHEN OTHERS THEN
        ROLLBACK TO sp_transfemp;
        P_MENSAGEM := 'Erro inesperado (' || TO_CHAR(SQLCODE) || ') durante ' || NVL(v_context, 'execução') || '. Detalhe: ' || SUBSTR(SQLERRM, 1, 3500);

END STP_TRANSFEMP_SPARK;