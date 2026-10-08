/*==============================================================================
  Nome do Script : TRG_UPT_TGFFIN_METAS
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPT_TGFFIN_METAS', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_METAS" AFTER UPDATE ON TGFFIN FOR EACH ROW
         WHEN (OLD.ORIGEM = 'F' AND
      ( OLD.RECDESP <> NEW.RECDESP OR 
       NVL(OLD.DHBAIXA, TRUNC(SYSDATE, 'YEAR')) <> NVL(NEW.DHBAIXA, TRUNC(SYSDATE, 'YEAR')) 
     )
      ) DECLARE
P_COUNT NUMBER(5);
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  IF :OLD.RECDESP = -1 AND :NEW.RECDESP = 1 THEN
    SELECT COUNT(1)
      INTO P_COUNT
    FROM TGMTRA 
    WHERE NUFIN = :OLD.NUFIN;
    
    IF P_COUNT > 0 THEN
      DELETE FROM TGMTRA 
      WHERE NUFIN = :OLD.NUFIN;
    END IF;
    
  ELSIF :NEW.DHBAIXA IS NOT NULL AND :OLD.DHBAIXA IS NULL THEN
    SELECT COUNT(1)
      INTO P_COUNT
    FROM TGMTRA 
    WHERE NUFIN = :OLD.NUFIN
        AND TIPO = 'C';
    
    IF P_COUNT > 0 THEN
      UPDATE TGMTRA SET VALOR = 0
      WHERE NUFIN = :OLD.NUFIN
        AND TIPO = 'C';
    END IF;
    
  ELSIF :NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL THEN
    SELECT COUNT(1)
      INTO P_COUNT
    FROM TGMTRA 
    WHERE NUFIN = :OLD.NUFIN
      AND TIPO = 'C';
    
    IF P_COUNT > 0 THEN
      UPDATE TGMTRA SET VALOR = :OLD.VLRBAIXA
      WHERE NUFIN = :OLD.NUFIN
        AND TIPO = 'C';
    END IF;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_METAS" ENABLE;
