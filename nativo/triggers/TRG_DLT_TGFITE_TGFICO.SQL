/*==============================================================================
  Nome do Script : TRG_DLT_TGFITE_TGFICO
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/02/2022.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFITE_TGFICO', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_TGFICO" 
BEFORE DELETE ON TGFITE FOR EACH ROW
DECLARE  P_COUNT INT;
                P_NUNOTACO NUMBER(10);
                PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  BEGIN
    SELECT COUNT(1), NVL(NUNOTACO, 0)
      INTO P_COUNT , P_NUNOTACO
    FROM TGFICO ICO
    WHERE ICO.NUNOTAPO = :OLD.NUNOTA
      AND ICO.SEQUENCIAPO = :OLD.SEQUENCIA
    GROUP BY NUNOTACO;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    P_COUNT := 0;
  END;
    
  IF P_COUNT > 0 THEN
    RAISE_APPLICATION_ERROR(-20101,'E necessario excluir o Pedido Confirmed Order (C.O) ('||P_NUNOTACO||') vinculado.');
  END IF;     
  
  COMMIT;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFITE_TGFICO" ENABLE;
