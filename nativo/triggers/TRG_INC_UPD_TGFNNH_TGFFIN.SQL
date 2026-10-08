/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFNNH_TGFFIN
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFNNH_TGFFIN', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFNNH_TGFFIN" 
BEFORE INSERT OR UPDATE ON TGFFIN  
FOR EACH ROW
DECLARE
  P_COUNT           INT := 0;
  ERRMSG            VARCHAR2(4000);
  ERROR             EXCEPTION;
  P_VALIDAR         BOOLEAN;
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  /* sincronização de dados */
  P_VALIDAR := Fpodevalidar('TGFFIN');
  
  IF (:NEW.RECDESP <> 1 
      OR :NEW.LINHADIGITAVEL IS NULL 
      OR :NEW.CODIGOBARRA IS NULL
      OR :NEW.NOSSONUM IS NULL) THEN
    RETURN;
  END IF;

  -- se for alteração
IF (UPDATING
     AND NVL(:NEW.NOSSONUM, '0') = NVL(:OLD.NOSSONUM, '0')
     AND NVL(:NEW.CODIGOBARRA, '0') = NVL(:OLD.CODIGOBARRA, '0')
     AND NVL(:NEW.LINHADIGITAVEL, '0') = NVL(:OLD.LINHADIGITAVEL, '0')
     AND NVL(:NEW.RECDESP, 0) = NVL(:OLD.RECDESP, 0)) THEN
   RETURN;
 END IF;
 
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFNNH 
  WHERE CODCTABCOINT = :NEW.CODCTABCOINT 
    AND CODPARC <> :NEW.CODPARC 
    AND NOSSONUM = :NEW.NOSSONUM;
  IF P_COUNT > 0 THEN
     ERRMSG := 'O nosso numero gerado ja foi usado para outro parceiro: nosso nro=' || :NEW.NOSSONUM || ', conta: ' || TO_CHAR(:NEW.CODCTABCOINT, '99999');
     RAISE ERROR;      
  END IF;    
   
    -- se já existe a linha na tgfnnh, retorna e não grava
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFNNH 
  WHERE CODCTABCOINT = :NEW.CODCTABCOINT 
    AND CODPARC = :NEW.CODPARC 
    AND NOSSONUM = :NEW.NOSSONUM;
  IF P_COUNT > 0 THEN
     RETURN;
  END IF;    

  INSERT INTO TGFNNH(CODCTABCOINT
  , CODPARC
  , NUFIN
  , NOSSONUM
  , CODUSU
  , DHALTER)VALUES(:NEW.CODCTABCOINT
  , :NEW.CODPARC
  , :NEW.NUFIN
  , :NEW.NOSSONUM
  , Tsiusu_Log_Pkg.V_CODUSULOG
  , SYSDATE);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    /*
    Sincronização de dados não faz validações
    */
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFNNH_TGFFIN" ENABLE;
