CREATE OR REPLACE TRIGGER TRG_BLOQUEIA_DELETE_SC
BEFORE DELETE ON AD_TGSSCP
FOR EACH ROW
WHEN (OLD.STATUS IN ('A', 'C', 'CR'))
/*==============================================================================
  Nome do Script : TRG_BLOQUEIA_DELETE_SC
  Tipo           : Trigger
  Descrição      : Bloqueia a exclusão de solicitações de compra que possuem status 'A' (Aprovada), 'C' (Cancelada) ou 'CR' (Compra Realizada).
  Tabela         : AD_TGSSCP
  Evento         : BEFORE DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: adicionada cláusula WHEN
                   idêntica ao único IF do corpo. Comportamento observável
                   inalterado (fora do filtro, o DELETE já prosseguia sem
                   erro).
==============================================================================*/
BEGIN
  IF :OLD.STATUS IN ('A', 'C', 'CR') THEN
    RAISE_APPLICATION_ERROR(-20011, 'Solicitações aprovadas, canceladas ou realizadas não podem ser excluídas.');
  END IF;
END TRG_BLOQUEIA_DELETE_SC;