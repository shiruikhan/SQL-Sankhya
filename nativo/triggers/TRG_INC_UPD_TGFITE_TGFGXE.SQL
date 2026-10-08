/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE_TGFGXE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW INSERT OR UPDATE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFITE_TGFGXE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE_TGFGXE" 
   AFTER INSERT OR UPDATE
   ON TGFITE
   FOR EACH ROW

DECLARE
   P_VALIDAR   BOOLEAN;
BEGIN
   P_VALIDAR := FPODEVALIDAR ('TGFITE');

   IF NOT (P_VALIDAR)
   THEN
      RETURN;
   END IF;

   IF INSERTING OR UPDATING (:NEW.CODPROD)
   THEN
      SNK_VAL_UTIL_PRODUTO_GENERICO (:NEW.NUNOTA, :NEW.CODPROD);
   END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE_TGFGXE" ENABLE;
