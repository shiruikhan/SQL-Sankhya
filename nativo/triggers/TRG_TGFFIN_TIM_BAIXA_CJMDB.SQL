/*==============================================================================
  Nome do Script : TRG_TGFFIN_TIM_BAIXA_CJMDB
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: DISABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_TIM_BAIXA_CJMDB', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_TIM_BAIXA_CJMDB" 
BEFORE UPDATE
ON TGFFIN
FOR EACH ROW
     WHEN (OLD.DHBAIXA IS NULL 
    AND NEW.DHBAIXA IS NOT NULL 
    AND NEW.RECDESP = 1 
    AND NEW.TIMORIGEM IN ('PD','EN','FI','AR','PI','PC','FP','FB','AC','AL','AV','FC')) DECLARE
    -- Trigger so eh executada se for uma baixa de receita com origem nas rotinas imobiliarias acima especificadas
    
    -- Declaracao de uma variavel e uma funcao para descobrir se o parametro 'Calc. Juros, Multa, Desconto (Incluso,Extra)' eh Extra ou Incluso
    P_TIMCALDESD VARCHAR(50);

    FUNCTION GET_PARAMETRO_TXT(P_PARAMETRO VARCHAR)
    RETURN VARCHAR
    AS
        P_RESULT VARCHAR(4000);
    BEGIN
        
        SELECT TEXTO INTO P_RESULT
        FROM TSIPAR
        WHERE UPPER(CHAVE) = UPPER(P_PARAMETRO)
        AND CODUSU = 0;
        
        RETURN P_RESULT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN NULL;
    END;
    
BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
    -- Trigger so eh executada se nao estiver ocorrendo uma atualizacao do SKW

    P_TIMCALDESD := NVL(GET_PARAMETRO_TXT('TIMCALDESD'),'Incluso');

    IF (:NEW.TIMORIGEM IN ('AL','AV','FC')) OR (:NEW.TIMORIGEM IN ('PD','EN','FI','AR','PI','PC','FP','FB','AC') AND :NEW.TIMCONTRATOLTV IS NOT NULL AND P_TIMCALDESD = 'Incluso') THEN
        -- So alterar se for locacao ou loteamento com calculos inclusos

        -- STP_TIM_GRAVAR_LOG_BAIXA(:NEW.NUFIN,:NEW.VLRJURO,:NEW.VLRMULTA,:NEW.VLRDESC,:NEW.VLRJUROEMBUT,:NEW.VLRMULTAEMBUT,:NEW.VLRDESCEMBUT,:NEW.VLRDESDOB,:NEW.VLRBAIXA);
        -- Grava log

        -- Remove o valor do campo juro e soma-o ao campo embutido e, se o tipo for incluso, tambem soma ao valor do desdobramento
        IF :NEW.VLRJURO >= 0.01 THEN
            :NEW.VLRJUROEMBUT := :NEW.VLRJUROEMBUT + :NEW.VLRJURO;
            
            IF :NEW.TIPJURO = '1' THEN
                :NEW.VLRDESDOB := :NEW.VLRDESDOB + :NEW.VLRJURO;
            END IF;
            
            :NEW.VLRJURO := 0;
        END IF;
        
        -- Remove o valor do campo multa e soma-o ao campo embutido e, se o tipo for incluso, tambem soma ao valor do desdobramento
        IF :NEW.VLRMULTA >= 0.01 THEN
            :NEW.VLRMULTAEMBUT := :NEW.VLRMULTAEMBUT + :NEW.VLRMULTA;
            
            IF :NEW.TIPMULTA = '1' THEN
                :NEW.VLRDESDOB := :NEW.VLRDESDOB + :NEW.VLRMULTA;
            END IF;
            
            :NEW.VLRMULTA := 0;
        END IF;
        
        -- Remove o valor do campo desconto e soma-o aos campos embutido e valor do desdobramento
        IF :NEW.VLRDESC >= 0.01 THEN
            :NEW.VLRDESCEMBUT := :NEW.VLRDESCEMBUT + :NEW.VLRDESC;
            :NEW.VLRDESDOB := :NEW.VLRDESDOB - :NEW.VLRDESC;
            :NEW.VLRDESC := 0;
        END IF;
        
       -- STP_TIM_GRAVAR_LOG_BAIXA(:NEW.NUFIN,:NEW.VLRJURO,:NEW.VLRMULTA,:NEW.VLRDESC,:NEW.VLRJUROEMBUT,:NEW.VLRMULTAEMBUT,:NEW.VLRDESCEMBUT,:NEW.VLRDESDOB,:NEW.VLRBAIXA);
       -- Grava log novamente
    
    END IF;

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_TIM_BAIXA_CJMDB" DISABLE;
