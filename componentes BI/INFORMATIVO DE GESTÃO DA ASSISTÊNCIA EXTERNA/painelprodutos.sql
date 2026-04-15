/*==============================================================================
  Nome do Script : painelprodutos
  Tipo           : Componente BI — Tabela
  Dashboard      : INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA
  Componente     : painelprodutos
  Descrição      : Retorna quantidade de ordens de assistência externa
                   agrupadas por produto.

  Parâmetros     : :P_PERIODO — período (INI/FIN)
                   :P_CODPARC — código do parceiro/fornecedor

  Tabelas        : AD_SPKCAE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT A.T_CODPROD,
    A.T_DESCRPROD,
    COUNT(A.NUMOS) AS TOTAL
FROM AD_SPKCAE A
WHERE (:P_PERIODO.INI IS NULL OR A.DTCONCLUSAO >= :P_PERIODO.INI)
    AND (:P_PERIODO.FIN IS NULL OR A.DTCONCLUSAO <= :P_PERIODO.FIN)
    AND (:P_CODPARC IS NULL OR A.CODPARC = :P_CODPARC)
GROUP BY A.T_CODPROD, A.T_DESCRPROD
