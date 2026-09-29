create or replace TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFPRO_SPARK"
BEFORE INSERT OR UPDATE ON TGFPRO
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPT_TGFPRO_SPARK
  Tipo           : Trigger
  Descrição      : Define uso de local para produtos da Spark, exceto para serviços
  Tabela         : TGFPRO
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance/limpeza: corrigido cabeçalho
                   ("Nome do Script: UNKNOWN") e END sem rótulo (END UNKNOWN;)
                   para o padrão do repositório; removidas P_COUNT/P_CODPROD,
                   declaradas mas nunca usadas no corpo. Nenhuma consulta SQL
                   própria nesta trigger além de STP_GET_ATUALIZANDO — sem
                   oportunidade adicional de performance. Comportamento
                   observável inalterado.
==============================================================================*/
DECLARE
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  /*OBJETIVO: CRIAR REGRAS CADASTRO PRODUTO DA SPARK
   AUTOR: DIONE SANTOS - SK
   DATA: 15/10/21
   */

  /* MARCA PRODUTO PARA USAR LOCAL, EXCETO SERVIÇO */
 IF NVL(:NEW.USALOCAL,'N') ='N' AND :NEW.USOPROD NOT IN ('S') THEN
 :NEW.USALOCAL := 'N';
 END IF;

END;
