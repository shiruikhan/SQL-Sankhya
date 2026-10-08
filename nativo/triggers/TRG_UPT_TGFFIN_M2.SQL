/*==============================================================================
  Nome do Script : TRG_UPT_TGFFIN_M2
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPT_TGFFIN_M2', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_M2" 
BEFORE UPDATE ON TGFFIN 
FOR EACH ROW
         WHEN ((NEW.NUNOTA IS NOT NULL) AND ((NEW.NURENEG IS NULL) OR (NEW.NURENEG = 0)) AND (NEW.VLRBAIXA <> 0) AND (NEW.CODPROJ <> 0)) DECLARE
  P_COUNT            INT := 0;
  P_M2               FLOAT;
  P_VLRNOTA          TGFCAB.VLRNOTA%TYPE;
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

	SELECT COUNT(*)
	INTO P_COUNT
	FROM TCSPRJ 
	WHERE CODPROJ = :NEW.CODPROJ
	AND AREATOTAL > 0;
	
	IF (P_COUNT > 0) THEN
		SELECT SUM(ITE.QTDNEG * CASE WHEN PRO.M3 IS NULL THEN 0 ELSE PRO.M3 END)
		INTO P_M2
		FROM TGFITE ITE
		, TGFPRO PRO
		WHERE ITE.NUNOTA = :NEW.NUNOTA
		AND ITE.CODPROD = PRO.CODPROD
		AND ITE.SEQUENCIA > 0;
		
		IF (P_M2 > 0) THEN
			SELECT VLRNOTA 
			INTO P_VLRNOTA
			FROM TGFCAB
			WHERE NUNOTA = :NEW.NUNOTA;
			:NEW.M2 := ROUND(:NEW.VLRDESDOB / P_VLRNOTA * P_M2, 6);
		ELSE 
			:NEW.M2 := 0;
		END IF;
	END IF;
	RETURN;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_M2" ENABLE;
