/*==============================================================================
  Nome do Script : donut
  Tipo           : Componente BI — Gráfico
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : ProdAcabado/donut
  Descrição      : Retorna distribuição de tipos de defeitos encontrados
                   em produtos acabados em formato de gráfico donut.

  Parâmetros     : :P_PERIODO — período (INI/FIN)
                   :P_DTFAB — data de fabricação (INI/FIN)
                   :A_AGRUPADOR — agrupador de produtos
                   :P_CODGRUPOPROD — código do grupo de produtos

  Tabelas        : AD_TGFASS, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    L.LABEL AS LABEL,
    SUM(CASE WHEN NVL(A.DEFEITO, 'SD') = L.CODE THEN 1 ELSE 0 END) AS VALUE
FROM AD_TGFASS A
    LEFT JOIN TGFPRO P ON A.T_CODPROD = P.CODPROD
    CROSS JOIN (
        SELECT 'ATT' AS CODE, 'Necessidade de Atualização' AS LABEL FROM DUAL
        UNION ALL SELECT 'MU' AS CODE, 'Mau Uso' AS LABEL FROM DUAL
        UNION ALL SELECT 'DC' AS CODE, 'Desgaste (Cronológico)' AS LABEL FROM DUAL
        UNION ALL SELECT 'FAB' AS CODE, 'Montagem (Fábrica)' AS LABEL FROM DUAL
        UNION ALL SELECT 'SD' AS CODE, 'Sem Defeito' AS LABEL FROM DUAL
    ) L
WHERE A.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND (:P_DTFAB.INI IS NULL OR TRUNC(A.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(A.T_DTFABRICACAO) <= :P_DTFAB.FIN)
    AND (:A_AGRUPADOR IS NULL OR P.AD_AGRUPADOR = :A_AGRUPADOR)
    AND (:P_CODGRUPOPROD IS NULL OR P.CODGRUPOPROD = :P_CODGRUPOPROD)
GROUP BY L.LABEL, L.CODE
ORDER BY CASE L.CODE WHEN 'ATT' THEN 1 WHEN 'MU' THEN 2 WHEN 'DC' THEN 3 WHEN 'FAB' THEN 4 WHEN 'SD' THEN 5 END
