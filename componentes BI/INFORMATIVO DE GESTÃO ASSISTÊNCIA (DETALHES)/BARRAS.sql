/*==============================================================================
  Nome do Script : BARRAS
  Tipo           : Componente BI — Gráfico
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : BARRAS
  Descrição      : Contagem de ordens de serviço por produto para um cliente
                   específico em período determinado.

  Parâmetros     : :P_PERIODO.INI e :P_PERIODO.FIN — Período de análise
                   :P_DTFAB.INI e :P_DTFAB.FIN — Filtro por data de fabricação (opcional)
                   :A_CODPARC — Código do cliente (parceiro) para filtro

  Tabelas        : AD_TGFASS, TGFPAR, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT COUNT(ASS.NUMOS) AS QTD,
    ASS.CODPARC,
    PRO.DESCRPROD
FROM AD_TGFASS ASS
    LEFT JOIN TGFPAR PAR ON ASS.CODPARC = PAR.CODPARC
    LEFT JOIN TGFPRO PRO ON ASS.T_CODPROD = PRO.CODPROD
WHERE ASS.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND (:P_DTFAB.INI IS NULL OR TRUNC(ASS.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(ASS.T_DTFABRICACAO) <= :P_DTFAB.FIN)
    AND :A_CODPARC = ASS.CODPARC
GROUP BY ASS.CODPARC,
    PRO.DESCRPROD
ORDER BY COUNT(ASS.NUMOS) DESC