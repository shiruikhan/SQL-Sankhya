/*==============================================================================
  Nome do Script : painelcomponentes
  Tipo           : Componente BI — Tabela
  Dashboard      : INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA
  Componente     : painelcomponentes
  Descrição      : Retorna total de movimentos de assistência externa
                   por componente/produto.

  Parâmetros     : :P_PERIODO — período (INI/FIN)
                   :P_CODPARC — código do parceiro/fornecedor

  Tabelas        : AD_SPKICAE, TGFPRO, AD_SPKCAE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT IA.CODPROD,
    P.DESCRPROD,
    SUM(IA.QTDMOV) AS TOTAL
FROM AD_SPKICAE IA
    INNER JOIN TGFPRO P ON IA.CODPROD = P.CODPROD
    INNER JOIN AD_SPKCAE A ON IA.NUMOS = A.NUMOS
WHERE (:P_PERIODO.INI IS NULL OR A.DTCONCLUSAO >= :P_PERIODO.INI)
    AND (:P_PERIODO.FIN IS NULL OR A.DTCONCLUSAO <= :P_PERIODO.FIN)
    AND (:P_CODPARC IS NULL OR A.CODPARC = :P_CODPARC)
GROUP BY IA.CODPROD, P.DESCRPROD
