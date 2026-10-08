/*==============================================================================
  Nome do Script : TRG_INC_UPT_TGFPRO_MARCA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPT_TGFPRO_MARCA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFPRO_MARCA" 
BEFORE INSERT OR UPDATE ON TGFPRO
FOR EACH ROW
      WHEN (NVL(OLD.MARCA, ' ') <> NVL(NEW.MARCA, ' ')) BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  IF NVL(TRIM(:NEW.MARCA), ' ') = ' ' THEN
       :NEW.CODMARCA := NULL;
  ELSIF NOT UPDATING('CODMARCA') THEN
    BEGIN
      SELECT MAX(CODIGO)
      INTO :NEW.CODMARCA
      FROM TGFMAR
      WHERE DESCRICAO = :NEW.MARCA;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        :NEW.CODMARCA := NULL;
    END;
  END IF;
  
  RETURN;
   
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFPRO_MARCA" ENABLE;
