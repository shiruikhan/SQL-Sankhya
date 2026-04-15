/*==============================================================================
  Nome do Script : RELACAO DE COMPRAS-PEDIDOS E PREVISAO DE ENTREGA
  Tipo           : Componente BI — Tabela
  Dashboard      : Gestão de Compras e Fornecedores
  Descrição      : Relação de pedidos de compra por fornecedor com valores
                   agrupados por mês de previsão de entrega.

  Parâmetros     : :P_ANO — ano de referência para filtro (NUMBER)

  Tabelas        : TGFCAB, TGFPAR (principais)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT V.CODPARC,
	V.RAZAOSOCIAL,
	SUM(CASE WHEN V.MES = 1 THEN V.VLRNEG ELSE 0 END) AS JANEIRO,
	SUM(CASE WHEN V.MES = 2 THEN V.VLRNEG ELSE 0 END) AS FEVEREIRO,
	SUM(CASE WHEN V.MES = 3 THEN V.VLRNEG ELSE 0 END) AS MAR,
	SUM(CASE WHEN V.MES = 4 THEN V.VLRNEG ELSE 0 END) AS ABRIL,
	SUM(CASE WHEN V.MES = 5 THEN V.VLRNEG ELSE 0 END) AS MAIO,
	SUM(CASE WHEN V.MES = 6 THEN V.VLRNEG ELSE 0 END) AS JUNHO,
	SUM(CASE WHEN V.MES = 7 THEN V.VLRNEG ELSE 0 END) AS JULHO,
	SUM(CASE WHEN V.MES = 8 THEN V.VLRNEG ELSE 0 END) AS AGOSTO,
	SUM(CASE WHEN V.MES = 9 THEN V.VLRNEG ELSE 0 END) AS SETEMBRO,
	SUM(CASE WHEN V.MES = 10 THEN V.VLRNEG ELSE 0 END) AS OUTUBRO,
	SUM(CASE WHEN V.MES = 11 THEN V.VLRNEG ELSE 0 END) AS NOVEMBRO,
	SUM(CASE WHEN V.MES = 12 THEN V.VLRNEG ELSE 0 END) AS DEZEMBRO
FROM (
	SELECT 
		CAB.CODPARC,
        PAR.RAZAOSOCIAL,
		SUM(COALESCE(CAB.VLRNOTA,0) + COALESCE(CAB.VLROUTROS,0)) AS VLRNEG,
		EXTRACT(MONTH FROM CAB.DTPREVENT) AS MES,
		EXTRACT(YEAR FROM CAB.DTPREVENT) AS ANO
	FROM TGFCAB CAB
		INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
	WHERE
		CAB.TIPMOV = 'O'
		AND CAB.DTPREVENT IS NOT NULL
		AND CAB.PENDENTE = 'S'
        AND CAB.STATUSNOTA = 'L'
	GROUP BY 
        CAB.CODPARC,
        PAR.RAZAOSOCIAL,
		EXTRACT(MONTH FROM CAB.DTPREVENT),
		EXTRACT(YEAR FROM CAB.DTPREVENT)
	) V
WHERE V.ANO = :P_ANO
GROUP BY V.CODPARC,
	V.RAZAOSOCIAL
ORDER BY V.CODPARC
