/*==============================================================================
  Nome do Script : p2
  Tipo           : Componente BI — Tabela
  Dashboard      : ADIANTAMENTO FORNECEDOR
  Componente     : P2
  Descrição      : Detalhes de compensação de adiantamentos com informações de natureza e usuário

  Parâmetros     : :A_NUCOMPENS — número de compensação

  Tabelas        : TGFFIN, TGFPAR, TGFNAT, TSIUSU, TGFFRE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT FIN.NUFIN,
	FIN.CODEMP,
	FIN.CODPARC,
	PAR.NOMEPARC,
    FIN.NUCOMPENS,
	FIN.NUMNOTA,
	FIN.VLRDESDOB,
	FIN.DTNEG,
	FIN.HISTORICO,
	NAT.DESCRNAT,
	FIN.CODUSU||' - '|| USU.NOMEUSU AS USUARIO,
    (CASE WHEN FIN.RECDESP = 1 THEN 'RECEITA' ELSE 'DESPESA' END) AS RECDESP
FROM TGFFIN FIN	
	INNER JOIN TGFPAR PAR ON PAR.CODPARC = FIN.CODPARC
	INNER JOIN TGFNAT NAT ON NAT.CODNAT = FIN.CODNAT
    INNER JOIN TSIUSU USU ON USU.CODUSU = FIN.CODUSU
    INNER JOIN TGFFRE FRE ON FIN.NUCOMPENS = FRE.NUACERTO
WHERE FIN.NUCOMPENS = :A_NUCOMPENS