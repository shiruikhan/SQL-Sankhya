/*==============================================================================
  Nome do Script : STP_TIM_INSERT_TIMDTL
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Insere um lançamento de detalhe (TIMDTL) de uma parcela (NUFIN) no módulo TIM (locação), com recebedor/repassa-para conforme o sinal do valor; chamada pelas triggers de TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 03/07/2024.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_TIM_INSERT_TIMDTL', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_TIM_INSERT_TIMDTL" (
	P_NUFIN INT,
    P_DTINI DATE,
    P_DTFIN DATE,
    P_HISTORICO INT,
    P_VALOR FLOAT,
    P_COMPLEMENTO VARCHAR)
IS
BEGIN
	
	INSERT INTO TIMDTL(
        DTLCODIGO,
        DTLPARCELA,
        DTLRECEBEDE,
        DTLREPASSAPARA,
        DTLDTFIM,
        DTLDTINIC,
        DTLHISTORICO,
        DTLVALOR,
        DTLCOMPLEMENTO,
        DTLGARANTIDO,
        DTLTAXAADM,
        DTLDATAMOV,
        DTLDATAINCLUSAO,
        DTLUSUARIO,
        DTLDATAALTERACAO,
        DTLUSUARIOALT
    )
    SELECT (
            SELECT NVL(MAX(NVL(DTLCODIGO,0)),0)+1
            FROM TIMDTL
            WHERE DTLPARCELA = P_NUFIN
        ) DTLCODIGO,
        P_NUFIN DTLPARCELA,
        CASE WHEN P_VALOR < 0 THEN HCBREPASSAPARA ELSE HCBRECEBEDE END DTLRECEBEDE,
        CASE WHEN P_VALOR < 0 THEN HCBRECEBEDE ELSE HCBREPASSAPARA END DTLREPASSAPARA,
        P_DTFIN DTLDTFIM,
        P_DTINI DTLDTINIC,
        HCBCODIGO DTLHISTORICO,
        ABS(P_VALOR) DTLVALOR,
        P_COMPLEMENTO DTLCOMPLEMENTO,
        CASE WHEN (FIN.TIMDHGERREPASSE IS NOT NULL OR FIN.TIMDHGERREPPARCIAL IS NOT NULL) THEN 'N' ELSE HCBGARANTIDO END DTLGARANTIDO,
        HCBADM DTLTAXAADM,
        SYSDATE DTLDATAMOV,
        SYSDATE DTLDATAINCLUSAO,
        STP_GET_CODUSULOGADO() DTLUSUARIO,
        SYSDATE DTLDATAALTERACAO,
        STP_GET_CODUSULOGADO() DTLUSUARIOALT
    FROM TIMHCB
	INNER JOIN TGFFIN FIN ON FIN.NUFIN = P_NUFIN
    WHERE HCBCODIGO = P_HISTORICO;
   
	INSERT INTO TIMFRT(
		FRTNUFIN
	)
	SELECT P_NUFIN FRTNUFIN
	FROM TIMHCB
	INNER JOIN TGFFIN ON NUFIN = P_NUFIN
	WHERE HCBCODIGO = P_HISTORICO
	AND TIMORIGEM IN ('AL','AV','FC')
	AND TIMTXADMGERALU  = 'S'
	AND HCBADM = 'S'
	AND (HCBREPASSAPARA = 'L'
		OR HCBRECEBEDE = 'L');

END;
