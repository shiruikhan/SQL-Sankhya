/*==============================================================================
  Nome do Script : TRG_DLT_TGFITE_METAS
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFITE_METAS', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_METAS" 
AFTER DELETE ON TGFITE FOR EACH ROW
DECLARE P_COUNT   NUMBER(10);
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  SELECT COUNT(1) INTO P_COUNT
  FROM TGMTRA
  WHERE NUNOTA = :OLD.NUNOTA
    AND SEQUENCIAITE = :OLD.SEQUENCIA;
  IF P_COUNT > 0 THEN
    DELETE FROM TGMTRA 
    WHERE NUNOTA = :OLD.NUNOTA
      AND SEQUENCIAITE = :OLD.SEQUENCIA;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_METAS" ENABLE;
