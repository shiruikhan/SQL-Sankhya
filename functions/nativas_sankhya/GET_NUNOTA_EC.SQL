/*==============================================================================
  Nome do Script : GET_NUNOTA_EC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o NUNOTA da nota gerada a partir de uma nota de
                  origem (via TGFVAR).
  Assinatura     : GET_NUNOTA_EC (P_NUNOTAORIG TGFCAB.NUNOTA%TYPE) RETURN
                  TGFCAB.NUNOTA%TYPE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_NUNOTA_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_NUNOTA_EC (P_NUNOTAORIG TGFCAB.NUNOTA%TYPE) 
RETURN TGFCAB.NUNOTA%TYPE
IS
 P_NUNOTA TGFCAB.NUNOTA%TYPE;
 P_TIPMOV TGFCAB.TIPMOV%TYPE;
BEGIN
	BEGIN
		SELECT DISTINCT CAB.NUNOTA, CAB.TIPMOV 
		INTO P_NUNOTA, P_TIPMOV
		FROM TGFCAB CAB
		INNER JOIN TGFVAR VAR ON VAR.NUNOTA = CAB.NUNOTA
		WHERE VAR.NUNOTAORIG = P_NUNOTAORIG
		AND ROWNUM = 1;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		 P_NUNOTA := NULL;		
	END;

	IF P_NUNOTA IS NULL THEN
		RETURN NULL;
	ELSE
		IF P_TIPMOV = 'V' THEN
			RETURN(P_NUNOTA);
		ELSE
			RETURN GET_NUNOTA_EC(P_NUNOTA);
		END IF;
	END IF;
END;
