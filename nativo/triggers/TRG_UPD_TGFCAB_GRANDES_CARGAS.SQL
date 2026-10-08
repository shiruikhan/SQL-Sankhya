/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_GRANDES_CARGAS
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_GRANDES_CARGAS', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_GRANDES_CARGAS" 
BEFORE UPDATE ON TGFCAB FOR EACH ROW
      WHEN (
    NEW.CODEMP <> OLD.CODEMP OR
    NEW.CODPARC <> OLD.CODPARC OR 
    NEW.CODTIPOPER <> OLD.CODTIPOPER OR
    NEW.DHTIPOPER <> OLD.DHTIPOPER OR
    NEW.CODTIPVENDA <> OLD.CODTIPVENDA OR
    NEW.DHTIPVENDA <> OLD.DHTIPVENDA OR
    NEW.VLRDESCSERV <> OLD.VLRDESCSERV OR 
    NEW.VLRDESCTOT <> OLD.VLRDESCTOT OR 
    NEW.VLRDESCTOTITEM <> OLD.VLRDESCTOTITEM OR 
    NEW.VLRFRETE <> OLD.VLRFRETE OR 
    NEW.VLRNOTA <> OLD.VLRNOTA
      ) DECLARE P_CONFIRMADO CHAR(1);
P_VALIDAR BOOLEAN;   
P_COUNT NUMBER(05);
BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_GRANDES_CARGAS = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  P_VALIDAR := Fpodevalidar('TGFCAB');
  IF (NOT P_VALIDAR) THEN
    RETURN;
  END IF;
  
     BEGIN
       SELECT CONFIRMADO INTO P_CONFIRMADO 
       FROM TGFDGC 
       WHERE NUNOTA = :NEW.NUNOTA 
       AND SEQUENCIA = 0;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN;
     END;
     IF P_CONFIRMADO = 'S' THEN
       RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido alterar a nota quando já existe cálculo de grandes cargas confirmado. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.');
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_GRANDES_CARGAS" ENABLE;
