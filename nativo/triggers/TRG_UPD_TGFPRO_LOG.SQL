/*==============================================================================
  Nome do Script : TRG_UPD_TGFPRO_LOG
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFPRO_LOG', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFPRO_LOG" 
BEFORE INSERT OR UPDATE 
ON TGFPRO 
FOR EACH ROW
         WHEN ((OLD.DESCRPROD IS NULL) OR
      (NEW.DESCRPROD <> OLD.DESCRPROD) OR
      (NEW.PRODUTONFE <> OLD.PRODUTONFE) OR
      (NVL(NEW.DESCRPRODNFE, ' ') <> NVL(OLD.DESCRPRODNFE, ' ')) OR
      (NVL(NEW.REFERENCIA, ' ') <> NVL(OLD.REFERENCIA, ' ')) 
     ) DECLARE 
  P_ACAO VARCHAR2(10); 
  P_CHAVEPK VARCHAR(400);
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  P_CHAVEPK := :NEW.CODPROD;
  IF INSERTING THEN
    IF (:NEW.DESCRPRODNFE IS NOT NULL) THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'DESCRPROD', :NEW.DESCRPRODNFE);      
    ELSIF (:NEW.DESCRPROD IS NOT NULL) THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'DESCRPROD', :NEW.DESCRPROD);
    END IF;    
    IF (:NEW.PRODUTONFE IS NOT NULL) THEN    
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'PRODUTONFE', :NEW.PRODUTONFE);
    END IF;
    IF (:NEW.PRODUTONFE = 1 AND NVL(:NEW.REFERENCIA,' ') <> ' ') THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'REFERENCIA', :NEW.REFERENCIA);
    END IF;        
  ELSE
    IF ((NVL(:OLD.DESCRPRODNFE,'null')) <> (NVL(:NEW.DESCRPRODNFE,'null'))) THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'DESCRPROD', :NEW.DESCRPRODNFE);
    ELSIF ((NVL(:OLD.DESCRPROD,'null')) <> (NVL(:NEW.DESCRPROD,'null'))) AND NVL(:OLD.DESCRPRODNFE,'null') = 'null' THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'DESCRPROD', :NEW.DESCRPROD);
    END IF;
    IF ((NVL(:OLD.PRODUTONFE,0)) <> (NVL(:NEW.PRODUTONFE,0))) THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'PRODUTONFE', :NEW.PRODUTONFE);
    END IF;
     IF ( (NVL(:OLD.PRODUTONFE,0) = 0 AND NVL(:NEW.PRODUTONFE,0) = 1) OR
          (NVL(:NEW.PRODUTONFE,0) = 1 AND NVL(:NEW.REFERENCIA,'null') <> NVL(:OLD.REFERENCIA,'null'))) AND
        NVL(:NEW.REFERENCIA,'null') <> 'null' THEN
      STP_LOGTSIALT('TGFPRO', P_CHAVEPK,'REFERENCIA', :NEW.REFERENCIA);
    END IF;    
  END IF;            
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFPRO_LOG" ENABLE;
