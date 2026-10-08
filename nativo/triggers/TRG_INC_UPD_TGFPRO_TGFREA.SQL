/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFPRO_TGFREA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFPRO_TGFREA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPRO_TGFREA" 
BEFORE INSERT OR UPDATE ON TGFPRO 
FOR EACH ROW
DECLARE 
	P_COUNT		NUMBER(10);
	
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

	IF :NEW.NUMITEMREA IS NOT NULL THEN
		SELECT COUNT(1) INTO P_COUNT
		  FROM TGFREA
		 WHERE NUMITEMREA = :NEW.NUMITEMREA;

		IF ((P_COUNT =  0) OR (P_COUNT IS NULL)) THEN
			RAISE_APPLICATION_ERROR(-20101,'N?o existe referencia para esse registro.');
		END IF;
	END IF;	
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPRO_TGFREA" ENABLE;
