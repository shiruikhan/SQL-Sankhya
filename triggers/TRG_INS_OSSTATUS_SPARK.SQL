create or replace TRIGGER TRG_INS_OSSTATUS_SPARK
BEFORE INSERT ON AD_OSINTERNA 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INS_OSSTATUS_SPARK
  Tipo           : Trigger
  Descrição      : Inicializa status padrão como "I" (Em aberto) para nova ordem de serviço interna
  Tabela         : AD_OSINTERNA
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

BEGIN
    :NEW.STATUS := 'I';
END TRG_INS_OSSTATUS_SPARK;