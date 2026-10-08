/*==============================================================================
  Nome do Script : TRG_TGFCAB_INC_UPD_VINCNT
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 01/07/2022 — referência)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 01/07/2022, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFCAB_INC_UPD_VINCNT', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFCAB_INC_UPD_VINCNT" 
AFTER UPDATE
ON TGFCAB
FOR EACH ROW
BEGIN

   IF STP_GET_ATUALIZANDO THEN 
     RETURN;
   END IF;

   IF NOT STP_GET_TIMUTILIZAIMOB
   THEN
      RETURN;
   END IF;

    IF :NEW.TIMORIGEM IS NOT NULL AND :NEW.TIMCONTRATOLTV IS NOT NULL THEN
        UPDATE TGFFIN
        SET TIMORIGEM = :NEW.TIMORIGEM,
            TIMCONTRATOLTV = :NEW.TIMCONTRATOLTV
        WHERE NUNOTA = :NEW.NUNOTA
        AND TIMORIGEM IS NULL
        AND TIMCONTRATOLTV IS NULL;
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFCAB_INC_UPD_VINCNT" ENABLE;
