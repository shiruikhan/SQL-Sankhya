/*==============================================================================
  Nome do Script : RESUMO DE VENDAS POR VENDEDOR ? P1 (Resumo por Gerente)
  Tipo           : Componente BI ? Tabela
  Dashboard      : Resumo de Vendas por Vendedor
  Descrição      : Visão gerencial do comercial: consolida o total de notas
                   faturadas, total de produtos vendidos e total faturado no
                   período, agrupado por GERENTE (TGFVEN.CODGER). Cada linha
                   soma as vendas de todos os vendedores subordinados àquele
                   gerente. Vendedores sem gerente cadastrado são agrupados
                   na linha "SEM GERENTE".
                   Traz também as devoluções do período (peças e valor) e o
                   saldo financeiro (faturamento - devoluções).
                   É o nível mais alto do painel; drill para P2 (resumo por
                   vendedor) pelo clique sobre o gerente (:A_CODGER).

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN ? período sobre DTNEG
                   (obrigatório)

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (filtro USOPROD)
                   TGFVEN -- cadastro de vendedores; auto-relacionada por
                            CODGER para agrupar por gerente

  Uso            : Painel BI "Resumo de Vendas por Vendedor" ? visão
                   gerencial por gerente; drill para P2 pelo campo CODGER
                   (:A_CODGER).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Novembro/2026 ? Adicionadas QTDDEVOLVIDA, VLRDEVOLVIDO e
                   SALDOFINANCEIRO (TOTALFATURAMENTO - VLRDEVOLVIDO).

  Observações    : - CODTIPOPER de venda e STATUSNOTA = 'L' seguem o mesmo
                     critério usado nos demais componentes de faturamento do
                     repositório (ex.: RESUMO DE RESULTADO DE VENDAS,
                     FATURAMENTO POR PERIODO) e o restante deste dashboard.
                   - CODGER = -1 é o sentinel usado para agrupar vendedores
                     sem gerente cadastrado (GER.CODVEND é NULL nesse caso).
                     Ele precisa ser tratado de forma simétrica em P2 ao
                     receber o clique (:A_CODGER = -1 ¿ filtrar VEN.CODGER
                     IS NULL), pois um bind NULL em :A_CODGER significa
                     "sem filtro" por convenção do painel, não "sem
                     gerente".
                   - TOTALVENDEDORES conta vendedores distintos com venda no
                     período dentro do grupo, não o quadro total do gerente.
                   - TOTALVENDEDORES, TOTALNOTAS, TOTALPRODUTOS e
                     TOTALFATURAMENTO consideram só as vendas (valores
                     brutos); as devoluções ficam em colunas próprias e são
                     abatidas apenas em SALDOFINANCEIRO.
                   - Devoluções (TIPMOV 'D', CODTIPOPER 1200,1201,1216,1217,
                     1272; 1206 fora de propósito) seguem o mesmo critério do
                     componente 228: entram pelo DTNEG da nota de devolução,
                     pelo vendedor da nota de devolução (CAB.CODVEND), com o
                     mesmo valor de item das vendas e com a regra
                     (CODEMP = 501 OR NVL(STATUSNFE, 'X') <> 'D'). O NVL é
                     obrigatório: STATUSNFE <> 'D' sem ele descarta as
                     devoluções com STATUSNFE nulo (falha corrigida em
                     Novembro/2026 nos demais componentes).
                   - Gerente com devolução e sem venda no período aparece
                     com faturamento zero e saldo negativo.
                   - Lista ordenada por faturamento decrescente.
==============================================================================*/

WITH MOVIMENTO AS (
    SELECT
         CAB.NUNOTA
        ,CAB.CODVEND
        ,CAB.TIPMOV
        ,ITE.QTDNEG
        ,(ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS,0) AS VLRITEM
    FROM TGFCAB CAB
    INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    WHERE CAB.DTNEG >= :P_PERIODO.INI
      AND CAB.DTNEG <= :P_PERIODO.FIN
      AND (
              (    CAB.TIPMOV = 'V'
               AND CAB.STATUSNOTA = 'L'
               AND CAB.CODTIPOPER IN (1100,2200,1111,1190,1124,2202)
              )
           OR (    CAB.TIPMOV = 'D'
               AND CAB.CODTIPOPER IN (1200,1201,1216,1217,1272)
               AND (CAB.CODEMP = 501 OR NVL(CAB.STATUSNFE, 'X') <> 'D')
              )
          )
      AND PRO.USOPROD = 'V'
)
SELECT
     CODGER
    ,GERENTE
    ,TOTALVENDEDORES
    ,TOTALNOTAS
    ,TOTALPRODUTOS
    ,TOTALFATURAMENTO
    ,QTDDEVOLVIDA
    ,VLRDEVOLVIDO
    ,TOTALFATURAMENTO - VLRDEVOLVIDO AS SALDOFINANCEIRO
FROM (
    SELECT
         NVL(GER.CODVEND, -1)        AS CODGER
        ,NVL(GER.APELIDO, 'SEM GERENTE') AS GERENTE
        ,COUNT(DISTINCT CASE WHEN MOV.TIPMOV = 'V' THEN MOV.CODVEND END) AS TOTALVENDEDORES
        ,COUNT(DISTINCT CASE WHEN MOV.TIPMOV = 'V' THEN MOV.NUNOTA END)  AS TOTALNOTAS
        ,SUM(CASE WHEN MOV.TIPMOV = 'V' THEN MOV.QTDNEG  ELSE 0 END)     AS TOTALPRODUTOS
        ,SUM(CASE WHEN MOV.TIPMOV = 'V' THEN MOV.VLRITEM ELSE 0 END)     AS TOTALFATURAMENTO
        ,SUM(CASE WHEN MOV.TIPMOV = 'D' THEN MOV.QTDNEG  ELSE 0 END)     AS QTDDEVOLVIDA
        ,SUM(CASE WHEN MOV.TIPMOV = 'D' THEN MOV.VLRITEM ELSE 0 END)     AS VLRDEVOLVIDO
    FROM MOVIMENTO MOV
    INNER JOIN TGFVEN VEN ON VEN.CODVEND = MOV.CODVEND
    LEFT JOIN TGFVEN GER ON GER.CODVEND = VEN.CODGER
    GROUP BY
         NVL(GER.CODVEND, -1)
        ,NVL(GER.APELIDO, 'SEM GERENTE')
)
ORDER BY TOTALFATURAMENTO DESC
