/*==============================================================================
  Nome do Script : Produtos do período
  Tipo           : Componente BI — Tabela
  Dashboard      : Informativo de Gestão da Assistência
  Componente     : Produtos do período
  Descrição      : Retorna quantidade de ordens de assistência agrupadas
                   por produto no período, com tratamento de código.

  Parâmetros     : :P_ANO — ano
                   :A_MES — mês
                   :P_DTFAB — data de fabricação (INI/FIN)
                   :P_CODPROD — código do produto
                   :P_CODGRUPOPROD — código do grupo de produto
                   :A_DEFEITO — tipo de defeito

  Tabelas        : AD_TGFASS, TGFPRO, TGFGRU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    CASE
        WHEN F.T_CODPROD IS NOT NULL AND SUBSTR(TO_CHAR(F.T_CODPROD), 1, 1) = '3' THEN
            TO_NUMBER(SUBSTR(TO_CHAR(F.T_CODPROD), 1, 1) ||
                      '1' ||
                      SUBSTR(TO_CHAR(F.T_CODPROD), 3))
        ELSE F.T_CODPROD
    END AS CODPROD_TRATADO,
    P.DESCRPROD,
    COUNT(F.NUMOS) AS TOTAL_OS,
    G.DESCRGRUPOPROD
FROM
    AD_TGFASS F
LEFT JOIN
    TGFPRO P ON P.CODPROD = CASE 
                                WHEN F.T_CODPROD IS NOT NULL AND SUBSTR(TO_CHAR(F.T_CODPROD), 1, 1) = '3' THEN 
                                    TO_NUMBER(SUBSTR(TO_CHAR(F.T_CODPROD), 1, 1) || 
                                              '1' || 
                                              SUBSTR(TO_CHAR(F.T_CODPROD), 3))
                                ELSE F.T_CODPROD
                            END
    LEFT JOIN TGFGRU G ON P.CODGRUPOPROD = G.CODGRUPOPROD
WHERE
    F.DTRECEB IS NOT NULL
    AND EXTRACT(YEAR FROM F.DTRECEB) = :P_ANO
    AND EXTRACT(MONTH FROM F.DTRECEB) = :A_MES
	AND ( :P_DTFAB.INI IS NULL OR TRUNC(T_DTFABRICACAO) >= :P_DTFAB.INI )
    AND ( :P_DTFAB.FIN IS NULL OR TRUNC(T_DTFABRICACAO) <= :P_DTFAB.FIN )
	AND ( :P_CODPROD IS NULL OR T_CODPROD = :P_CODPROD )
	AND ( :P_CODGRUPOPROD IS NULL OR P.CODGRUPOPROD = :P_CODGRUPOPROD )
    AND ( :A_DEFEITO = 'NULL' OR F.DEFEITO = :A_DEFEITO)
GROUP BY
    CASE 
        WHEN F.T_CODPROD IS NOT NULL AND SUBSTR(TO_CHAR(F.T_CODPROD), 1, 1) = '3' THEN 
            TO_NUMBER(SUBSTR(TO_CHAR(F.T_CODPROD), 1, 1) || 
                      '1' || 
                      SUBSTR(TO_CHAR(F.T_CODPROD), 3))
        ELSE F.T_CODPROD
    END,
    P.DESCRPROD,
    G.DESCRGRUPOPROD
ORDER BY
    TOTAL_OS DESC
