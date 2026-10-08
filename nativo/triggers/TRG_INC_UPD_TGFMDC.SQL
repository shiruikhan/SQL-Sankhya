/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFMDC
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFMDC.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFMDC', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFMDC" 
BEFORE INSERT OR UPDATE ON TGFMDC
FOR EACH ROW
DECLARE
  P_COUNT INTEGER; 
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  IF ((INSERTING OR (UPDATING('CODTIPTIT'))) AND (:NEW.CODTIPTIT IS NOT NULL)) THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TGFTIT
    WHERE CODTIPTIT = :NEW.CODTIPTIT
    AND ATIVO = 'N';
    IF (P_COUNT > 0) THEN 
      RAISE_APPLICATION_ERROR(-20101, 'Tipo de Titulo de receita n?o esta ativo. ');
    END IF;
              END IF;              

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFMDC" ENABLE;
