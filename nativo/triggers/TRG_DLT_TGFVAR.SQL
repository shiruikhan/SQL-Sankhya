/*==============================================================================
  Nome do Script : TRG_DLT_TGFVAR
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFVAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFVAR', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFVAR" BEFORE DELETE ON TGFVAR FOR EACH ROW
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

 IF ((:OLD.NUNOTAORIG <> :OLD.NUNOTA) AND (:OLD.QTDATENDIDA <> 0)) THEN
   INSERT INTO TGFVAR_DLT(NUNOTA, SEQUENCIA, NUNOTAORIG, SEQUENCIAORIG, QTDATENDIDA, FIXACAO)
   VALUES (:OLD.NUNOTA, :OLD.SEQUENCIA, :OLD.NUNOTAORIG, :OLD.SEQUENCIAORIG, :OLD.QTDATENDIDA, :OLD.FIXACAO);
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFVAR" ENABLE;
