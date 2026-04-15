CREATE OR REPLACE FUNCTION FC_TEMMETA_SPARK (
    P_CODPROD IN NUMBER   -- Código do produto a verificar
)
RETURN VARCHAR2
/*==============================================================================
  Nome do Script : FC_TEMMETA_SPARK
  Tipo           : Function
  Descrição      : Verifica se um produto possui meta de produção cadastrada
                   com o código de meta 3 (meta padrão de PCP da Spark).

                   Retorna 'S' se houver pelo menos um registro ativo para o
                   produto em TGMMET com CODMETA = 3; retorna 'N' caso contrário.

  Parâmetros     :
    P_CODPROD      — Código do produto a verificar (TGFPRO.CODPROD)

  Retorno        :
    'S'            — produto possui meta de código 3 cadastrada
    'N'            — produto não possui meta de código 3

  Tabela fonte   : TGMMET — tabela de metas de produção do Sankhya

  Observações    : - CODMETA = 3 é o identificador da meta de produção padrão
                     utilizada pelo PCP da Spark Eletrônica.
                   - A function é usada pelas procedures STP_PCP_SPARK e
                     STP_PCPMETA_SPARK como pré-condição para geração do MPS:
                     apenas produtos com meta cadastrada são planejados.
                   - COUNT(0) é equivalente a COUNT(*) em Oracle — conta linhas
                     sem avaliar o valor da expressão.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 16/12/2021
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
AS
    -- Contador de registros com meta de código 3 para o produto informado
    V_COUNT INTEGER;

BEGIN
    -- Verifica se existe pelo menos uma meta de código 3 para o produto.
    -- CODMETA = 3 identifica a meta padrão de PCP na Spark Eletrônica.
    SELECT COUNT(0)
      INTO V_COUNT
      FROM TGMMET
     WHERE CODMETA = 3
       AND CODPROD = P_CODPROD;

    -- Retorna 'S' se encontrou ao menos um registro; 'N' caso contrário.
    IF V_COUNT > 0 THEN
        RETURN 'S';
    ELSE
        RETURN 'N';
    END IF;

END FC_TEMMETA_SPARK;
