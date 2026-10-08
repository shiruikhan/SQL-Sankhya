/*==============================================================================
  Nome do Script : TRG_DLT_TGFITE_TGFCUSITE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFITE_TGFCUSITE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_TGFCUSITE" 
BEFORE DELETE ON TGFITE FOR EACH ROW
DECLARE
    ERRMSG                     VARCHAR2(255);
    ERROR                      EXCEPTION;
    P_VALIDAR                  BOOLEAN;
    P_COUNT                    INT:= 0;
    
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  /* 
  sincronização de dados
  */
  P_VALIDAR := Fpodevalidar('TGFITE');
  -- OS 916248
  BEGIN
      SELECT COUNT(*) INTO P_COUNT 
      FROM TGFCUSITE 
      WHERE NUNOTA = :OLD.NUNOTA
      AND SEQUENCIA = :OLD.SEQUENCIA;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_COUNT := 0;
  END;

  IF P_COUNT > 0 THEN 
      DELETE FROM TGFCUSITE 
      WHERE NUNOTA = :OLD.NUNOTA
      AND SEQUENCIA = :OLD.SEQUENCIA;
  END IF; 
  -- OS 916248

EXCEPTION
  WHEN ERROR THEN
    IF (P_VALIDAR) THEN 
      RAISE_APPLICATION_ERROR(-20101, ERRMSG);
    END IF; 
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_TGFCUSITE" ENABLE;
