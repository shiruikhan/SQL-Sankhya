/*==============================================================================
  Nome do Script : TRG_UPT_TGFITE_METAS
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 05/11/2025)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 05/11/2025, última alteração em 05/11/2025.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPT_TGFITE_METAS', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPT_TGFITE_METAS" 
AFTER UPDATE ON TGFITE 
FOR EACH ROW
  WHEN (
(NEW.STATUSNOTA <> 'A') AND
       (OLD.STATUSNOTA <> NEW.STATUSNOTA OR 
        OLD.PENDENTE <> NEW.PENDENTE OR 
        OLD.QTDENTREGUE <> NEW.QTDENTREGUE OR
        OLD.QTDNEG <> NEW.QTDNEG OR
        OLD.VLRTOT <> NEW.VLRTOT)
      ) DECLARE      
P_COUNT     NUMBER(05);      
      
BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(1) INTO P_COUNT
    FROM TGMTRA 
    WHERE NUNOTA = :NEW.NUNOTA
    AND SEQUENCIAITE = :NEW.SEQUENCIA
    AND TIPO = 'C';
  IF P_COUNT = 0 THEN
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  IF (:NEW.PENDENTE = 'N') OR 
     (:NEW.QTDENTREGUE >= :NEW.QTDNEG) OR 
     ((:NEW.STATUSNOTA = 'L') AND (:NEW.ATUALESTOQUE = 1) AND (:NEW.RESERVA = 'N')) THEN
     
    UPDATE TGMTRA SET VALOR = 0
    , STATUS = DECODE(:NEW.STATUSNOTA,'L', 'A', 'P')
    WHERE NUNOTA = :NEW.NUNOTA
    AND SEQUENCIAITE = :NEW.SEQUENCIA
    AND TIPO = 'C'
    AND VALOR <> 0;    
    
  ELSIF :NEW.QTDNEG <> 0 THEN 
      UPDATE TGMTRA SET VALOR = ROUND(VALOR_ORIG / :OLD.QTDNEG * (:NEW.QTDNEG - :NEW.QTDENTREGUE),2)
    , STATUS = DECODE(:NEW.STATUSNOTA,'L', 'A', 'P')
    WHERE NUNOTA = :NEW.NUNOTA
    AND SEQUENCIAITE = :NEW.SEQUENCIA
    AND TIPO = 'C';
    
    UPDATE TGMTRA SET VALOR = 0
    WHERE NUNOTA = :NEW.NUNOTA
    AND SEQUENCIAITE = :NEW.SEQUENCIA
    AND TIPO = 'C'
    AND VALOR < 0;
    
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPT_TGFITE_METAS" ENABLE;
