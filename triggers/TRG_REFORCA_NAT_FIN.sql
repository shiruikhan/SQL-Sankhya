CREATE OR REPLACE TRIGGER TRG_REFORCA_NAT_FIN
AFTER INSERT OR UPDATE ON TGFCAB
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_REFORCA_NAT_FIN
  Tipo           : Trigger
  Descrição      : Atualiza natureza e centro de custo na tabela TGFFIN com base nos valores da TGFCAB, excluindo tipos específicos e financeiros rateados.
  Tabela         : TGFCAB
  Evento         : AFTER INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Agosto/2025
  Última Revisão : Setembro/2026 — Performance: em UPDATE, só executa quando
                   CODNAT ou CODCENCUS de fato mudaram em relação ao :OLD
                   (antes rodava em toda gravação de TGFCAB, mesmo alterando
                   campos sem relação). Em INSERT o comportamento permanece
                   incondicional, como antes. Comportamento observável
                   inalterado — o UPDATE já era idempotente para valores
                   inalterados.
==============================================================================*/
DECLARE
    P_DEVEATUALIZAR BOOLEAN;
BEGIN
    -- Reforça a natureza e centro de custo na TGFFIN baseada na TGFCAB
    -- Utiliza NUNOTA e CODPARC como parâmetros de ligação

    IF INSERTING THEN
        P_DEVEATUALIZAR := (:NEW.CODNAT IS NOT NULL OR :NEW.CODCENCUS IS NOT NULL);
    ELSE
        -- Só reforça em UPDATE quando o valor de fato mudou
        P_DEVEATUALIZAR := (:NEW.CODNAT IS NOT NULL AND NVL(:NEW.CODNAT,-1) <> NVL(:OLD.CODNAT,-1))
                         OR (:NEW.CODCENCUS IS NOT NULL AND NVL(:NEW.CODCENCUS,-1) <> NVL(:OLD.CODCENCUS,-1));
    END IF;

    IF P_DEVEATUALIZAR THEN
        UPDATE TGFFIN
           SET CODNAT = CASE WHEN :NEW.CODNAT IS NOT NULL THEN :NEW.CODNAT ELSE CODNAT END,
               CODCENCUS = CASE WHEN :NEW.CODCENCUS IS NOT NULL THEN :NEW.CODCENCUS ELSE CODCENCUS END
         WHERE NUNOTA = :NEW.NUNOTA
           AND CODPARC = :NEW.CODPARC
           -- Mantém a regra de exclusão dos tipos isentos (34, 35, 36, 15)
           AND CODTIPTIT NOT IN (34, 35, 36, 15)
           AND NURENEG IS NULL
           -- Validação: O update só pode acontecer SE o financeiro não for rateado
           AND NOT EXISTS (
               SELECT 1
               FROM TGFRAT
               WHERE TGFRAT.NUFIN = TGFFIN.NUFIN
           );
    END IF;
END;
