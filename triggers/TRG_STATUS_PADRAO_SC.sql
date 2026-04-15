CREATE OR REPLACE TRIGGER TRG_STATUS_PADRAO_SC
BEFORE INSERT ON AD_TGSSCP
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_STATUS_PADRAO_SC
  Tipo           : Trigger
  Descrição      : Define automaticamente o status padrão 'EA' (Em Análise) para novas solicitações de compra.
  Tabela         : AD_TGSSCP
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
  :NEW.STATUS := 'EA';
END TRG_STATUS_PADRAO_SC;
