/*==============================================================================
  Nome do Script : SNK_CONFIRMOU_DESC_GRAN_CARGA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se a descarga de granel de uma nota (pedido ou venda vinculada)
                  ja foi confirmada em TGFDGC.
  Assinatura     : SNK_CONFIRMOU_DESC_GRAN_CARGA (P_NUNOTA NUMBER)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_CONFIRMOU_DESC_GRAN_CARGA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_CONFIRMOU_DESC_GRAN_CARGA (P_NUNOTA 	NUMBER)
RETURN VARCHAR2
AS
	P_TIPMOV		VARCHAR2(1);
	P_NUNOTACALC	NUMBER;
	P_COUNT			NUMBER;
	P_RESULT        VARCHAR2(1);
BEGIN
	P_NUNOTACALC := 0;
	P_RESULT := 'N';

	SELECT COUNT(1) INTO P_COUNT
	FROM TGFCAB
	WHERE NUNOTA = P_NUNOTA;
	
	IF P_COUNT > 0 THEN
		SELECT TIPMOV INTO P_TIPMOV
		FROM TGFCAB
		WHERE NUNOTA = P_NUNOTA;

		IF P_TIPMOV = 'P' THEN
			P_NUNOTACALC := P_NUNOTA;

		ELSIF P_TIPMOV = 'V' THEN
            BEGIN
                SELECT DGC.NUNOTA INTO P_NUNOTACALC
                FROM TGFVAR VAR
                    ,TGFDGC DGC
                WHERE VAR.NUNOTA = P_NUNOTA
                    AND VAR.NUNOTA <> VAR.NUNOTAORIG
                    AND DGC.NUNOTA = VAR.NUNOTAORIG
                    AND DGC.CONFIRMADO = 'S';            
            EXCEPTION WHEN NO_DATA_FOUND THEN
                P_NUNOTACALC := 0;
            END;
		END IF;

		IF P_NUNOTACALC <> 0 THEN
            BEGIN
                SELECT CONFIRMADO INTO P_RESULT
                FROM TGFDGC 
                WHERE NUNOTA = P_NUNOTACALC 
                    AND SEQUENCIA = 0;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                P_RESULT := 'N';
            END;
		END IF;
	END IF;

  RETURN P_RESULT;
END;
