CREATE OR REPLACE TRIGGER TRG_INC_AD_TGFFTA_SPARK
BEFORE INSERT ON AD_TGFFTA
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_AD_TGFFTA_SPARK
  Tipo           : Trigger
  Descrição      : Valida preenchimento obrigatório de INDICADORORT quando INDICADOR é "OTR"
  Tabela         : AD_TGFFTA
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
    IF :NEW.INDICADOR = 'OTR' AND :NEW.INDICADORORT IS NULL THEN
        RAISE_APPLICATION_ERROR(-20101, 'Falha de preenchimento: O campo DESCREVA é obrigatório quando INDICADOR é "Outro".');
    END IF;
END TRG_INC_AD_TGFFTA_SPARK;
