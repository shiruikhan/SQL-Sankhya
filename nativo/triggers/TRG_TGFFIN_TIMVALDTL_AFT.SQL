/*==============================================================================
  Nome do Script : TRG_TGFFIN_TIMVALDTL_AFT
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 01/07/2022 — referência)
  Descrição      : Trigger AFTER STATEMENT UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 01/07/2022, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_TIMVALDTL_AFT', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_TIMVALDTL_AFT" 
AFTER UPDATE
ON TGFFIN
DECLARE
    TYPE T_TIMVALDTL IS TABLE OF TIMVALDTL%ROWTYPE;
    L_TIMVALDTL T_TIMVALDTL;
    R_TGFFIN TGFFIN%ROWTYPE;
    R_TIMVALDTL TIMVALDTL%ROWTYPE;
    P_COUNT INT;
    P_SUM NUMBER(10,2);
    P_DESDOBRAMENTO NUMBER(10,2);
BEGIN
    
   IF STP_GET_ATUALIZANDO THEN
    RETURN;
   END IF; 

   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

     DELETE
    FROM TIMVALDTL D
    WHERE NOT EXISTS (
        SELECT 1
        FROM TGFFIN
        WHERE NUFIN = D.NUFIN
    );
   
    DELETE
    FROM TIMVALDTL D
    WHERE EXISTS (
        SELECT 1
        FROM TIM_BAIXA_CJMD C
        WHERE C.NUFIN = D.NUFIN
    );

    SELECT * BULK COLLECT INTO L_TIMVALDTL
    FROM TIMVALDTL
    WHERE PROCESSANDO = 'N';
    
    FOR IDX IN 1 .. L_TIMVALDTL.COUNT
    LOOP
        UPDATE TIMVALDTL
        SET PROCESSANDO = 'S'
        WHERE NUFIN = L_TIMVALDTL(IDX).NUFIN;
    END LOOP;
    
    FOR IDX IN 1 .. L_TIMVALDTL.COUNT
    LOOP
        
        R_TIMVALDTL := L_TIMVALDTL(IDX);
        
        SELECT * INTO R_TGFFIN
        FROM TGFFIN
        WHERE NUFIN = L_TIMVALDTL(IDX).NUFIN;
        
        IF R_TGFFIN.VLRJURO >= 0.01 THEN
            RAISE_APPLICATION_ERROR(-20201, 'Não é permitido informar o campo Vlr. Juro em títulos de aluguel.');
        END IF;
        
        IF R_TGFFIN.VLRMULTA >= 0.01 THEN
            RAISE_APPLICATION_ERROR(-20201, 'Não é permitido informar o campo Vlr. Multa em títulos de aluguel.');
        END IF;
        
        IF R_TGFFIN.VLRDESC >= 0.01 THEN
            RAISE_APPLICATION_ERROR(-20201, 'Não é permitido informar o campo Vlr. Desconto em títulos de aluguel.');
        END IF;
        
        IF ROUND(ABS(NVL(R_TIMVALDTL.OLD_VLRDESDOB,0) - NVL(R_TGFFIN.VLRDESDOB,0)),2) >= 0.01 THEN
            
            SELECT
                COUNT(*), ROUND(SUM(A.VLRDESDOB),2), ROUND(SUM(R_TGFFIN.VLRDESDOB),2)
                INTO P_COUNT, P_DESDOBRAMENTO, P_SUM
            FROM VIMALU A
            WHERE A.DTLPARCELA = R_TGFFIN.NUFIN
            AND ABS(ROUND(ABS(A.VLRDESDOB),2) - ROUND(R_TGFFIN.VLRDESDOB,2)) >= 0.01;

            IF P_COUNT > 0 THEN
                RAISE_APPLICATION_ERROR(-20201, 'O valor do campo Vlr. Desdobramento ('||P_DESDOBRAMENTO||') não pode ser diferente da soma de todos os detalhamentos da parcela ('||P_SUM||').');
            END IF;
        
        END IF;
        
    END LOOP;
    
    FOR IDX IN 1 .. L_TIMVALDTL.COUNT
    LOOP
        DELETE
        FROM TIMVALDTL
        WHERE NUFIN = L_TIMVALDTL(IDX).NUFIN;
    END LOOP;

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_TIMVALDTL_AFT" ENABLE;
