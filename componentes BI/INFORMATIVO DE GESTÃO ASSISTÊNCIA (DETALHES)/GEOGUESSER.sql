/*==============================================================================
  Nome do Script : GEOGUESSER
  Tipo           : Componente BI — Gráfico
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : GEOGUESSER
  Descrição      : Distribuição geográfica de ordens de serviço por estado (UF)
                   com mapa de calor de incidências por período.

  Parâmetros     : :P_PERIODO.INI e :P_PERIODO.FIN — Período de análise
                   :P_DTFAB.INI e :P_DTFAB.FIN — Filtro por data de fabricação (opcional)

  Tabelas        : AD_TGFASS, TGFPAR, TSICID, TSIUFS

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT COUNT(ASS.NUMOS) AS QTD,
    CID.UF AS CODUF,
    UFS.UF AS UF
FROM AD_TGFASS ASS
    INNER JOIN TGFPAR PAR ON ASS.CODPARC = PAR.CODPARC
    LEFT JOIN TSICID CID ON PAR.CODCID = CID.CODCID
    LEFT JOIN TSIUFS UFS ON CID.UF = UFS.CODUF
WHERE ASS.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND (:P_DTFAB.INI IS NULL OR TRUNC(ASS.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(ASS.T_DTFABRICACAO) <= :P_DTFAB.FIN)
GROUP BY UFS.UF,
    CID.UF
ORDER BY COUNT(ASS.NUMOS) DESC