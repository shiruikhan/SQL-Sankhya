/*==============================================================================
  Nome do Script : Componentes do período
  Tipo           : Componente BI — Tabela
  Dashboard      : Informativo de Gestão da Assistência
  Componente     : Componentes do período
  Descrição      : Retorna quantidade total de componentes em assistência
                   por código e grupo de produto no período.

  Parâmetros     : :P_ANO — ano
                   :A_MES — mês
                   :P_DTFAB — data de fabricação (INI/FIN)
                   :P_CODPROD — código do produto
                   :P_CODGRUPOPROD — código do grupo de produto
                   :A_DEFEITO — tipo de defeito

  Tabelas        : AD_TGFIASS, AD_TGFASS, TGFPRO, TGFGRU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    C.CODPROD,
    P.DESCRPROD,
    SUM(C.QTDMOV) AS TOTAL_COMPONENTES,
    G.DESCRGRUPOPROD
FROM
    AD_TGFIASS C
JOIN
    AD_TGFASS F ON F.NUMOS = C.NUMOS
LEFT JOIN
    TGFPRO P ON P.CODPROD = C.CODPROD
LEFT JOIN 
    TGFGRU G ON P.CODGRUPOPROD = G.CODGRUPOPROD
LEFT JOIN
    TGFPRO PRD ON PRD.CODPROD = F.T_CODPROD
WHERE
    F.DTRECEB IS NOT NULL
    AND EXTRACT(YEAR FROM F.DTRECEB) = :P_ANO
    AND EXTRACT(MONTH FROM F.DTRECEB) = :A_MES
	AND ( :P_DTFAB.INI IS NULL OR TRUNC(T_DTFABRICACAO) >= :P_DTFAB.INI )
    AND ( :P_DTFAB.FIN IS NULL OR TRUNC(T_DTFABRICACAO) <= :P_DTFAB.FIN )
	AND ( :P_CODPROD IS NULL OR F.T_CODPROD = :P_CODPROD )
	AND ( :P_CODGRUPOPROD IS NULL OR PRD.CODGRUPOPROD = :P_CODGRUPOPROD )
    AND ( :A_DEFEITO = 'NULL' OR F.DEFEITO = :A_DEFEITO)
GROUP BY
    C.CODPROD,
    P.DESCRPROD,
    G.DESCRGRUPOPROD
ORDER BY
    TOTAL_COMPONENTES DESC
