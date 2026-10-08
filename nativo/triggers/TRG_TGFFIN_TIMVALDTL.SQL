/*==============================================================================
  Nome do Script : TRG_TGFFIN_TIMVALDTL
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: DISABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_TIMVALDTL', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_TIMVALDTL" 
AFTER UPDATE
ON TGFFIN
FOR EACH ROW
    WHEN (NEW.TIMORIGEM IN ('AL','AV','FC')) BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
    
    INSERT INTO TIMVALDTL (
        NUFIN,
        OLD_DHBAIXA,
        OLD_VLRDESDOB,
        PROCESSANDO 
    )
    SELECT 
        :NEW.NUFIN NUFIN,
        :OLD.DHBAIXA OLD_DHBAIXA,
        :OLD.VLRDESDOB OLD_VLRDESDOB,
        'N' PROCESSANDO
    FROM DUAL
    WHERE NOT EXISTS (
        SELECT 1
        FROM TIMVALDTL
        WHERE NUFIN = :NEW.NUFIN
    );
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_TIMVALDTL" DISABLE;
