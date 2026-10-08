/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFITE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE" 
BEFORE INSERT OR UPDATE ON TGFITE
FOR EACH ROW
DECLARE
  P_COUNT   NUMBER(5);
  P_VALIDAR BOOLEAN;
  P_NUPLAN  NUMBER(10);    
BEGIN


  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  P_VALIDAR := Fpodevalidar('TGFITE');
  IF (NOT P_VALIDAR) THEN
    RETURN;
  END IF;
  
  IF :OLD.CODVOL IS NULL OR :OLD.CODVOL <> :NEW.CODVOL THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TGFPRO
    WHERE CODPROD = :NEW.CODPROD
      AND CODVOL <> :NEW.CODVOL
      AND USOPROD <> 'S'
      AND NOT EXISTS(SELECT 1
                     FROM TGFVOA
                     WHERE CODPROD = :NEW.CODPROD
                       AND CODVOL  = :NEW.CODVOL);
             
    IF P_COUNT > 0 THEN
      RAISE_APPLICATION_ERROR(-20101, 'Volume: '||:NEW.CODVOL||' n?o cadastrado para o produto: '||TO_CHAR(:NEW.CODPROD));  
    END IF;  
  END IF;
  
  IF :OLD.STATUSNOTA = 'L' AND (NVL(:OLD.QTDNEG, 0) <> NVL(:NEW.QTDNEG, 0)) THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TGFCAB
    WHERE NUNOTA = :NEW.NUNOTA
      AND NVL(MODENTREGA, 'N') IN ('P', 'M', 'F')
      AND TIPMOV = 'P'
      AND EXISTS(SELECT 1
                 FROM TGFPLAN P
                 WHERE P.NUNOTAORIG = :NEW.NUNOTA
                   AND SITUACAO = 'A');
    IF P_COUNT > 0 THEN    
      SELECT P.NUPLAN INTO P_NUPLAN
      FROM TGFPLAN P
      WHERE P.NUNOTAORIG = :NEW.NUNOTA;
      Raise_Application_Error(-20101,'O pedido ' || :NEW.NUNOTA || ' n?o pode ser alterado pois esta relacionado ao planejamento ' || P_NUPLAN ||' que possui distribuic?o de itens.');    
    END IF;  
  END IF;  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE" ENABLE;
