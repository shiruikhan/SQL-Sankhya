/*==============================================================================
  Nome do Script : SNK_GET_COD_LEGAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina o codigo legal de motivo de restituicao de ICMS-ST em devolucao
                  de venda (TGFNST/TGFDIN).
  Assinatura     : SNK_GET_COD_LEGAL (P_NUNOTAVENDA NUMBER ,P_SEQUENCIAVENDA NUMBER ,P_QTDVENDA FLOAT ,P_NUNOTAORIG NUMBER ,P_SEQUENCIAORIG NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_COD_LEGAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_COD_LEGAL (P_NUNOTAVENDA		NUMBER
											,P_SEQUENCIAVENDA	NUMBER
											,P_QTDVENDA			FLOAT
											,P_NUNOTAORIG		NUMBER
											,P_SEQUENCIAORIG	NUMBER)
RETURN NUMBER
AS 
	P_RESULT		NUMBER;
	P_COUNT			NUMBER;
BEGIN
	P_RESULT := NULL;

	SELECT COUNT(1) 
	INTO P_COUNT
	FROM TGFNST NST
	WHERE NST.NUNOTA = P_NUNOTAORIG
	    AND NST.SEQUENCIA = P_SEQUENCIAORIG
	    AND NVL(NST.VLRSUBST, 0) > 0;

	IF P_COUNT > 0 THEN
		SELECT MAX(TAB.CODLEGAL) 
		INTO P_RESULT
		FROM (
			SELECT CASE WHEN COD_MOT_RES IN (3, 4) THEN 2
			 			WHEN COD_MOT_RES = 2 THEN 3
			 			WHEN COD_MOT_RES = 1 THEN 4
			 			WHEN ROUND(NVL(NST.VLRICMS, 0) + NVL(NST.VLRSUBST, 0), 2) > ROUND(NVL((SELECT SUM(VALOR)
																							   FROM TGFDIN DIN 
																							   WHERE DIN.NUNOTA = P_NUNOTAVENDA
																								   AND DIN.SEQUENCIA = P_SEQUENCIAVENDA
																								   AND DIN.CODIMP IN (1, 2)), 0) / P_QTDVENDA * NST.QTDENT, 2) THEN 1
						ELSE 0
				   END AS CODLEGAL
			FROM TGFNST NST 
			WHERE NST.NUNOTA = P_NUNOTAORIG 
				AND NST.SEQUENCIA = P_SEQUENCIAORIG
				AND NVL(NST.VLRSUBST, 0) > 0
		) TAB;
	END IF;

	RETURN P_RESULT;
END;
