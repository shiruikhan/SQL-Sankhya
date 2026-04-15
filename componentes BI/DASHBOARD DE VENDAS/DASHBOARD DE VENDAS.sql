/*==============================================================================
  Nome do Script : DASHBOARD DE VENDAS
  Tipo           : Componente BI — Tabela
  Dashboard      : DASHBOARD DE VENDAS
  Componente     : DASHBOARD DE VENDAS
  Descrição      : Detalhe de vendas com informações de parceiro, produto, preço e volumes

  Parâmetros     : :P_PERIODO.INI — data inicial
                   :P_PERIODO.FIN — data final
                   :P_CODVEND — código do vendedor (opcional)
                   :P_CODGRUPOPROD — código do grupo de produto (opcional)
                   :P_UF — unidade federativa (opcional)
                   :P_CODPARC — código do parceiro (opcional)

  Tabelas        : TGFITE, TGFCAB, TGFPAR, TGFTOP, TSICID, TSIUFS, TGFVEN, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT PAR.CODPARC,
	PAR.NOMEPARC,
	UFS.UF,
	VEN.APELIDO,
	ITE.CODPROD,
	PRO.DESCRPROD,
	CAB.DTNEG,
	ITE.QTDNEG,
	ITE.VLRUNIT*((100-ITE.PERCDESC)/100) AS VLRUNIT,
	NVL(ITE.AD_VLRCHEIO,ITE.VLRUNIT) * ((100-ITE.PERCDESC)/100) AS VLRCHEIODESC,
	TPO.CODTIPOPER,
	TPO.DESCROPER,
	CAB.NUNOTA,
	CAB.NUMNOTA
FROM TGFITE ITE
	INNER JOIN TGFCAB CAB ON ITE.NUNOTA = CAB.NUNOTA
	INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
	INNER JOIN TGFTOP TPO ON (TPO.CODTIPOPER = CAB.CODTIPOPER AND TPO.DHALTER = CAB.DHTIPOPER)
	INNER JOIN TSICID CID ON PAR.CODCID = CID.CODCID
	INNER JOIN TSIUFS UFS ON CID.UF = UFS.CODUF
	INNER JOIN TGFVEN VEN ON CAB.CODVEND = VEN.CODVEND
	INNER JOIN TGFPRO PRO ON ITE.CODPROD = PRO.CODPROD
WHERE ((CAB.DTNEG >= :P_PERIODO.INI) AND (CAB.DTNEG <= :P_PERIODO.FIN))
	AND UPPER(TPO.GRUPO) IN ('VENDAS')	
	AND ((:P_CODVEND IS NULL) OR (CAB.CODVEND = :P_CODVEND))
	AND ((:P_CODGRUPOPROD IS NULL) OR (PRO.CODGRUPOPROD = :P_CODGRUPOPROD))
	AND ((:P_UF IS NULL) OR (UFS.CODUF = :P_UF))
    AND ((:P_CODPARC IS NULL) OR (PAR.CODPARC = :P_CODPARC))
ORDER BY CAB.NUNOTA, ITE.SEQUENCIA