CREATE OR REPLACE TRIGGER TRG_INC_UPD_AD_TGSIXN_SPARK
BEFORE INSERT OR UPDATE ON AD_TGSIXN
FOR EACH ROW
FOLLOWS TRG_INC_UPD_TGSIXN_DTFIM_SPARK
/*==============================================================================
  Nome do Script : TRG_INC_UPD_AD_TGSIXN_SPARK
  Tipo           : Trigger
  Descrição      : Mantém o campo STATUS de AD_TGSIXN coerente com o
                   preenchimento de DTFIM: enquanto o apontamento de conferência
                   está em aberto, STATUS = 1; ao ser finalizado (DTFIM
                   preenchida), STATUS = 2.
  Tabela         : AD_TGSIXN
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSIXN -- registro alterado via :NEW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Adicionado FOLLOWS TRG_INC_UPD_TGSIXN_DTFIM_SPARK
                   para garantir que STATUS seja calculado após o preenchimento
                   automático de DTFIM.

  Observações    : - STATUS é sempre recalculado a partir de DTFIM, sobrepondo
                     qualquer valor informado manualmente para a coluna.
                   - Depende da execução prévia de TRG_INC_UPD_TGSIXN_DTFIM_SPARK
                     (cláusula FOLLOWS) para enxergar o DTFIM já calculado.
==============================================================================*/
BEGIN
    IF :NEW.DTFIM IS NULL THEN
        :NEW.STATUS := '1';
    ELSE
        :NEW.STATUS := '2';
    END IF;
END;
