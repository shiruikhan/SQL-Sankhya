/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_SERIE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_SERIE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_SERIE" BEFORE UPDATE ON TGFCAB FOR EACH ROW 
DECLARE
    P_COUNT INT := 0;
  BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  IF (:NEW.CODTIPOPER <> :OLD.CODTIPOPER) OR (:NEW.NUMCONTRATO <> :OLD.NUMCONTRATO) THEN 
    SELECT 
	 COUNT(1) 
	INTO
	 P_COUNT
	FROM 
	 TGFTOP ITPO, 
	 TGFTOP DTPO
	WHERE :NEW.CODTIPOPER = ITPO.CODTIPOPER
	  AND :NEW.DHTIPOPER = ITPO.DHALTER
	  AND :OLD.CODTIPOPER = DTPO.CODTIPOPER
	  AND :OLD.DHTIPOPER = DTPO.DHALTER
	  AND (DTPO.INTEGSERCON <> ITPO.INTEGSERCON OR
          :NEW.NUMCONTRATO <> :OLD.NUMCONTRATO);
		 
    IF (P_COUNT<>0) THEN
        DELETE FROM TCSPSS 
		WHERE :OLD.NUMCONTRATO IN 
		( 
		SELECT DISTINCT PSS.NUMCONTRATO 
		FROM 
		  TCSPSS PSS
	      , TGFSER SER
	      , TGFTOP TPO
        WHERE SER.NUNOTA = :OLD.NUNOTA 
          AND PSS.NUMCONTRATO = :OLD.NUMCONTRATO
          AND TPO.CODTIPOPER = :OLD.CODTIPOPER
          AND TPO.DHALTER = :OLD.DHTIPOPER
          AND TPO.INTEGSERCON = 'E'
		  AND SER.CODPROD = PSS.CODPROD
          AND SER.SERIE = PSS.SERIE 
		);

       /* 
	     N?o seria o new no lugar do old
		 No sql tem ligacao com pss e n?o deve precisar pois estou inserindo nela todos que tem na tgfser, se a logica for essa
	   */
        INSERT INTO TCSPSS
                (NUMCONTRATO, CODPROD, SERIE, ATIVO, CODUSU, DTALTER)
        SELECT :OLD.NUMCONTRATO, SER.CODPROD, SER.SERIE, 'S' as Ativo, :OLD.CODUSU, :OLD.DTALTER
        FROM
		    TGFSER SER
		  , TCSPSS PSS
          , TGFTOP TPO
        WHERE SER.NUNOTA = :OLD.NUNOTA
		  AND TPO.CODTIPOPER = :OLD.CODTIPOPER
          AND TPO.DHALTER = :OLD.DHTIPOPER
          AND TPO.INTEGSERCON = 'B'
          AND PSS.NUMCONTRATO = :OLD.NUMCONTRATO
          AND PSS.CODPROD = SER.CODPROD
          AND PSS.SERIE = SER.SERIE;		  
		  

        DELETE FROM TCSPSS 
		WHERE :NEW.NUMCONTRATO IN 
		( 
		SELECT DISTINCT PSS.NUMCONTRATO 
		FROM 
		  TCSPSS PSS
         , TGFSER SER
         , TGFTOP TPO
	    WHERE SER.NUNOTA = :NEW.NUNOTA 
	      AND PSS.NUMCONTRATO = :NEW.NUMCONTRATO
	      AND TPO.CODTIPOPER = :NEW.CODTIPOPER
	      AND TPO.DHALTER = :NEW.DHTIPOPER
	      AND TPO.INTEGSERCON = 'B'
		  AND SER.CODPROD = PSS.CODPROD
	      AND SER.SERIE = PSS.SERIE); 
		

        INSERT INTO TCSPSS
                (NUMCONTRATO, CODPROD, SERIE, ATIVO, CODUSU, DTALTER)
        SELECT :NEW.NUMCONTRATO, SER.CODPROD, SER.SERIE, 'S' as Ativo, :NEW.CODUSU, :NEW.DTALTER
        FROM 
	        TGFSER SER
		  , TCSPSS PSS
          , TGFTOP TPO
        WHERE SER.NUNOTA = :NEW.NUNOTA 
          AND TPO.CODTIPOPER = :NEW.CODTIPOPER
          AND TPO.DHALTER = :NEW.DHTIPOPER
          AND TPO.INTEGSERCON = 'E'
          AND PSS.NUMCONTRATO = :NEW.NUMCONTRATO
          AND PSS.CODPROD = SER.CODPROD
          AND PSS.SERIE = SER.SERIE;		  
		  
    END IF;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_SERIE" ENABLE;
