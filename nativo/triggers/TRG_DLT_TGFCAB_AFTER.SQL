/*==============================================================================
  Nome do Script : TRG_DLT_TGFCAB_AFTER
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 19/09/2025 — referência)
  Descrição      : Trigger AFTER STATEMENT DELETE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 19/09/2025, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFCAB_AFTER', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFCAB_AFTER" 
AFTER DELETE ON TGFCAB
DECLARE
  P_LOOPINDEX         BINARY_INTEGER;
  P_NUNOTA            TGFCAB.NUNOTA%TYPE;
  CURSOR NOTAS IS SELECT DISTINCT NUNOTA FROM TGFCAB_DLT;
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  OPEN NOTAS;
  LOOP
    FETCH NOTAS INTO P_NUNOTA;
    EXIT WHEN NOTAS%NOTFOUND;
    DELETE FROM TGFITE WHERE NUNOTA = P_NUNOTA;
  END LOOP;
  CLOSE NOTAS;

  DELETE FROM TGFCAB_DLT;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFCAB_AFTER" ENABLE;
