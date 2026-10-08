/*==============================================================================
  Nome do Script : TRG_INC_UPD_TSICID_SITE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TSICID.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: DISABLED; criada em 07/12/2021, última alteração em 28/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TSICID_SITE', 'SPARKPRD') FROM dual;
                   - Referencia: AD_USADOLV, AD_VLRMIMFTSGRATIS
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TSICID_SITE" BEFORE INSERT OR UPDATE ON TSICID FOR EACH ROW
DECLARE
BEGIN
	IF (:NEW.VLRFRETEMIN <> :OLD.VLRFRETEMIN) THEN
		UPDATE TGFPAR SET AD_VLRMIMFTSGRATIS = :NEW.VLRFRETEMIN WHERE CODCID = :NEW.CODCID AND AD_USADOLV = 'S';
	END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TSICID_SITE" DISABLE;
