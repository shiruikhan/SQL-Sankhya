/*==============================================================================
  Nome do Script : P3
  Tipo           : Componente BI — Tabela
  Dashboard      : ESTIMATIVA DE ESTOQUE GERENCIAL
  Componente     : P3
  Descrição      : Produções em processo com quantidade pendente (planejado menos
                   já entregue) para um produto específico.

  Parâmetros     : :A_CODPROD — Código do produto para filtro

  Tabelas        : TPRIPROC, TPRIPA, TGFCAB, TGFITE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT IPA.IDIPROC,IPA.NROLOTE, IPA.QTDPRODUZIR-NVL((SELECT SUM(I.QTDNEG) FROM TGFCAB C INNER JOIN TGFITE I ON (C.NUNOTA=I.NUNOTA) WHERE C.TIPMOV='F' AND C.IDIPROC= PROC.IDIPROC AND I.ATUALESTOQUE=1 AND I.CODPROD = IPA.CODPRODPA AND C.CODTIPOPER <> 900),0) AS QTDPRODUZIR ,PROC.DTPREVENT
FROM TPRIPROC PROC INNER JOIN  TPRIPA IPA ON (PROC.IDIPROC = IPA.IDIPROC)
WHERE PROC.STATUSPROC IN ('A','P2')
 AND IPA.CODPRODPA = :A_CODPROD