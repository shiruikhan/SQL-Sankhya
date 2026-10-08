/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFCUS
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFCUS.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFCUS', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCUS" 
BEFORE INSERT OR UPDATE ON TGFCUS
FOR EACH ROW
BEGIN
    
  IF (VARIAVEIS_PKG.V_PROCESSO_ATUAL_CUSTO IS NOT NULL) THEN
    :NEW.PROCESSO := VARIAVEIS_PKG.V_PROCESSO_ATUAL_CUSTO;
  END IF;
  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCUS" ENABLE;
