/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFFIN_DTPRAZO
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 03/07/2024 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 03/07/2024, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFFIN_DTPRAZO', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_DTPRAZO" 
   BEFORE INSERT OR UPDATE
   ON TGFFIN
   FOR EACH ROW
   DECLARE
    NVLDATE DATE;
BEGIN
   IF STP_GET_ATUALIZANDO THEN
      RETURN;
   END IF;

   NVLDATE := TO_DATE('1900/01/01', 'yyyy/mm/dd');

   IF NVL(:NEW.NURENEG,0) = 0  -- nao e titulo renegociado/renegociacao
      AND
      NVL(:NEW.DTPRAZO,NVLDATE) = NVL(:OLD.DTPRAZO,NVLDATE) -- nao transferindo vencimento 
      AND 
      NVL(:NEW.DTVENC,NVLDATE) <> NVL(:OLD.DTVENC,NVLDATE)  -- alterando vencimento
   THEN      
        :NEW.DTPRAZO := :NEW.DTVENC;
   END IF; 

   RETURN;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_DTPRAZO" ENABLE;
