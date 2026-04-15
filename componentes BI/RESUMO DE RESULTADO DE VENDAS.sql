/*==============================================================================
  Nome do Script : RESUMO DE RESULTADO DE VENDAS
  Tipo           : Componente BI — Tabela
  Dashboard      : Análise de Resultados de Vendas
  Descrição      : Resumo de faturamento e resultado por nota fiscal de venda,
                   com valores e margens de lucro desagregados.

  Parâmetros     : :P_CODPARC — código do cliente (optional)
                   :P_PERIODO.INI — data inicial (DATE)
                   :P_PERIODO.FIN — data final (DATE)
                   :P_CODEMP — código da empresa (optional)
                   :P_CODVEND — código do vendedor (optional)

  Tabelas        : TGFCAB, TGFITE, TGFPAR, TSICID, TSIUFS, TGFPRO (principais)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT DISTINCT CAB.NUMNOTA,
	MAX(ITE.CODCFO) AS CFOP,
	CAB.DTNEG,
	PAR.CODPARC || ' - ' || PAR.RAZAOSOCIAL AS PARCEIRO,
	UFS.UF,
	SUM(ITE.VLRTOT - ITE.VLRDESC) AS VLRNOTA,
    CAB.VLRIPI,
    CAB.VLRFRETE,
    NVL(CAB.AD_VLROUTROSFRETE,0) AS AD_VLROUTROSFRETE,
    SUM(NVL(ITE.AD_VLROUTROS,0)) AS VLROUTROS,
    SUM(ITE.VLRTOT - ITE.VLRDESC) + SUM(NVL(ITE.AD_VLROUTROS,0)) AS VLR_TOTAL,
	SUM(ITE.QTDNEG) AS QUANTIDADE,
	NVL(CAB.AD_RESULTADO,0) AS RESULTADO,
    CAB.VLRSUBST
FROM TGFCAB CAB
	INNER JOIN TGFITE ITE ON CAB.NUNOTA = ITE.NUNOTA	
	INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
	INNER JOIN TSICID CID ON PAR.CODCID = CID.CODCID
	INNER JOIN TSIUFS UFS ON CID.UF = UFS.CODUF
    INNER JOIN TGFPRO PRO ON ITE.CODPROD = PRO.CODPROD
WHERE (:P_CODPARC IS NULL OR CAB.CODPARC = :P_CODPARC)
	AND CAB.DTNEG >= :P_PERIODO.INI
	AND CAB.DTNEG <= :P_PERIODO.FIN
	AND CAB.STATUSNOTA = 'L'
	AND CAB.CODTIPOPER IN (1100,2200,1111,1190,1124,2202)
	AND (:P_CODEMP IS NULL OR CAB.CODEMP = :P_CODEMP)
    AND PRO.USOPROD = 'V'
	AND (CAB.CODVEND = :P_CODVEND OR :P_CODVEND IS NULL)
GROUP BY CAB.NUMNOTA,
	CAB.DTNEG,
	PAR.CODPARC || ' - ' || PAR.RAZAOSOCIAL,
	UFS.UF,
    CAB.VLRIPI,
    CAB.VLRFRETE,
    CAB.AD_VLROUTROSFRETE,
	NVL(CAB.AD_RESULTADO,0),
    CAB.VLRSUBST,
	(CASE WHEN CAB.AD_RESULTADO > 0 THEN (CAB.AD_RESULTADO / (CAB.VLRNOTA + NVL(CAB.VLROUTROS,0)))*100 ELSE 0 END)