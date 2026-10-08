/*==============================================================================
  Nome do Script : TRG_TGFFIN_DLT_TIMFK
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: DISABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_DLT_TIMFK', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_DLT_TIMFK" 
BEFORE DELETE
ON TGFFIN
FOR EACH ROW
DECLARE
    P_COUNT INT;
    P_VALIDAR BOOLEAN;
    P_ERRMSG VARCHAR(255);
    ERROR EXCEPTION;
BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;

    P_VALIDAR := FPODEVALIDAR('TGFFIN');


    INSERT INTO TGFFIN_DLT_TIMFK (NUFIN)
    SELECT :OLD.NUFIN
    FROM DUAL
    WHERE NOT EXISTS (
        SELECT 1
        FROM TGFFIN_DLT_TIMFK
        WHERE NUFIN = :OLD.NUFIN
    );


EXCEPTION
WHEN ERROR THEN
    IF P_VALIDAR THEN
        RAISE_APPLICATION_ERROR(-20201, P_ERRMSG);
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_DLT_TIMFK" DISABLE;
