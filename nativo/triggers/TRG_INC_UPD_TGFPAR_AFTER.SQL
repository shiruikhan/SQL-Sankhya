/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFPAR_AFTER
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW INSERT OR UPDATE sobre TGFPAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 12/01/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFPAR_AFTER', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPAR_AFTER" 
   AFTER UPDATE OR INSERT
   ON TGFPAR
   FOR EACH ROW
      WHEN (
NVL(NEW.PERMITECORTE, 'N') <> NVL(OLD.PERMITECORTE, 'N')
      ) DECLARE
   P_COUNT   INT;
   
   PRAGMA AUTONOMOUS_TRANSACTION;
   
BEGIN

   SELECT COUNT(*) INTO P_COUNT FROM TGFPAR WHERE PERMITECORTE <> 'N';
   IF :NEW.PERMITECORTE <> 'N' OR P_COUNT > 0 THEN
      UPDATE TSIVARBD SET UTILIZA_VERIFCORTE = 'S';
   ELSE 
      UPDATE TSIVARBD SET UTILIZA_VERIFCORTE = 'N';
   END IF;
   COMMIT;

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPAR_AFTER" ENABLE;
