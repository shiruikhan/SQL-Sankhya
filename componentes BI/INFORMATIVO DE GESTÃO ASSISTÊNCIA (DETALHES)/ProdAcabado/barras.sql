/*==============================================================================
  Nome do Script : barras
  Tipo           : Componente BI — Gráfico
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : ProdAcabado/barras
  Descrição      : Retorna quantidade de assistências por produto acabado
                   em formato de gráfico de barras.

  Parâmetros     : :P_PERIODO — período (INI/FIN)
                   :P_DTFAB — data de fabricação (INI/FIN)

  Tabelas        : AD_TGFASS, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT COUNT(ASS.NUMOS) AS QTD,
    PRO.AD_AGRUPADOR AS DESCRPROD
    
FROM AD_TGFASS ASS
    LEFT JOIN TGFPRO PRO ON ASS.T_CODPROD = PRO.CODPROD
WHERE ASS.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND (:P_DTFAB.INI IS NULL OR TRUNC(ASS.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(ASS.T_DTFABRICACAO) <= :P_DTFAB.FIN)
GROUP BY PRO.AD_AGRUPADOR
ORDER BY COUNT(ASS.NUMOS) DESC