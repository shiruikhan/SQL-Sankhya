/*==============================================================================
  Nome do Script : p1
  Tipo           : Componente BI — Tabela
  Dashboard      : ADIANTAMENTO FORNECEDOR
  Componente     : P1
  Descrição      : Lista adiantamentos e empréstimos de fornecedores com detalhes de natureza, datas e usuário

  Parâmetros     : :P_CODPARC — código do parceiro (opcional)
                   :DATA.INI — data inicial
                   :DATA.FIN — data final

  Tabelas        : TGFFIN, TGFPAR, TGFNAT, TSIUSU, TGFFRE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT FIN.NUFIN, 	
	FIN.NUCOMPENS,
	FIN.CODPARC,
	PAR.NOMEPARC,
	FIN.NUMDUPL AS NROADTO,
	NAT.DESCRNAT,
	FIN.DTNEG,
	FIN.CODEMP,
	FIN.VLRDESDOB,
	USU.NOMEUSU AS USUADTO,
	FIN.HISTORICO,
    (CASE WHEN FIN.RECDESP = 1 THEN 'ADIANTAMENTO' ELSE 'EMPRESTIMO' END) AS RECDESP
FROM TGFFIN FIN
	INNER JOIN TGFPAR PAR ON PAR.CODPARC = FIN.CODPARC
	INNER JOIN TGFNAT NAT ON NAT.CODNAT = FIN.CODNAT
	INNER JOIN TSIUSU USU ON USU.CODUSU = FIN.CODUSU
    INNER JOIN TGFFRE FRE ON FIN.NUFIN = FRE.NUFIN AND FRE.SEQUENCIA = 1
WHERE (PAR.CODPARC = :P_CODPARC OR :P_CODPARC IS NULL)
	AND FIN.DTNEG >= :DATA.INI
    AND FIN.DTNEG <= :DATA.FIN
    AND FIN.NUCOMPENS IS NOT NULL
ORDER BY FIN.NUMDUPL,
	FIN.DTNEG