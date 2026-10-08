/*==============================================================================
  Nome do Script : TRG_INC_UPT_TGFEST_CODBARRA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPT_TGFEST_CODBARRA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFEST_CODBARRA" BEFORE
INSERT
    OR
UPDATE
ON
    TGFEST FOR EACH ROW
 WHEN (
NEW.CODBARRA IS NOT NULL
        AND
        (
            OLD.CODBARRA IS NULL
            OR OLD.CODBARRA   <> NEW.CODBARRA
        )
      ) DECLARE P_COUNT NUMBER(5);
    P_CODPROD TGFPRO.CODPROD%TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
    ERRMSG    VARCHAR2(4000);
    ERROR     EXCEPTION;
    P_VALIDAR BOOLEAN;
    BEGIN
        IF STP_GET_ATUALIZANDO THEN
        RETURN;
    END
    IF;
    P_VALIDAR := Fpodevalidar('TGFEST'); -- sincronizac?o de dados
    SELECT
        COUNT(*)
    INTO
        P_COUNT
    FROM
        TSIPAR
    WHERE
        CHAVE      = 'VALCODBARREPET'
        AND LOGICO = 'S'
    ;
    
    --Só executa as validações se o parâmetro VALCODBARREPET estiver marcado.
    IF P_COUNT = 0 THEN
    RETURN;
END
IF;
SELECT
    COUNT(*)
  , MAX(CODPROD)
INTO
    P_COUNT
  , P_CODPROD
FROM
    TGFPRO
WHERE
    REFERENCIA = :NEW.CODBARRA
;

IF P_COUNT > 0 THEN
ERRMSG := 'Código de Barras REPETIDO na Referência do produto ' || P_CODPROD;
RAISE ERROR;
END
IF;
SELECT
    COUNT(*)
  , MAX(CODPROD)
INTO
    P_COUNT
  , P_CODPROD
FROM
    TGFVOA
WHERE
    CODBARRA = :NEW.CODBARRA
;

IF P_COUNT > 0 THEN
ERRMSG := 'Código de Barras REPETIDO na unidade alternativa para o produto ' || P_CODPROD;
RAISE ERROR;
END
IF;
SELECT
    COUNT(*)
  , MAX(CODPROD)
INTO
    P_COUNT
  , P_CODPROD
FROM
    TGFEST
WHERE
    CODBARRA      = :NEW.CODBARRA
    AND CONTROLE <> :NEW.CONTROLE
;

IF P_COUNT > 0 THEN
ERRMSG := 'Código de Barras REPETIDO em Controles diferentes para o produto ' || P_CODPROD;
RAISE ERROR;
END
IF;
SELECT
    COUNT(*)
  , MAX(CODPROD)
INTO
    P_COUNT
  , P_CODPROD
FROM
    TGFEST
WHERE
    CODBARRA     = :NEW.CODBARRA
    AND CODPROD <> :NEW.CODPROD
;

IF P_COUNT > 0 THEN
ERRMSG := 'Código de Barras REPETIDO no estoque para o produto ' || P_CODPROD;
RAISE ERROR;
END
IF;
SELECT
    COUNT(*)
  , MAX(CODPROD)
INTO
    P_COUNT
  , P_CODPROD
FROM
    TGFBAR
WHERE
    CODBARRA = :NEW.CODBARRA
;

IF P_COUNT > 0 AND :NEW.CODLOCAL <> 108 THEN --PERSONALIZADO SPARK, PRECISAMOS GERAR CODIGO DE BARRA DA SÉRIE PARA CONFERENCIA PRODUÇÃO
ERRMSG := 'Código de Barras REPETIDO no Cadastro de Código de Barras por produto, para o produto ' || P_CODPROD;
RAISE ERROR;
END
IF;
EXCEPTION
WHEN OTHERS THEN
    /*
    Sincronizac?o de dados n?o faz validac?es
    */
    IF (P_VALIDAR) THEN
    IF SQLCODE <> 1 THEN
    ERRMSG := ERRMSG || '  ' || SQLERRM;
END
IF;
RAISE_APPLICATION_ERROR(-20101, ERRMSG);
END
IF;
END; 
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFEST_CODBARRA" ENABLE;
