/*==============================================================================
  Nome do Script : TRG_UPD_TGFPRO_TGFVOA
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 24/02/2023)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 24/02/2023, última alteração em 08/01/2025.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFPRO_TGFVOA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFPRO_TGFVOA" 
AFTER UPDATE 
ON TGFPRO
FOR EACH ROW
DECLARE
   ERRMSG           VARCHAR2(255);
   ERROR            EXCEPTION;
   P_VALIDAR        BOOLEAN;
   P_COUNT          NUMBER(5);
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  /* 
   Sincronização de dados
  */
  P_VALIDAR := FPODEVALIDAR('TGFPRO');
  
  IF :NEW.CODVOLCOMPRA IS NOT NULL AND 
     :NEW.CODVOL <> :OLD.CODVOL AND 
     :OLD.CODVOLCOMPRA = :OLD.CODVOL AND 
     :NEW.CODVOLCOMPRA <> :NEW.CODVOL AND 
	 :NEW.USOPROD <> 'S' THEN   
    SELECT COUNT(1)
    INTO P_COUNT
    FROM TGFVOA
    WHERE CODPROD = :NEW.CODPROD
    AND CODVOL = :NEW.CODVOLCOMPRA;
    
    IF P_COUNT = 0 THEN
      ERRMSG := 'A unidade padrão não pode ser alterada. A unidade de compra é igual a ela e não há uma unidade alternativa igual a unidade de compra.';
      RAISE ERROR;
    END IF;
  END IF;
  
  RETURN;
EXCEPTION
  WHEN ERROR THEN
    /* 
    Sincronização de dados não faz validações
    */
    IF (P_VALIDAR) THEN 
      RAISE_APPLICATION_ERROR(-20101, ERRMSG);
    END IF; 
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFPRO_TGFVOA" ENABLE;
