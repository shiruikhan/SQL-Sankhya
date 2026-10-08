/*==============================================================================
  Nome do Script : TRG_INS_UPD_TGFPAR_FLEX
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INS_UPD_TGFPAR_FLEX', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INS_UPD_TGFPAR_FLEX" 
BEFORE INSERT OR UPDATE 
ON TGFPAR FOR EACH ROW
      WHEN ( NEW.SALDODISP < 0 ) DECLARE
  P_PERSALFLXPARNEG INTEGER;
  P_COUNT           INT;
BEGIN

  IF NVL(:NEW.SALDODISP,0) >= NVL(:OLD.SALDODISP,0) THEN
    RETURN;
  END IF;
  
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  IF NOT Fpodevalidar('TGFPAR') THEN
    RETURN;
  END IF;
  
  SELECT COUNT(1) 
  INTO P_PERSALFLXPARNEG
  FROM TSIPAR 
  WHERE CHAVE = 'PERSALFLXPARNEG'
    AND CODUSU = 0
    AND LOGICO = 'S';
  
  IF P_PERSALFLXPARNEG = 0 THEN 
    RAISE_APPLICATION_ERROR(-20101, 'Saldo Flex do parceiro '|| :NEW.NOMEPARC ||' insuficiente para o desconto informado.');
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INS_UPD_TGFPAR_FLEX" ENABLE;
