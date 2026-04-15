/*==============================================================================
  Nome do Script : Operadores
  Tipo           : Componente BI — Tabela
  Dashboard      : Informativo de Gestão da Assistência
  Componente     : Operadores
  Descrição      : Retorna quantidade de ordens de assistência processadas
                   por técnico/operador no período.

  Parâmetros     : :P_ANO — ano
                   :A_MES — mês
                   :P_DTFAB — data de fabricação (INI/FIN)
                   :P_CODPROD — código do produto
                   :P_CODGRUPOPROD — código do grupo de produto
                   :A_DEFEITO — tipo de defeito

  Tabelas        : AD_TGFASS, AD_CADFUNC, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    F.TECNICO AS IDFUNC,
    C.NOME AS NOME_TECNICO,
    COUNT(F.NUMOS) AS TOTAL_OS
FROM
    AD_TGFASS F
JOIN
    AD_CADFUNC C ON C.IDFUNC = F.TECNICO
LEFT JOIN
	TGFPRO P ON F.T_CODPROD = P.CODPROD
WHERE
    F.DTRECEB IS NOT NULL
    AND F.TECNICO IS NOT NULL
    AND EXTRACT(YEAR FROM F.DTRECEB) = :P_ANO
    AND EXTRACT(MONTH FROM F.DTRECEB) = :A_MES
    AND ( :P_DTFAB.INI IS NULL OR TRUNC(T_DTFABRICACAO) >= :P_DTFAB.INI )
    AND ( :P_DTFAB.FIN IS NULL OR TRUNC(T_DTFABRICACAO) <= :P_DTFAB.FIN )
	AND ( :P_CODPROD IS NULL OR T_CODPROD = :P_CODPROD )
	AND ( :P_CODGRUPOPROD IS NULL OR P.CODGRUPOPROD = :P_CODGRUPOPROD )
    AND ( :A_DEFEITO = 'NULL' OR F.DEFEITO = :A_DEFEITO)
GROUP BY
    F.TECNICO,
    C.NOME
ORDER BY
    TOTAL_OS DESC
