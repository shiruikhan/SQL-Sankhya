/*==============================================================================
  Nome do Script : TRG_UPT_TGFFIN_NUBCO
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPT_TGFFIN_NUBCO', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_NUBCO" 
BEFORE INSERT OR UPDATE ON TGFFIN 
FOR EACH ROW
         WHEN ((NEW.NUBCO IS NULL) AND (NEW.DHBAIXA IS NOT NULL) AND (NEW.PROVISAO = 'N') AND (NEW.NUDEV IS NULL)) DECLARE
  P_COUNT INT;
  ERRMSG            VARCHAR2(255);
  ERROR             EXCEPTION;
  P_VALIDAR BOOLEAN;
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  /* 
  sincronizac?o de dados
  */
  P_VALIDAR := FPODEVALIDAR('TGFFIN');
  IF (NOT P_VALIDAR) THEN 
    RETURN;
  END IF;
  /* Substituic?o de naturezas */
  SELECT COUNT(1) INTO P_COUNT
  FROM TSIPAR
  WHERE (CHAVE = 'SBPARCEIRO' OR CHAVE ='MGE-SUBST');
  
  IF (P_COUNT>0) THEN 
    RETURN;
  END IF;
  
  SELECT COUNT(1)
  INTO P_COUNT
  FROM TGFFRE
  WHERE NUFIN = :NEW.NUFIN;
  
  IF P_COUNT = 0 THEN
    SELECT COUNT(1)
    INTO P_COUNT
    FROM TGFRAP
    WHERE NUFIN = :NEW.NUFIN;
    IF P_COUNT = 0 THEN
      ERRMSG := 'Baixa sem ligac?o com TGFMBC. Financeiro de Nro Unico: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;
  END IF;
  RETURN;
EXCEPTION
  WHEN ERROR THEN
  RAISE_APPLICATION_ERROR(-20101, ERRMSG);
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_NUBCO" ENABLE;
