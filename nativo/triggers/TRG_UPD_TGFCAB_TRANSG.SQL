/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_TRANSG
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_TRANSG', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_TRANSG" 
BEFORE UPDATE ON TGFCAB 
FOR EACH ROW
      WHEN ( OLD.DTNEG <> NEW.DTNEG OR OLD.NUMNOTA <> NEW.NUMNOTA OR 
       OLD.CODPARC <> NEW.CODPARC OR OLD.CODTIPOPER <> NEW.CODTIPOPER OR OLD.DHTIPOPER <> NEW.DHTIPOPER OR OLD.NUMCONTRATO <> NEW.NUMCONTRATO
      ) DECLARE
  P_COUNT INT;
  P_VALIDAR BOOLEAN;
BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_TRANSG = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  P_VALIDAR := Fpodevalidar('TGFCAB');
  IF (NOT P_VALIDAR) THEN
    RETURN;
  END IF;
  
  SELECT COUNT(*)
  INTO P_COUNT
  FROM TGAGTM
  WHERE NUNOTA = :NEW.NUNOTA;
  IF P_COUNT > 0 THEN
    IF :OLD.CODPARC <> :NEW.CODPARC OR 
       :OLD.CODTIPOPER <> :NEW.CODTIPOPER OR 
       :OLD.DHTIPOPER <> :NEW.DHTIPOPER OR 
       :OLD.NUMCONTRATO <> :NEW.NUMCONTRATO THEN
      RAISE_APPLICATION_ERROR(-20101, 'Parceiro, TOP e Contrato não podem ser alterados em notas com produtos transgênicos. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.');
    END IF;
    UPDATE TGAGTM SET
      DTNEG = :NEW.DTNEG
    , NUMNOTA = :NEW.NUMNOTA
    WHERE NUNOTA = :NEW.NUNOTA;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_TRANSG" ENABLE;
