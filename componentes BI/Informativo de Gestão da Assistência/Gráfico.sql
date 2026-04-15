/*==============================================================================
  Nome do Script : Gráfico
  Tipo           : Componente BI — Gráfico
  Dashboard      : Informativo de Gestão da Assistência
  Componente     : Gráfico
  Descrição      : Retorna série temporal de ordens de assistência por tipo
                   de defeito para visualização em gráfico mensal.

  Parâmetros     : :P_ANO — ano
                   :P_DTFAB — data de fabricação (INI/FIN)
                   :P_CODPROD — código do produto
                   :P_CODGRUPOPROD — código do grupo de produto

  Tabelas        : AD_TGFASS, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    TO_CHAR(A.DTRECEB, 'MM') AS MES,
    TO_CHAR(TO_DATE(TO_CHAR(A.DTRECEB, 'MM'), 'MM'), 'fmMonth', 'NLS_DATE_LANGUAGE=PORTUGUESE') AS MES_EXTENSO,
    COUNT(A.NUMOS) AS TOTAL_OS,
    SUM(CASE WHEN A.DEFEITO = 'ATT' THEN 1 ELSE 0 END) AS QTD_ATT,
    SUM(CASE WHEN A.DEFEITO = 'MU' THEN 1 ELSE 0 END) AS QTD_MU,
    SUM(CASE WHEN A.DEFEITO = 'DC' THEN 1 ELSE 0 END) AS QTD_DC,
    SUM(CASE WHEN A.DEFEITO = 'FAB' THEN 1 ELSE 0 END) AS QTD_FAB,
    SUM(CASE WHEN A.DEFEITO = 'SD' OR A.DEFEITO IS NULL THEN 1 ELSE 0 END) AS QTD_SD
FROM AD_TGFASS A
    LEFT JOIN TGFPRO P ON A.T_CODPROD = P.CODPROD
WHERE A.DTRECEB IS NOT NULL
    AND EXTRACT(YEAR FROM A.DTRECEB) = :P_ANO
    AND (:P_DTFAB.INI IS NULL OR TRUNC(A.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(A.T_DTFABRICACAO) <= :P_DTFAB.FIN)
    AND (:P_CODPROD IS NULL OR T_CODPROD = :P_CODPROD)
    AND (:P_CODGRUPOPROD IS NULL OR P.CODGRUPOPROD = :P_CODGRUPOPROD)
GROUP BY TO_CHAR(DTRECEB, 'MM'),
    TO_CHAR(TO_DATE(TO_CHAR(DTRECEB, 'MM'), 'MM'), 'fmMonth', 'NLS_DATE_LANGUAGE=PORTUGUESE')
ORDER BY TO_CHAR(DTRECEB, 'MM')
