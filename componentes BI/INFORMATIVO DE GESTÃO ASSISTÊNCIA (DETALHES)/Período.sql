/*==============================================================================
  Nome do Script : Período
  Tipo           : Componente BI — Card
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : Período
  Descrição      : Retorna a quantidade de movimentos de assistência agrupados
                   por mês do período informado.

  Parâmetros     : :P_PERIODO — período (INI/FIN)
                   :P_DTFAB — data de fabricação (INI/FIN)
                   :A_CODGRUPOPROD — código do grupo/produto

  Tabelas        : AD_TGFIASS, AD_TGFASS, TGFPRO, TGFGRU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    TO_CHAR(ASS.DTRECEB, 'Month', 'NLS_DATE_LANGUAGE=PORTUGUESE') AS NOME_MES,
    SUM(IAS.QTDMOV) AS QTDMOV
FROM AD_TGFIASS IAS
    INNER JOIN AD_TGFASS ASS ON IAS.NUMOS = ASS.NUMOS
    LEFT JOIN TGFPRO PRO ON IAS.CODPROD = PRO.CODPROD
    LEFT JOIN TGFGRU GRU ON PRO.CODGRUPOPROD = GRU.CODGRUPOPROD
WHERE ASS.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND (:P_DTFAB.INI IS NULL OR TRUNC(ASS.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(ASS.T_DTFABRICACAO) <= :P_DTFAB.FIN)
    AND ((GRU.CODGRUPOPROD = :A_CODGRUPOPROD) OR (PRO.CODPROD = :A_CODGRUPOPROD))

GROUP BY 
    EXTRACT(MONTH FROM ASS.DTRECEB),
    TO_CHAR(ASS.DTRECEB, 'Month', 'NLS_DATE_LANGUAGE=PORTUGUESE')
ORDER BY 
    EXTRACT(MONTH FROM ASS.DTRECEB),
    SUM(IAS.QTDMOV) DESC