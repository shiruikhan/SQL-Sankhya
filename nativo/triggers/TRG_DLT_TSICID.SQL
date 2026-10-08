/*==============================================================================
  Nome do Script : TRG_DLT_TSICID
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TSICID.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TSICID', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TSICID" BEFORE DELETE ON TSICID FOR EACH ROW
DECLARE
	P_COUNT                  INT:= 0;
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  IF (:OLD.CODCID = 0) THEN
     raise_application_error(-20101, 'Registro padr?o do sistema. N?o pode ser alterado ou excluido.');
  END IF;

  SELECT COUNT(1) INTO P_COUNT
  FROM TGFICM
  WHERE (TIPRESTRICAO = 'C' OR TIPRESTRICAO = 'D')
  AND CODRESTRICAO = :OLD.CODCID;
  IF (P_COUNT<>0) THEN
    raise_application_error(-20101, 'Registro nao pode ser deletado. Existe uma ref.nas excec?es das aliquotas de ICMS.');
  END IF;


  SELECT COUNT(1)  INTO P_COUNT
  FROM TGFICM
  WHERE (TIPRESTRICAO2 = 'C' OR TIPRESTRICAO2 = 'D')
  AND CODRESTRICAO2 = :OLD.CODCID;
  IF (P_COUNT<>0) THEN
    raise_application_error(-20101, 'Registro nao pode ser deletado. Existe uma ref.nas excec?es das aliquotas de ICMS.');
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TSICID" ENABLE;
