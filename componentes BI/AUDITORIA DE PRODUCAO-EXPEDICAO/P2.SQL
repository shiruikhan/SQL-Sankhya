/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela
  Dashboard      : AUDITORIA DE PRODUCAO-EXPEDICAO
  Componente     : P2
  Descrição      : Expedição/conferência apontada por produto e apontador

  Parâmetros     : :P_DTBASE — data base para o apontamento

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TGFPRO, TSIUSU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT PRO.CODPROD,
	PRO.DESCRPROD,
	SUM(APA.QTDAPONTADA) AS PRODUCAO,
	APO.CODUSU || ' - ' || (SELECT NOMEUSU FROM TSIUSU WHERE CODUSU = APO.CODUSU) AS APONTADOR
FROM TPRAPA APA
	INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO
	INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV
	INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX
	INNER JOIN TGFPRO PRO ON APA.CODPRODPA = PRO.CODPROD
WHERE TRUNC(APO.DHAPO) = TO_CHAR(:P_DTBASE, 'DD/MM/YYYY')
	AND FX.DESCRICAO IN ('EXPEDIÇÃO/CONFERENCIA')
GROUP BY PRO.CODPROD,
	PRO.DESCRPROD,
	APO.CODUSU
ORDER BY PRO.CODPROD