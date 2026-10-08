/*==============================================================================
  Nome do Script : TRG_TGFFIN_INC_UPD_DIFVLRLDT
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFFIN_INC_UPD_DIFVLRLDT', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_INC_UPD_DIFVLRLDT" 
AFTER UPDATE
ON TGFFIN
FOR EACH ROW
    WHEN ((
    NEW.RECDESP = 1 
    AND OLD.DHBAIXA IS NULL 
    AND NEW.DHBAIXA IS NULL 
    AND NEW.TIMORIGEM IN ('FI','PC','PD','EN','AR','PI')) 
    AND (NEW.TIMCONTRATOLTV IS NOT NULL)) DECLARE
    V_SUMDTL NUMBER;
    V_DESDOB NUMBER;
    QTD INT;
BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
   
       SELECT COUNT(*) INTO QTD
       FROM TIM_BAIXA_CJMD C
    WHERE C.NUFIN = :NEW.NUFIN;
    
    IF QTD > 0 THEN
        RETURN;
    END IF;
    
    IF STP_GET_DISVALLDT(:NEW.NUFIN) THEN
        RETURN;
    END IF;

--       Por favor se essa trigger esta causando o bloqueio de algum processo
--       desative ela execute as rotinas do processo em bloqueio, e depois faça a sua ativação novamente
--       e tire um print que mostre a maioria dos campos possíveis do financeiro
--       e dos detalhamentos vinculados a ele para ser possível um diagnostico da diferênça entre o valor do financeiro
--       e a soma de seus detalhamentos conforme as suas devidas regras.
--       Informe o erro ao João Bosco Ribeiro ou a Equipe Labs da Central Sankhya falar com Bruno Pina ou Bruno Mota.
    IF NOT (( :NEW.VLRDESC IS NULL AND :OLD.VLRDESC IS NOT NULL )
        OR  ( :NEW.VLRDESC IS NOT NULL AND :OLD.VLRDESC IS NULL )
        OR  ( :NEW.VLRDESC != :OLD.VLRDESC )
        
        OR  ( :NEW.VLRJURO IS NULL AND :OLD.VLRJURO IS NOT NULL )
        OR  ( :NEW.VLRJURO IS NOT NULL AND :OLD.VLRJURO IS NULL )
        OR  ( :NEW.VLRJURO != :OLD.VLRJURO )
        
        OR  ( :NEW.VLRMULTA IS NULL AND :OLD.VLRMULTA IS NOT NULL )
        OR  ( :NEW.VLRMULTA IS NOT NULL AND :OLD.VLRMULTA IS NULL )
        OR  ( :NEW.VLRMULTA != :OLD.VLRMULTA )
        
        OR  ( :NEW.VLRDESDOB IS NULL AND :OLD.VLRDESDOB IS NOT NULL )
        OR  ( :NEW.VLRDESDOB IS NOT NULL AND :OLD.VLRDESDOB IS NULL )
        OR  ( :NEW.VLRDESDOB != :OLD.VLRDESDOB ) ) THEN
        RETURN;
    END IF;
    
    SELECT COUNT(*) INTO QTD
    FROM TIMLDT
    WHERE LDTPARCELA = :NEW.NUFIN;
    
    -- DEIXAR DE VALIDAR POR SER MUITO COMPLEXO O FATURAMENTO E AS TRATIVAS DE CADA CLIENTE
    IF QTD = 0 AND :NEW.TIMORIGEM = 'PC' THEN
        RETURN;
    END IF;
    
    SELECT NVL(SUM(NVL(CASE 
                WHEN LDTRECEBEDE = 'I' THEN LDTVALOR
                WHEN LDTREPASSAPARA = 'I' THEN -LDTVALOR
               END,0)),0) INTO V_SUMDTL
    FROM TIMLDT
    WHERE LDTPARCELA = :NEW.NUFIN;
   
   V_DESDOB := ROUND(
        :NEW.VLRDESDOB
        +NVL(CASE WHEN :NEW.TIPJURO = '1' THEN :NEW.VLRJURO END,0)
        +NVL(CASE WHEN :NEW.TIPMULTA = '1' THEN :NEW.VLRMULTA END,0)
        -NVL(:NEW.VLRDESC,0)    ,2);
    
    IF ROUND(ABS(V_DESDOB
        -ROUND(V_SUMDTL, 2)), 2) > 0.09 THEN
        
        RAISE_APPLICATION_ERROR(-20201, 'O valor do campo "Vlr. Desdobramento" ('|| TO_CHAR(V_DESDOB) ||') não é igual a soma dos detalhamentos ('|| TO_CHAR(V_SUMDTL) ||
       '), Nro. Único:'||TO_CHAR(:NEW.NUFIN));
            
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_INC_UPD_DIFVLRLDT" ENABLE;
