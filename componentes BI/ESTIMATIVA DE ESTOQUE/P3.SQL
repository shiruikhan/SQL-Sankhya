/*==============================================================================
  Nome do Script : P3
  Tipo           : Componente BI — Tabela
  Dashboard      : ESTIMATIVA DE ESTOQUE
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

WITH EntregasProc AS (
    SELECT C.IDIPROC, I.CODPROD, SUM(I.QTDNEG) AS QTD_ENTREGUE
    FROM TGFCAB C
    INNER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA
    WHERE C.TIPMOV = 'F'
      AND I.ATUALESTOQUE = 1
      AND C.CODTIPOPER <> 900
    GROUP BY C.IDIPROC, I.CODPROD
)
SELECT IPA.IDIPROC,
       IPA.NROLOTE,
       IPA.QTDPRODUZIR - COALESCE(E.QTD_ENTREGUE, 0) AS QTDPRODUZIR,
       PROC.DTPREVENT,
       PROC.NUMPS
FROM TPRIPROC PROC
INNER JOIN TPRIPA IPA ON PROC.IDIPROC = IPA.IDIPROC
LEFT JOIN EntregasProc E ON E.IDIPROC = PROC.IDIPROC AND E.CODPROD = IPA.CODPRODPA
WHERE PROC.STATUSPROC IN ('A','P2')
  AND IPA.CODPRODPA = :A_CODPROD
