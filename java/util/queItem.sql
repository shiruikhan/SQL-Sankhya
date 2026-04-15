/*==============================================================================
  Nome do Script : queItem.sql
  Tipo           : Query SQL auxiliar (carregada via NativeSql.loadSql)
  Descrição      : Retorna os itens de uma nota fiscal para iteração no processo
                   de geração de séries. Utilizada por TransferenciaUtils.gerarSerie()
                   para percorrer os itens da nota de origem e copiar as séries
                   vinculadas para a nota de destino (transferência).

  Parâmetro      : :NUNOTA — número único da nota de origem (TGFITE.NUNOTA)

  Tabela         : TGFITE
  Colunas        : NUNOTA, SEQUENCIA, CODPROD

  Uso            : TransferenciaUtils.gerarSerie(BigDecimal origem, BigDecimal destino)
  Empresa        : Spark Eletrônica
  Última Revisão : Abril/2026 — Adição de cabeçalho padronizado
==============================================================================*/

SELECT NUNOTA
     , SEQUENCIA
     , CODPROD
  FROM TGFITE
 WHERE NUNOTA = :NUNOTA
 ORDER BY SEQUENCIA ASC
