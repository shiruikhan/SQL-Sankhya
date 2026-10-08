/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFEST_ROUND
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 06/09/2023)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 06/09/2023, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFEST_ROUND', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFEST_ROUND" 
BEFORE INSERT OR UPDATE ON TGFEST 
FOR EACH ROW
 WHEN ((NVL(NEW.RESERVADO, 0) <> NVL(OLD.RESERVADO, 0)) OR (NVL(NEW.ESTOQUE, 0) <> NVL(OLD.ESTOQUE, 0))) BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  -- OS 717072
  IF (NVL(:NEW.RESERVADO,0) <> NVL(:OLD.RESERVADO,0)) THEN
    :NEW.RESERVADO := ROUND(:NEW.RESERVADO, 9);
  END IF; 

  IF (NVL(:NEW.ESTOQUE,0) <> NVL(:OLD.ESTOQUE,0)) THEN
    :NEW.ESTOQUE := ROUND(:NEW.ESTOQUE, 9);
  END IF; 
  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFEST_ROUND" ENABLE;
