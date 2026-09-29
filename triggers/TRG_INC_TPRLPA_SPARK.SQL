create or replace TRIGGER "SPARKPRD"."TRG_INC_TPRLPA_SPARK"
  BEFORE INSERT OR UPDATE ON TPRLPA
  FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TPRLPA_SPARK
  Tipo           : Trigger
  Descrição      : Define máscara padrão para geração automática de série em produtos com controle por série
  Tabela         : TPRLPA
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance/limpeza: checagem de
                   existência (SELECT COUNT(*)) ganhou ROWNUM = 1; corrigido
                   cabeçalho END sem rótulo válido (END UNKNOWN;) para END;.
                   Comportamento observável inalterado.
==============================================================================*/
DECLARE
P_COUNT  INT;

BEGIN

  SELECT COUNT(*) INTO P_COUNT
  FROM TGFPRO WHERE CODPROD = :NEW.CODPRODPA AND TIPCONTEST='E' AND ROWNUM = 1;

  /*PRODUTO COM MARCAÇÃO DE CONTROLE POR SÉRIE, SEMPRE CADASTRAR A MASCARA PARA GERAR SERIE */
  IF P_COUNT = 1 THEN
  :NEW.TIPOGERASERIE :='P';
  :NEW.MASCSERIE :='SNLLLLLLLL####';
  END IF;

END;
