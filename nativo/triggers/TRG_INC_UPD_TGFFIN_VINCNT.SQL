/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFFIN_VINCNT
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFFIN_VINCNT', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_VINCNT" 
BEFORE INSERT OR UPDATE 
ON TGFFIN 
FOR EACH ROW
BEGIN
  IF NOT STP_GET_TIMUTILIZAIMOB THEN
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  IF UPDATING THEN
    IF :NEW.TIMCONTRATOLTV IS NOT NULL AND :NEW.TIMORIGEM = 'MF' AND :NEW.NUNOTA IS NULL AND :OLD.NUNOTA IS NOT NULL THEN
        :NEW.NUNOTA := :OLD.NUNOTA;
    END IF;
  END IF;
  IF :OLD.NUNOTA IS NOT NULL THEN
    :NEW.TIMNUNOTA := :OLD.NUNOTA;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_VINCNT" ENABLE;
