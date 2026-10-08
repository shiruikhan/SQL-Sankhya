/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE_ATIVO
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 17/03/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFITE_ATIVO', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE_ATIVO" 
BEFORE INSERT OR UPDATE ON TGFITE 
FOR EACH ROW
     WHEN (
OLD.CODPROD IS NULL OR OLD.CODPROD <> NEW.CODPROD
      ) DECLARE
  P_DESCRPROD  TGFPRO.DESCRPROD%TYPE; 
  P_ATIVO      TGFPRO.ATIVO%TYPE;
  ERRMSG              VARCHAR2(4000);
  ERROR               EXCEPTION;
  P_VALIDAR           BOOLEAN;
BEGIN
  P_VALIDAR := Fpodevalidar('TGFITE');  -- Sincronização de dados

  BEGIN
      SELECT DESCRPROD, ATIVO INTO P_DESCRPROD, P_ATIVO
      FROM TGFPRO
      WHERE codprod = :NEW.CODPROD;
  EXCEPTION 
      WHEN OTHERS THEN
        ERRMSG := 'Erro inesperado. Entre em contato com a TI.';
        RAISE ERROR;
  END; 

  IF P_ATIVO = 'N' THEN
        ERRMSG := 'Produto "' || TO_CHAR(:NEW.CODPROD) || ' - ' || p_descrprod || '" inativo.';
        RAISE ERROR;
  END if;  

EXCEPTION
  WHEN OTHERS THEN
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE_ATIVO" ENABLE;
