CREATE OR REPLACE TRIGGER TRG_INC_UPD_AD_TGSIXN_SPARK
BEFORE INSERT OR UPDATE ON AD_TGSIXN
FOR EACH ROW
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
  Última Revisão : Julho/2026 — Removida a cláusula FOLLOWS
                   TRG_INC_UPD_TGSIXN_DTFIM_SPARK: essa trigger foi
                   descontinuada (STP_ATUALIZADTFIM_TGSIXN_SPARK passou a
                   calcular DTFIM diretamente, consultando TGFCAB). Esta
                   trigger não depende de ordem de execução com nenhuma
                   outra: DTFIM já chega pronto em :NEW, seja de um UPDATE
                   direto da procedure, seja de uma edição manual na tela.

  Observações    : - STATUS é sempre recalculado a partir de DTFIM, sobrepondo
                     qualquer valor informado manualmente para a coluna.
==============================================================================*/
BEGIN
    IF :NEW.DTFIM IS NULL THEN
        :NEW.STATUS := '1';
    ELSE
        :NEW.STATUS := '2';
    END IF;
END;
