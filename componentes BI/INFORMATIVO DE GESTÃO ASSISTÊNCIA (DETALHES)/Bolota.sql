/*==============================================================================
  Nome do Script : Bolota
  Tipo           : Componente BI — Gráfico
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : Bolota
  Descrição      : Distribuição de movimentações por peça utilizada em assistência
                   com filtros por grupo de matéria-prima e produto acabado.

  Parâmetros     : :P_PERIODO.INI e :P_PERIODO.FIN — Período de análise
                   :P_DTFAB.INI e :P_DTFAB.FIN — Filtro por data de fabricação (opcional)
                   :P_CODGRUPOMAPROD — Filtro por grupo da matéria-prima (opcional)
                   :P_CODGRUPOPROD — Filtro por grupo do produto acabado (opcional)

  Tabelas        : AD_TGFIASS, AD_TGFASS, TGFPRO, TGFGRU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT PRO.DESCRPROD,
    PRO.CODPROD,
    SUM(IAS.QTDMOV) AS QTDMOV
FROM AD_TGFIASS IAS
    INNER JOIN AD_TGFASS ASS ON IAS.NUMOS = ASS.NUMOS
    LEFT JOIN TGFPRO PRO ON IAS.CODPROD = PRO.CODPROD
    LEFT JOIN TGFGRU GRU ON PRO.CODGRUPOPROD = GRU.CODGRUPOPROD
    LEFT JOIN TGFPRO PROPA ON ASS.T_CODPROD = PROPA.CODPROD
    LEFT JOIN TGFGRU GRUPA ON PROPA.CODGRUPOPROD = GRUPA.CODGRUPOPROD
WHERE ASS.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN    
    AND (:P_DTFAB.INI IS NULL OR TRUNC(ASS.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(ASS.T_DTFABRICACAO) <= :P_DTFAB.FIN)
    AND (:P_CODGRUPOMAPROD IS NULL OR PRO.CODGRUPOPROD = :P_CODGRUPOMAPROD)
    AND (:P_CODGRUPOPROD IS NULL OR PROPA.CODGRUPOPROD = :P_CODGRUPOPROD)
GROUP BY PRO.DESCRPROD, PRO.CODPROD
ORDER BY SUM(IAS.QTDMOV) DESC
