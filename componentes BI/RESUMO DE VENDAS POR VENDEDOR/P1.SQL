/*==============================================================================
  Nome do Script : RESUMO DE VENDAS POR VENDEDOR — P1 (Resumo por Gerente)
  Tipo           : Componente BI — Tabela
  Dashboard      : Resumo de Vendas por Vendedor
  Descrição      : Visão gerencial do comercial: consolida o total de notas
                   faturadas, total de produtos vendidos e total faturado no
                   período, agrupado por GERENTE (TGFVEN.CODGER). Cada linha
                   soma as vendas de todos os vendedores subordinados àquele
                   gerente. Vendedores sem gerente cadastrado são agrupados
                   na linha "SEM GERENTE".
                   É o nível mais alto do painel; drill para P2 (resumo por
                   vendedor) pelo clique sobre o gerente (:A_CODGER).

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (filtro USOPROD)
                   TGFVEN -- cadastro de vendedores; auto-relacionada por
                            CODGER para agrupar por gerente

  Uso            : Painel BI "Resumo de Vendas por Vendedor" — visão
                   gerencial por gerente; drill para P2 pelo campo CODGER
                   (:A_CODGER).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026

  Observações    : - CODTIPOPER de venda e STATUSNOTA = 'L' seguem o mesmo
                     critério usado nos demais componentes de faturamento do
                     repositório (ex.: RESUMO DE RESULTADO DE VENDAS,
                     FATURAMENTO POR PERIODO) e o restante deste dashboard.
                   - CODGER = -1 é o sentinel usado para agrupar vendedores
                     sem gerente cadastrado (GER.CODVEND é NULL nesse caso).
                     Ele precisa ser tratado de forma simétrica em P2 ao
                     receber o clique (:A_CODGER = -1 → filtrar VEN.CODGER
                     IS NULL), pois um bind NULL em :A_CODGER significa
                     "sem filtro" por convenção do painel, não "sem
                     gerente".
                   - TOTALVENDEDORES conta vendedores distintos com venda no
                     período dentro do grupo, não o quadro total do gerente.
                   - Lista ordenada por faturamento decrescente.
==============================================================================*/

WITH VENDAS AS (
    SELECT
         CAB.NUNOTA
        ,CAB.CODVEND
        ,ITE.QTDNEG
        ,(ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS,0) AS VLRITEM
    FROM TGFCAB CAB
    INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    WHERE CAB.DTNEG >= :P_PERIODO.INI
      AND CAB.DTNEG <= :P_PERIODO.FIN
      AND CAB.TIPMOV = 'V'
      AND CAB.STATUSNOTA = 'L'
      AND CAB.CODTIPOPER IN (1100,2200,1111,1190,1124,2202)
      AND PRO.USOPROD = 'V'
)
SELECT
     NVL(GER.CODVEND, -1)        AS CODGER
    ,NVL(GER.APELIDO, 'SEM GERENTE') AS GERENTE
    ,COUNT(DISTINCT VND.CODVEND) AS TOTALVENDEDORES
    ,COUNT(DISTINCT VND.NUNOTA)  AS TOTALNOTAS
    ,SUM(VND.QTDNEG)             AS TOTALPRODUTOS
    ,SUM(VND.VLRITEM)            AS TOTALFATURAMENTO
FROM VENDAS VND
INNER JOIN TGFVEN VEN ON VEN.CODVEND = VND.CODVEND
LEFT JOIN TGFVEN GER ON GER.CODVEND = VEN.CODGER
GROUP BY
     NVL(GER.CODVEND, -1)
    ,NVL(GER.APELIDO, 'SEM GERENTE')
ORDER BY TOTALFATURAMENTO DESC
