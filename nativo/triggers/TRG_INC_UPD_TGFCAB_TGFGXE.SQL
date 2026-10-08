/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFCAB_TGFGXE
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 01/07/2022 — referência)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 01/07/2022, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFCAB_TGFGXE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCAB_TGFGXE" 
   AFTER UPDATE
   ON TGFCAB
   FOR EACH ROW
    WHEN (NEW.CODTIPOPER <> OLD.CODTIPOPER OR NEW.DHTIPOPER <> OLD.DHTIPOPER) DECLARE
   P_COUNT   NUMBER (05);
BEGIN

   IF STP_GET_ATUALIZANDO THEN 
     RETURN;
   END IF;

   SELECT COUNT (1)
     INTO P_COUNT
     FROM TGFTOP T
    WHERE     T.CODTIPOPER = :NEW.CODTIPOPER
          AND T.DHALTER = :NEW.DHTIPOPER
          AND T.ATUALLIVFIS <> 'N'
          AND EXISTS
                 (SELECT 1
                    FROM TGFTOP TOLD
                   WHERE     TOLD.CODTIPOPER = :OLD.CODTIPOPER
                         AND TOLD.DHALTER = :OLD.DHTIPOPER
                         AND T.ATUALLIVFIS <> TOLD.ATUALLIVFIS);

   IF P_COUNT > 0
   THEN
      SNK_VAL_UTIL_PRODUTO_GENERICO (:NEW.NUNOTA);
   END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCAB_TGFGXE" ENABLE;
