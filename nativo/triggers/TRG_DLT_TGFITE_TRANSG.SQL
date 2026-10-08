/*==============================================================================
  Nome do Script : TRG_DLT_TGFITE_TRANSG
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/02/2022.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFITE_TRANSG', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_TRANSG" 
AFTER DELETE ON TGFITE 
FOR EACH ROW
      WHEN ( OLD.GRUPOTRANSG IS NOT NULL ) DECLARE
P_COUNT     NUMBER(05);
BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_TRANSG = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  DELETE FROM TGAGTM WHERE NUNOTA = :OLD.NUNOTA AND SEQUENCIA = :OLD.SEQUENCIA;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_TRANSG" ENABLE;
