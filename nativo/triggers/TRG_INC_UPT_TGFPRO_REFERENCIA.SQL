/*==============================================================================
  Nome do Script : TRG_INC_UPT_TGFPRO_REFERENCIA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: DISABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPT_TGFPRO_REFERENCIA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFPRO_REFERENCIA" 
BEFORE INSERT OR UPDATE ON TGFPRO
FOR EACH ROW
         WHEN (
NEW.REFERENCIA IS NOT NULL AND (OLD.REFERENCIA IS NULL OR OLD.REFERENCIA <> NEW.REFERENCIA)
      ) DECLARE 
  P_COUNT             NUMBER(5);
  P_CODPROD           TGFPRO.CODPROD%TYPE;
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  IF ((INSTR(:NEW.REFERENCIA,CHR(10)) > 0) OR 
      (INSTR(:NEW.REFERENCIA,CHR(13)) > 0) OR
      (INSTR(:NEW.REFERENCIA,CHR(9)) > 0)) THEN
    RAISE_APPLICATION_ERROR(-20101,'N?o e permitido quebra de linha no campo CODBARRA.');
  END IF;
  
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIPAR 
  WHERE CHAVE = 'VALCODBARREPET'
    AND LOGICO = 'S'; 
  --So executa as validac?es se o parametro VALCODBARREPET estiver marcado.
  IF P_COUNT = 0 THEN
    RETURN;
  END IF;

  SELECT COUNT(*), MAX(CODPROD)
    INTO P_COUNT, P_CODPROD
  FROM TGFVOA
  WHERE CODBARRA = :NEW.REFERENCIA;
  
  IF P_COUNT > 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Referencia REPETIDO no Codigo de Barra da Unidade Alternativa para o produto ' || P_CODPROD);
  END IF;

  SELECT COUNT(*), MAX(CODPROD)
    INTO P_COUNT, P_CODPROD
  FROM TGFEST
  WHERE CODBARRA = :NEW.REFERENCIA;
  
  IF P_COUNT > 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Referencia REPETIDO no Codigo de Barra do Estoque para o produto ' || P_CODPROD);
  END IF;

  SELECT COUNT(*), MAX(CODPROD)
    INTO P_COUNT, P_CODPROD
  FROM TGFPRO
  WHERE REFERENCIA = :NEW.REFERENCIA;
  
  IF P_COUNT > 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Referencia REPETIDO para o produto ' || P_CODPROD);
  END IF;
  
  SELECT COUNT(*), MAX(CODPROD)
    INTO P_COUNT, P_CODPROD 
  FROM TGFBAR
   WHERE CODBARRA = :NEW.REFERENCIA;
  
  IF P_COUNT > 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Codigo Barra REPETIDO no Cadastro de Codigo de Barras por produto, para o produto ' || P_CODPROD);
  END IF;
   
  RETURN;  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFPRO_REFERENCIA" DISABLE;
