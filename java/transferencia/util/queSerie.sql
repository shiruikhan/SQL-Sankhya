/*==============================================================================
  Nome do Script : queSerie.sql
  Tipo           : Query SQL auxiliar (carregada via NativeSql.loadSql)
  Descrição      : Retorna as séries de um produto em uma nota fiscal específica.
                   Utilizada por TransferenciaUtils.gerarSerie() para copiar as
                   séries do item da nota de origem para o item correspondente
                   na nota de destino da transferência.

  Parâmetros     : :NUNOTA    — número único da nota de origem (TGFSER.NUNOTA)
                   :SEQUENCIA — sequência do item na nota (TGFSER.SEQUENCIA)
                   :CODPROD   — código do produto (TGFSER.CODPROD)

  Tabela         : TGFSER — controle de séries de produtos
  Colunas        : NUNOTA, SEQUENCIA, CODPROD, SERIE, ATUALESTOQUE

  Uso            : TransferenciaUtils.gerarSerie(BigDecimal origem, BigDecimal destino)
  Empresa        : Spark Eletrônica
  Última Revisão : Abril/2026 — Adição de cabeçalho padronizado
==============================================================================*/

SELECT NUNOTA,
       SEQUENCIA,
       CODPROD,
       SERIE,
       ATUALESTOQUE
  FROM TGFSER
 WHERE NUNOTA     = :NUNOTA
   AND SEQUENCIA  = :SEQUENCIA
   AND CODPROD    = :CODPROD
