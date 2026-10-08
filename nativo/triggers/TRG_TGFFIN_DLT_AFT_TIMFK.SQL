/*==============================================================================
  Nome do Script : TRG_TGFFIN_DLT_AFT_TIMFK
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 01/07/2022 — referência)
  Descrição      : Trigger AFTER STATEMENT DELETE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 01/07/2022, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_DLT_AFT_TIMFK', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_DLT_AFT_TIMFK" 
AFTER DELETE
ON TGFFIN
DECLARE
    P_COUNT INT;
    P_ERRMSG VARCHAR(255);
    ERROR EXCEPTION;

    TYPE OLD_TGFFIN_TYPE IS TABLE OF TGFFIN_DLT_TIMFK%ROWTYPE INDEX BY PLS_INTEGER;
    OLD_TGFFIN_LIST OLD_TGFFIN_TYPE;

    OLD_FIN TGFFIN_DLT_TIMFK%ROWTYPE;
BEGIN

   IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

   IF NOT STP_GET_TIMUTILIZAIMOB
   THEN
      RETURN;
   END IF;

    DELETE
    FROM TGFFIN_DLT_TIMFK DLT
    WHERE NOT EXISTS (
        SELECT 1
        FROM TGFFIN
        WHERE NUFIN = DLT.NUFIN
    );

    SELECT * BULK COLLECT INTO OLD_TGFFIN_LIST
    FROM TGFFIN_DLT_TIMFK
    WHERE PROCESSANDO = 'N';

    FOR I IN 1..OLD_TGFFIN_LIST.COUNT
    LOOP
        UPDATE TGFFIN_DLT_TIMFK
        SET PROCESSANDO = 'S'
        WHERE NUFIN = OLD_TGFFIN_LIST(I).NUFIN;
    END LOOP;


    FOR I IN 1..OLD_TGFFIN_LIST.COUNT
    LOOP
        OLD_FIN := OLD_TGFFIN_LIST(I);


        SELECT COUNT(*) INTO P_COUNT
        FROM TGFFIN
        WHERE TIMFINGARANTORIG = OLD_FIN.NUFIN;

        IF P_COUNT > 0 THEN
            P_ERRMSG := 'Este registro PK[NUFIN='||TO_CHAR(OLD_FIN.NUFIN)||'] não pode ser excluído, pois está sendo usado em outro cadastro.';
            RAISE ERROR;
        END IF;

        SELECT COUNT(*) INTO P_COUNT
        FROM TGFFIN
        WHERE TIMNUFINORIG = OLD_FIN.NUFIN;

        IF P_COUNT > 0 THEN
            P_ERRMSG := 'Este registro PK[NUFIN='||TO_CHAR(OLD_FIN.NUFIN)||'] não pode ser excluído, pois está sendo usado em outro cadastro.';
            RAISE ERROR;
        END IF;

        SELECT COUNT(*) INTO P_COUNT
        FROM TGFCAB
        WHERE TIMNUFINORIG = OLD_FIN.NUFIN;

        IF P_COUNT > 0 THEN
            P_ERRMSG := 'Este registro PK[NUFIN='||TO_CHAR(OLD_FIN.NUFIN)||'] não pode ser excluído, pois está sendo usado em outro cadastro.';
            RAISE ERROR;
        END IF;

    END LOOP;


    FOR I IN 1..OLD_TGFFIN_LIST.COUNT
    LOOP
        DELETE
        FROM TGFFIN_DLT_TIMFK
        WHERE NUFIN = OLD_TGFFIN_LIST(I).NUFIN;
    END LOOP;    

EXCEPTION
WHEN ERROR THEN
    RAISE_APPLICATION_ERROR(-20201, P_ERRMSG);
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_DLT_AFT_TIMFK" ENABLE;
