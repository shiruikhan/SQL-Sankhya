/*==============================================================================
  Nome do Script : TRG_INC_UPT_TGFEST_BAR_TRANSF
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPT_TGFEST_BAR_TRANSF', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFEST_BAR_TRANSF" 
BEFORE INSERT OR UPDATE ON TGFEST
FOR EACH ROW
    WHEN (NEW.CODBARRA IS NULL) DECLARE 
  P_COUNT             NUMBER(5);
  P_CODPROD           TGFEST.CODPROD%TYPE;
  P_CONTROLE          TGFEST.CONTROLE%TYPE;
  P_CODBARRA          TGFEST.CODBARRA%TYPE;
  PRAGMA AUTONOMOUS_TRANSACTION;
  ERRMSG              VARCHAR2(4000);
  ERROR               EXCEPTION;
  P_VALIDAR           BOOLEAN;
  P_TIPCONTEST		  TGFPRO.TIPCONTEST%TYPE;
  
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  P_VALIDAR := Fpodevalidar('TGFEST'); -- sincronização de dados
  

  SELECT COUNT(1) INTO P_COUNT 
  FROM TSIPAR 
  WHERE CHAVE='COPIACODBAREST' 
  AND LOGICO='S';
  
  IF P_COUNT = 0 THEN
    RETURN;
  END IF;
  
  IF NVL(:NEW.CODEMP,0)  <> 0 THEN
  BEGIN
   SELECT TIPCONTEST INTO P_TIPCONTEST
     FROM TGFPEM
    WHERE NVL(TIPCONTEST, 'N' ) <> 'N'
      AND CODPROD = :NEW.CODPROD
      AND CODEMP = :NEW.CODEMP;
      EXCEPTION 
          WHEN NO_DATA_FOUND THEN
             P_TIPCONTEST := NULL;
    END;
  END IF;

  IF P_TIPCONTEST IS NULL THEN	
   BEGIN
    SELECT TIPCONTEST INTO P_TIPCONTEST
      FROM TGFPRO
     WHERE NVL(TIPCONTEST, 'N' ) <> 'N'
       AND CODPROD = :NEW.CODPROD;
       EXCEPTION 
          WHEN NO_DATA_FOUND THEN
             P_TIPCONTEST := NULL;
    END;
  END IF;
		  
  IF(NVL(P_TIPCONTEST, 'N') <> 'N' AND NVL(:NEW.CONTROLE, ' ') = ' ') THEN
	RETURN;
  END IF;	
  
  BEGIN
      SELECT CODBARRA INTO P_CODBARRA
        FROM TGFEST
       WHERE CODPROD = :NEW.CODPROD
         AND CONTROLE = NVL(:NEW.CONTROLE, ' ')
         AND CODBARRA IS NOT NULL
         AND ROWNUM = 1;
       EXCEPTION 
          WHEN NO_DATA_FOUND THEN
             P_CODBARRA := NULL;
   END;

  IF NVL(P_CODBARRA, ' ') <> ' ' THEN
	:NEW.CODBARRA := P_CODBARRA;
  END IF;
    
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
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFEST_BAR_TRANSF" ENABLE;
