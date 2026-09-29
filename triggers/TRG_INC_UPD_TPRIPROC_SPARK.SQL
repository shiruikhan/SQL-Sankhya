create or replace TRIGGER TRG_INC_UPD_TPRIPROC_SPARK
BEFORE INSERT OR UPDATE ON TPRIPROC
FOR EACH ROW
WHEN (NEW.STATUSPROC = 'C' AND NEW.NUMPS > 0)
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TPRIPROC_SPARK
  Tipo           : Trigger
  Descrição      : Limpa número MPS ao cancelar ordem de produção para liberação em exclusão de planos
  Tabela         : TPRIPROC
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance/limpeza: adicionada cláusula
                   WHEN idêntica ao único IF do corpo; removida P_COUNT,
                   declarada mas nunca usada. Comportamento observável
                   inalterado.
==============================================================================*/
BEGIN

/* AO CANCELAR UMA OP LIMPAR O CAMPO NRO DO MPS PARA NÃO TRAVAR A EXCLUSÃO DE UM PLANO NA TELA DE MRP 1 - DIONE/RENAN  08/04/22 */

   :NEW.AD_AGRUPADORIMP := :NEW.NUMPS;
   :NEW.NUMPS := NULL;

END TRG_INC_UPD_TPRIPROC_SPARK;
