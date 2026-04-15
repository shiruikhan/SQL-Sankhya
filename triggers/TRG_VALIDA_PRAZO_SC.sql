CREATE OR REPLACE TRIGGER TRG_VALIDA_PRAZO_SC
BEFORE INSERT OR UPDATE ON AD_TGSSCP
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_VALIDA_PRAZO_SC
  Tipo           : Trigger
  Descrição      : Valida se o prazo de necessidade é posterior à data atual, bloqueando datas iguais ou anteriores.
  Tabela         : AD_TGSSCP
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
  IF :NEW.PRAZO <= TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(-20001, 'O prazo de necessidade deve ser maior que a data atual.');
  END IF;
END TRG_VALIDA_PRAZO_SC;
