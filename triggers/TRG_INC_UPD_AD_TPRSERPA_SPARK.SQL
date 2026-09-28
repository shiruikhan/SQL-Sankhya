create or replace TRIGGER TRG_INC_UPD_AD_TPRSERPA_SPARK
BEFORE INSERT OR UPDATE OR DELETE ON AD_TPRSERPA
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_AD_TPRSERPA_SPARK
  Tipo           : Trigger
  Descrição      : Insere código de barras em tabela de estoque para conferência de produção
  Tabela         : AD_TPRSERPA
  Evento         : BEFORE INSERT OR UPDATE OR DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: avaliada e REJEITADA a proposta
                   de só rodar o INSERT/SELECT em TGFEST quando o UPDATE altera
                   SERIEPA/CODPRODPA. Revisão adversarial apontou que esse
                   INSERT também tem um papel de "autocura" do registro em
                   TGFEST (o NOT EXISTS recria a linha se ela tiver sido
                   removida por algum processo externo/nativo do Sankhya);
                   restringir a colunas específicas suprimiria essa autocura em
                   qualquer UPDATE que não toque SERIEPA/CODPRODPA. Como não há
                   garantia no schema de que essa linha nunca é removida fora
                   deste trigger, a lógica original (incondicional) foi
                   mantida para não arriscar perda de funcionalidade.
==============================================================================*/
DECLARE
P_COUNT        INT;

BEGIN
  --INSERE O CÓDIGO DE BARRAS NA TABELA DE ESTOQUE PARA  REALIZAR A CONFERENCIA PRODUÇÃO
  INSERT INTO TGFEST (CODEMP,CODLOCAL,CODPROD,CONTROLE,CODBARRA)
  SELECT 1,108,NVL(:NEW.CODPRODPA,:OLD.CODPRODPA),NVL(:NEW.SERIEPA,:OLD.SERIEPA),NVL(:NEW.SERIEPA,:OLD.SERIEPA)
    FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM TGFEST E WHERE E.CODBARRA = NVL(:NEW.SERIEPA,:OLD.SERIEPA) AND E.CODPROD = NVL(:NEW.CODPRODPA,:OLD.CODPRODPA) AND CODLOCAL = 108);

END TRG_INC_UPD_AD_TPRSERPA_SPARK;