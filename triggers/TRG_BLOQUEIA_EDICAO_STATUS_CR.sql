CREATE OR REPLACE TRIGGER TRG_BLOQUEIA_EDICAO_STATUS_CR
BEFORE UPDATE ON AD_TGSSCP
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_BLOQUEIA_EDICAO_STATUS_CR
  Tipo           : Trigger
  Descrição      : Impede alterações em solicitações de compra que atingiram o status 'CR' (Compra Realizada).
  Tabela         : AD_TGSSCP
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
  IF :OLD.STATUS = 'CR' THEN
    RAISE_APPLICATION_ERROR(-20010, 'Alterações não são permitidas após o status ser "CR - Compra Realizada".');
  END IF;
END TRG_BLOQUEIA_EDICAO_STATUS_CR;