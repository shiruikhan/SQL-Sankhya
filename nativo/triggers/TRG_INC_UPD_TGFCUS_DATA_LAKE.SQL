/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFCUS_DATA_LAKE
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 19/09/2025 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFCUS.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 19/09/2025, última alteração em 19/09/2025.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFCUS_DATA_LAKE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCUS_DATA_LAKE" 
BEFORE INSERT OR UPDATE ON TGFCUS
FOR EACH ROW
BEGIN
	:NEW.DHALTER := SYSTIMESTAMP;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCUS_DATA_LAKE" ENABLE;
