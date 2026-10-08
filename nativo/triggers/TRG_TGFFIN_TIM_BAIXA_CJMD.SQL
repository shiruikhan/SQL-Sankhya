/*==============================================================================
  Nome do Script : TRG_TGFFIN_TIM_BAIXA_CJMD
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: DISABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_TIM_BAIXA_CJMD', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_TIM_BAIXA_CJMD" 
AFTER UPDATE
ON TGFFIN
FOR EACH ROW
     WHEN (OLD.DHBAIXA IS NULL 
    AND NEW.DHBAIXA IS NOT NULL 
    AND NEW.RECDESP = 1 
    AND NEW.TIMORIGEM IN ('PD','EN','FI','AR','PI','PC','FP','FB','AC','AL','AV','FC')) BEGIN
    -- Trigger so eh executada se for uma baixa de receita com origem nas rotinas imobiliarias acima especificadas
    
   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
    -- Trigger so eh executada se nao estiver ocorrendo uma atualizacao do SKW
    
    -- Registra os valores antigos dos campos juro/multa/desc, os embutidos, e o desdobramento
    INSERT INTO TIM_BAIXA_CJMD (
        NUFIN,
        OLD_VLRJURO,
        OLD_VLRMULTA,
        OLD_VLRDESC,
        OLD_VLRJUROEMBUT,
        OLD_VLRMULTAEMBUT,
        OLD_VLRDESCEMBUT)
    SELECT 
        :NEW.NUFIN,
        :OLD.VLRJURO,
        :OLD.VLRMULTA,
        :OLD.VLRDESC,
        :OLD.VLRJUROEMBUT,
        :OLD.VLRMULTAEMBUT,
        :OLD.VLRDESCEMBUT
    FROM DUAL
    WHERE NOT EXISTS (
        SELECT 1
        FROM TIM_BAIXA_CJMD
        WHERE NUFIN = :NEW.NUFIN
    );
    -- So grava se ja nao existir
    
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_TIM_BAIXA_CJMD" DISABLE;
