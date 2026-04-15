CREATE OR REPLACE TRIGGER TRG_ATUALIZA_STATUS_NUNOTA
BEFORE UPDATE ON AD_TGSSCP
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_ATUALIZA_STATUS_NUNOTA
  Tipo           : Trigger
  Descrição      : Atualiza automaticamente o status para 'CR' (Compra Realizada) quando o campo NUNOTA é preenchido na solicitação de compra.
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
  -- Executa somente se o campo NUNOTA for preenchido e estiver diferente de NULL
  IF :NEW.NUNOTA IS NOT NULL AND :OLD.NUNOTA IS NULL THEN
    :NEW.STATUS := 'CR';
  END IF;
END TRG_ATUALIZA_STATUS_NUNOTA;