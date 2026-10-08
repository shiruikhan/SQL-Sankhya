/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFFIN_DTVENC
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFFIN_DTVENC', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_DTVENC" 
BEFORE INSERT OR UPDATE ON TGFFIN
FOR EACH ROW
    WHEN ((NEW.TIMCONTRATOLOC IS NOT NULL OR NEW.TIMCONTRATOLTV IS NOT NULL)
	AND NEW.TIMORIGEM IS NOT NULL) DECLARE
  P_VALIDAR                 BOOLEAN;
  ERRMSG                    VARCHAR2(255);
  ERROR                      EXCEPTION;
BEGIN
  IF STP_GET_ATUALIZANDO() THEN
    RETURN;
  END IF;
  
  P_VALIDAR := Fpodevalidar('TGFFIN');
  
  IF :NEW.DTVENC <> TRUNC(:NEW.DTVENC) THEN
    RAISE_APPLICATION_ERROR(-20101, 'Data de vencimento com Hora');
  END IF;

  RETURN;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_DTVENC" ENABLE;
