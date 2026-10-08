/*==============================================================================
  Nome do Script : TRG_TGFCAB_INC_UPD_AFT_TIMFK
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER STATEMENT INSERT OR UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 26/08/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFCAB_INC_UPD_AFT_TIMFK', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFCAB_INC_UPD_AFT_TIMFK" 
AFTER INSERT OR UPDATE
ON TGFCAB
DECLARE
    P_COUNT INT;
    P_ERRMSG VARCHAR(255);
    ERROR EXCEPTION;
    
    TYPE OLD_TGFCAB_TYPE IS TABLE OF TGFCAB_INC_UPD_TIMFK%ROWTYPE INDEX BY PLS_INTEGER;
    OLD_TGFCAB_LIST OLD_TGFCAB_TYPE;
    
    OLD_CAB TGFCAB_INC_UPD_TIMFK%ROWTYPE;
    NEW_CAB TGFCAB%ROWTYPE;
BEGIN

  IF STP_GET_ATUALIZANDO THEN 
    RETURN;
  END IF;

  IF NOT STP_GET_TIMUTILIZAIMOB THEN
    RETURN;
  END IF;

    DELETE
    FROM TGFCAB_INC_UPD_TIMFK IU
    WHERE NOT EXISTS (
        SELECT 1
        FROM TGFCAB
        WHERE NUNOTA = IU.NUNOTA
    );
    
    SELECT * BULK COLLECT INTO OLD_TGFCAB_LIST
    FROM TGFCAB_INC_UPD_TIMFK
    WHERE PROCESSANDO = 'N';
    
    FOR I IN 1..OLD_TGFCAB_LIST.COUNT
    LOOP
        UPDATE TGFCAB_INC_UPD_TIMFK
        SET PROCESSANDO = 'S'
        WHERE NUNOTA = OLD_TGFCAB_LIST(I).NUNOTA;
    END LOOP;
    
    FOR I IN 1..OLD_TGFCAB_LIST.COUNT
    LOOP
        OLD_CAB := OLD_TGFCAB_LIST(I);
        
        SELECT * INTO NEW_CAB
        FROM TGFCAB
        WHERE NUNOTA = OLD_CAB.NUNOTA;
        
        
        IF (OLD_CAB.TIMCONTRATOLTV IS NULL AND NEW_CAB.TIMCONTRATOLTV IS NOT NULL) OR (OLD_CAB.TIMCONTRATOLTV != NEW_CAB.TIMCONTRATOLTV) THEN
            SELECT COUNT(*) INTO P_COUNT
            FROM TIMLTV
            WHERE LTVCODIGO = NEW_CAB.TIMCONTRATOLTV;
    
            IF P_COUNT = 0 THEN
                P_ERRMSG := 'O campo ""'||FIELD_LABEL('TGFCAB','TIMCONTRATOLTV')||'"" não possui valor válido.';
                RAISE ERROR;
            END IF;
        END IF;
        IF (OLD_CAB.TIMCONTRATOVENDA IS NULL AND NEW_CAB.TIMCONTRATOVENDA IS NOT NULL) OR (OLD_CAB.TIMCONTRATOVENDA != NEW_CAB.TIMCONTRATOVENDA) THEN
            SELECT COUNT(*) INTO P_COUNT
            FROM TIMCLA
            WHERE CLACODIGO = NEW_CAB.TIMCONTRATOVENDA;
    
            IF P_COUNT = 0 THEN
                P_ERRMSG := 'O campo ""'||FIELD_LABEL('TGFCAB','TIMCONTRATOVENDA')||'"" não possui valor válido.';
                RAISE ERROR;
            END IF;
        END IF;
        IF (OLD_CAB.TIMNUFINORIG IS NULL AND NEW_CAB.TIMNUFINORIG IS NOT NULL) OR (OLD_CAB.TIMNUFINORIG != NEW_CAB.TIMNUFINORIG) THEN
            SELECT COUNT(*) INTO P_COUNT
            FROM TGFFIN
            WHERE NUFIN = NEW_CAB.TIMNUFINORIG;
    
            IF P_COUNT = 0 THEN
                P_ERRMSG := 'O campo ""'||FIELD_LABEL('TGFCAB','TIMNUFINORIG')||'"" não possui valor válido.';
                RAISE ERROR;
            END IF;
        END IF;
        
    END LOOP;
    
    
    FOR I IN 1..OLD_TGFCAB_LIST.COUNT
    LOOP
        DELETE
        FROM TGFCAB_INC_UPD_TIMFK
        WHERE NUNOTA = OLD_TGFCAB_LIST(I).NUNOTA;
    END LOOP;

EXCEPTION
WHEN ERROR THEN
    RAISE_APPLICATION_ERROR(-20201, P_ERRMSG);
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFCAB_INC_UPD_AFT_TIMFK" ENABLE;
