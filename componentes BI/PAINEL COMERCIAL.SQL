/*==============================================================================
  Nome do Script : PAINEL COMERCIAL
  Tipo           : Componente BI — Tabela
  Dashboard      : Painel Comercial
  Descrição      : Painel comercial de pedidos em aberto com estoque
                   atual, simulações de entrega e disponibilidade.

  Parâmetros     : :P_PERIODO.INI — Data inicial
                   :P_PERIODO.FIN — Data final
                   :P_ENTREGA.INI — Data início de entrega prevista (ou NULL)
                   :P_ENTREGA.FIN — Data fim de entrega prevista (ou NULL)
                   :P_CODEMP — Código da empresa (ou NULL para todas)
                   :P_CODPARC — Código do parceiro (ou NULL para todos)
                   :P_SIMULACRO — Data de simulação para cálculo de estoque

  Tabelas        : TGFITE, TGFCAB, TGFPRO, TGFPAR, TGFEST, TPRIPROC, TPRIPA

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.DTPREVENT,
	PAR.CODPARC,
	PAR.RAZAOSOCIAL,
	CAB.CODVEND,
	(SELECT V.APELIDO FROM TGFVEN V WHERE V.CODVEND = CAB.CODVEND) AS VEDEDOR,
	PRO.CODPROD,
	PRO.DESCRPROD,
	PRO.CODVOL,
	ITE.QTDNEG,
	NVL((SELECT SUM(NVL(EST.ESTOQUE,0)) AS ESTOQUEATUAL FROM TGFEST EST WHERE EST.CODPROD = ITE.CODPROD),0) AS ESTOQUEATUAL,
	NVL((SELECT SUM(NVL(EST.ESTOQUE,0)) AS ESTOQUEATUAL FROM TGFEST EST WHERE EST.CODPROD = ITE.CODPROD),0) + 
	NVL((SELECT SUM(IPA.QTDPRODUZIR) - SUM(NVL((SELECT SUM(I.QTDNEG) 
												FROM TGFCAB C 
													INNER JOIN TGFITE I ON (C.NUNOTA = I.NUNOTA) 
												WHERE C.TIPMOV= 'F' 
													AND C.IDIPROC = PROC.IDIPROC 
													AND I.ATUALESTOQUE = 1 
													AND I.CODPROD = IPA.CODPRODPA),0))
		FROM TPRIPROC PROC 
			INNER JOIN TPRIPA IPA ON (PROC.IDIPROC = IPA.IDIPROC) 
		WHERE PROC.STATUSPROC IN ('A','P2') 
			AND IPA.CODPRODPA = ITE.CODPROD
			AND NVL(PROC.DTPREVENT,TRUNC(PROC.DHINC)+ 7) <= :P_SIMULACRO),0) SIMULACRO,
	NVL((SELECT SUM(NVL(EST.ESTOQUE,0)) AS ESTOQUEATUAL FROM TGFEST EST WHERE EST.CODPROD = ITE.CODPROD),0) + 
	NVL((SELECT SUM(IPA.QTDPRODUZIR) - SUM(NVL((SELECT SUM(I.QTDNEG) 
												FROM TGFCAB C 
													INNER JOIN TGFITE I ON (C.NUNOTA = I.NUNOTA) 
												WHERE C.TIPMOV= 'F' 
													AND C.IDIPROC = PROC.IDIPROC 
													AND I.ATUALESTOQUE = 1 
													AND I.CODPROD = IPA.CODPRODPA),0))
		FROM TPRIPROC PROC 
			INNER JOIN TPRIPA IPA ON (PROC.IDIPROC = IPA.IDIPROC) 
		WHERE PROC.STATUSPROC IN ('A','P2') 
			AND IPA.CODPRODPA = ITE.CODPROD
			AND NVL(PROC.DTPREVENT,TRUNC(PROC.DHINC)+ 7) <= CAB.DTPREVENT),0) SIMULACAO		
FROM TGFITE ITE
	INNER JOIN TGFCAB CAB ON (ITE.NUNOTA = CAB.NUNOTA AND CAB.PENDENTE = 'S' AND CAB.TIPMOV = 'P' AND CAB.CODTIPOPER <> 900)
	INNER JOIN TGFPRO PRO ON (ITE.CODPROD = PRO.CODPROD AND PRO.USOPROD='V' AND PRO.ATIVO='S' AND PRO.AD_OBSOLETO = 'N')
	INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
	--LEFT JOIN TGFEST EST ON (PRO.CODPROD = EST.CODPROD AND EST.CODLOCAL = 109)
WHERE (TRUNC(CAB.DTNEG) >= :P_PERIODO.INI AND TRUNC(CAB.DTNEG) <= :P_PERIODO.FIN)
	AND ITE.PENDENTE = 'S'
	AND (:P_ENTREGA IS NULL OR (TRUNC(CAB.DTPREVENT) >= :P_ENTREGA.INI AND TRUNC(CAB.DTPREVENT) <= :P_ENTREGA.FIN))
	AND (:P_CODEMP IS NULL OR CAB.CODEMP = :P_CODEMP)
	AND (:P_CODPARC IS NULL OR CAB.CODPARC = :P_CODPARC)
ORDER BY CAB.CODPARC,
	CAB.NUNOTA,
	ITE.CODPROD