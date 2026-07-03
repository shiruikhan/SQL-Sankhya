CREATE OR REPLACE TRIGGER TRG_UPD_AD_TGSIXN_SPARK
BEFORE UPDATE ON AD_TGSIXN
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_UPD_AD_TGSIXN_SPARK
  Tipo           : Trigger
  Descrição      : Impede a edição dos dados de identidade do apontamento de
                   conferência após sua criação (NUCONF, CODUSUINC, NUARQUIVO,
                   DTINI, OBSERVACAO). O apontamento é único e imutável: uma
                   vez gravado pelo botão de ação (STP_APONTACONFERENCIA_SPARK),
                   só pode ser fechado automaticamente pelo próprio sistema.
  Tabela         : AD_TGSIXN
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSIXN -- registro validado via :OLD/:NEW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Criação

  Observações    : - DTFIM e STATUS ficam de fora da checagem de propósito:
                     são as únicas colunas que o próprio sistema pode alterar
                     (TRG_INC_UPD_TGSIXN_DTFIM_SPARK e
                     TRG_INC_UPD_AD_TGSIXN_SPARK, acionadas também pela
                     reavaliação periódica de STP_ATUALIZADTFIM_TGSIXN_SPARK).
                   - Só atua em UPDATE (não em INSERT), pois na criação
                     :OLD ainda não existe.
==============================================================================*/
BEGIN
    IF :NEW.NUCONF != :OLD.NUCONF
       OR NVL(:NEW.CODUSUINC, -1) != NVL(:OLD.CODUSUINC, -1)
       OR NVL(:NEW.NUARQUIVO, -1) != NVL(:OLD.NUARQUIVO, -1)
       OR NVL(:NEW.DTINI, DATE '0001-01-01') != NVL(:OLD.DTINI, DATE '0001-01-01')
       OR (:OLD.OBSERVACAO IS NULL AND :NEW.OBSERVACAO IS NOT NULL)
       OR (:OLD.OBSERVACAO IS NOT NULL AND :NEW.OBSERVACAO IS NULL)
       OR (:OLD.OBSERVACAO IS NOT NULL AND :NEW.OBSERVACAO IS NOT NULL
           AND DBMS_LOB.COMPARE(:OLD.OBSERVACAO, :NEW.OBSERVACAO) != 0)
    THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Apontamento de conferência (NUCONF ' || :OLD.NUCONF || ') não pode ser alterado após criado.');
    END IF;
END;
