/*==============================================================================
  Nome do Script : TRG_INC_UPD_DLT_TPRAPA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TPRAPA.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/02/2022.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_DLT_TPRAPA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TPRAPA" 
BEFORE INSERT OR UPDATE
ON TPRAPA
FOR EACH ROW
    WHEN ( NVL(OLD.QTDFAT,0) <> NVL(NEW.QTDFAT,0) AND NVL(ROUND(NEW.QTDFAT, 9),0) > NVL(ROUND(NEW.QTDAPONTADA, 9),0)) DECLARE ERRMSG VARCHAR2(100);
BEGIN
	ERRMSG := 'Qtd.Faturada ('|| :NEW.QTDFAT ||') não pode ser maior que Qtd.Apontada ('|| :NEW.QTDAPONTADA ||').';
     RAISE_APPLICATION_ERROR(-20101, ERRMSG);
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TPRAPA" ENABLE;
