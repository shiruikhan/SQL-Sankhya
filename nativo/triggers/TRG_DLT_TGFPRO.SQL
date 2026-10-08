/*==============================================================================
  Nome do Script : TRG_DLT_TGFPRO
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFPRO', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFPRO" 
   BEFORE DELETE
   ON TGFPRO
   FOR EACH ROW
DECLARE
   P_COUNT   INT:= 0;

 BEGIN

   IF STP_GET_ATUALIZANDO THEN
    RETURN;
   END IF;

   EXISTSRESTRICAO('TGFPRO',:OLD.CODPROD);

   BEGIN
    VARIAVEIS_PKG.V_DLT_PROD := TRUE;
   END;

   SELECT COUNT (1) INTO P_COUNT
   FROM TGFTEL T WHERE T.CODPROD = :OLD.CODPROD;
   IF P_COUNT > 0 THEN
      RAISE_APPLICATION_ERROR(-20101,'Produto esta sendo referenciado no Telemarketing, n?o pode ser excluido.');
   END IF;
   
   
   SELECT COUNT(1) INTO P_COUNT
   FROM TGFICM
   WHERE (TIPRESTRICAO2 = 'P' AND CODRESTRICAO2 = :OLD.CODPROD) OR
         (TIPRESTRICAO = 'P' AND CODRESTRICAO = :OLD.CODPROD);
   IF P_COUNT > 0 THEN
     DELETE FROM TGFICM
     WHERE (TIPRESTRICAO2 = 'P' AND CODRESTRICAO2 = :OLD.CODPROD) OR
           (TIPRESTRICAO = 'P' AND CODRESTRICAO = :OLD.CODPROD);
   END IF;
   
   
   SELECT COUNT(1) INTO P_COUNT
   FROM TSIATA
   WHERE TIPO = 'R' AND CODATA = :OLD.CODPROD;
   IF P_COUNT > 0 THEN
     DELETE FROM TSIATA
     WHERE TIPO = 'R' AND CODATA = :OLD.CODPROD;
   END IF;
         

   SELECT COUNT(1) INTO P_COUNT
   FROM TGFIMA
   WHERE TIPO IN ('R', 'S') AND CODIGO = :OLD.CODPROD;
   IF P_COUNT > 0 THEN
     DELETE FROM TGFIMA
     WHERE TIPO IN ('R', 'S') AND CODIGO = :OLD.CODPROD;
   END IF;
   
   
   SELECT COUNT(1) INTO P_COUNT
   FROM TGFFCP
   WHERE CODPROD = :OLD.CODPROD AND VARIACAO = 30000;
   IF P_COUNT > 0 THEN
     DELETE FROM TGFFCP  
     WHERE CODPROD = :OLD.CODPROD AND VARIACAO = 30000;
   END IF;
  
  
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFDFO
  WHERE CODPROD = :OLD.CODPROD;
  IF P_COUNT > 0 THEN
    DELETE FROM TGFDFO 
    WHERE CODPROD = :OLD.CODPROD;
  END IF;
  
  
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFPMA
  WHERE CODPROD = :OLD.CODPROD;
  IF P_COUNT > 0 THEN
    DELETE FROM TGFPMA
    WHERE CODPROD = :OLD.CODPROD;
  END IF;
        
  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFPRO" ENABLE;
