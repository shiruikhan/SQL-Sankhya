/*==============================================================================
  Nome do Script : TRG_INC_UPD_DLT_TGFPRO_SUBST
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW INSERT OR UPDATE OR DELETE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_DLT_TGFPRO_SUBST', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFPRO_SUBST" 
  AFTER INSERT OR UPDATE OR DELETE
  ON TGFPRO FOR EACH ROW
DECLARE
  P_COUNT     NUMBER(10);
  ERRMSG      VARCHAR2(500);
  ERROR       EXCEPTION;
  P_VALIDAR   BOOLEAN;  
  
  PRAGMA AUTONOMOUS_TRANSACTION;
  
  
            
BEGIN

    SELECT COUNT(*) INTO P_COUNT
    FROM TSIPAR 
    WHERE CHAVE = 'PERCADPRODSUBST';
    IF P_COUNT = 0 THEN
        RETURN;
    ELSE
        P_COUNT := 0;
        SELECT COUNT(*) INTO P_COUNT
        FROM TSIPAR
        WHERE CHAVE = 'PERCADPRODSUBST'
          AND LOGICO = 'S';
        IF P_COUNT = 0 THEN
            RETURN;
        END IF;
    END IF;
     
    

    IF STP_GET_ATUALIZANDO THEN
    RETURN;
    END IF;
    
    --sincronizac?o de dados
    P_VALIDAR := Fpodevalidar('TGFPRO');  
    --Sincronizac?o de dados n?o faz validac?es
    IF NOT P_VALIDAR THEN
      RETURN;
    END IF;
    
    --Um produto n?o pode ser substituto de si mesmo
    IF :NEW.CODPRODSUBST = :NEW.CODPROD THEN
      RAISE_APPLICATION_ERROR(-20101, 'Um produto n?o pode ser substituto de si mesmo.');
    END IF;
    
    --N?o existe inclus?o de produto com substituto ja definido!
    IF INSERTING AND (:NEW.CODPRODSUBST IS NOT NULL) THEN
       RAISE_APPLICATION_ERROR(-20101, 'Um produto que esta sendo criado n?o deve possuir um substituto.');
    END IF;
    
    --N?o existe inclus?o de produto com data de substituic?o ja definida!
    IF INSERTING AND (:NEW.DTSUBST IS NOT NULL) THEN
       RAISE_APPLICATION_ERROR(-20101, 'Um produto que esta sendo criado n?o deve possuir data de substituic?o.');
    END IF;
        
    --Um produto que n?o existe n?o pode ser inserido como substituto de outro
    IF UPDATING('CODPRODSUBST') AND :NEW.CODPRODSUBST IS NOT NULL THEN
       SELECT COUNT(1) INTO P_COUNT
              FROM TGFPRO
              WHERE CODPROD = :NEW.CODPRODSUBST;
       IF (P_COUNT = 0) THEN
          RAISE_APPLICATION_ERROR(-20101, 'O produto que esta sendo colocado como substituto n?o existe.');
       END IF;
     END IF;
     
    --Se colocar um SUBSTITUTO deve colocar a DTSUBST e vice versa
    IF (:NEW.CODPRODSUBST IS NOT NULL AND :NEW.DTSUBST IS NULL) OR (:NEW.DTSUBST IS NOT NULL AND :NEW.CODPRODSUBST IS NULL) THEN
       RAISE_APPLICATION_ERROR(-20101, 'Se existe um produto Substituto e necessaria uma Data de Substituic?o e vice versa.');
    END IF;
    
    --DELETE REGISTROS DA TGFPAL QUE PERDERAM A LIGAC?O
    IF UPDATING AND NVL(:NEW.CODPRODSUBST, 0) <> NVL(:OLD.CODPRODSUBST, 0) THEN
       DELETE FROM TGFPAL WHERE CODPROD = :NEW.CODPROD AND CODPRODALT <> :NEW.CODPRODSUBST;
    END IF;
    
    --DELETE REGISTROS DA TGFPAL QUANDO APAGA PRODUTO SUBSTITUTO NA TGFPRO
    IF UPDATING AND :OLD.CODPRODSUBST IS NOT NULL AND :NEW.CODPRODSUBST IS NULL THEN
       DELETE FROM TGFPAL WHERE CODPROD = :NEW.CODPROD;
    END IF;
    
    --Chama a procedure para executar a substituic?o recursiva
    IF NVL(:NEW.CODPRODSUBST, 0) <> 0 AND (NVL(:OLD.CODPRODSUBST, 0) <> NVL(:NEW.CODPRODSUBST, 0) OR  NVL(:OLD.DTSUBST, '01/01/1900') <> NVL(:NEW.DTSUBST, '01/01/1900')) THEN 
        STP_PRODALTERNATIVO(:NEW.CODPROD, :NEW.CODPRODSUBST, :OLD.CODPRODSUBST, :NEW.DTSUBST);
    END IF;
    
  COMMIT;
  
  RETURN;
EXCEPTION
  WHEN ERROR THEN
  /* 
  Sincronizac?o de dados n?o faz validac?es
  */
  IF (P_VALIDAR) THEN 
    RAISE_APPLICATION_ERROR(-20101, ERRMSG);
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFPRO_SUBST" ENABLE;
