/*==============================================================================
  Nome do Script : RESUMO DE VENDAS POR VENDEDOR — P2 (Detalhe)
  Tipo           : Componente BI — Tabela
  Dashboard      : Resumo de Vendas por Vendedor
  Descrição      : Lista nota a nota as vendas do vendedor selecionado em P1.
                   É o detalhe (drill-down) de P1: recebe o vendedor
                   selecionado em :A_CODVEND (clique na linha) e honra o
                   mesmo período do painel. Mesmo critério de venda de P1
                   (TIPMOV, STATUSNOTA, CODTIPOPER, USOPROD). Repete o
                   vendedor e o gerente (TGFVEN.CODGER) em cada linha para
                   identificação sem depender do contexto de P1.

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)
                   :A_CODVEND — vendedor selecionado na linha de P1
                   (obrigatório, vindo do clique)

  Colunas        : NUNOTA / NUMNOTA / DTNEG — identificação da nota
                   PARCEIRO             — código + razão social do cliente
                   CODPROD / DESCRPROD / CODVOL — produto e unidade
                   QTDNEG               — quantidade vendida do item
                   VLRTOTALITEM         — valor líquido do item (VLRTOT -
                                          VLRDESC + AD_VLROUTROS)
                   VENDEDOR / GERENTE   — nome do vendedor da nota e do seu
                                          gerente (TGFVEN.CODGER)

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFPAR -- cadastro de parceiros (razão social)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (descrição, unidade, filtro USOPROD)
                   TGFVEN -- cadastro de vendedores; auto-relacionada por
                            CODGER para identificar o gerente

  Uso            : Painel BI "Resumo de Vendas por Vendedor" — detalhe
                   acionado pelo clique em P1 sobre o vendedor.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Setembro/2026 — Adicionadas colunas VENDEDOR e GERENTE
                   (TGFVEN.CODGER) em cada linha do detalhe.

  Observações    : - CODTIPOPER de venda e STATUSNOTA = 'L' idênticos a P1;
                     SUM(VLRTOTALITEM) deste detalhe deve fechar com
                     TOTALFATURAMENTO da linha correspondente em P1.
                   - Como o vendedor já vem fixado por :A_CODVEND, os
                     parâmetros :P_VENDEDOR e :P_GERENTE do painel não são
                     reaplicados aqui — o gerente do vendedor selecionado já
                     está implícito na cadeia CODVEND -> CODGER.
                   - GER é o próprio TGFVEN relacionado por CODGER = CODVEND
                     do gerente; LEFT JOIN porque nem todo vendedor tem
                     gerente cadastrado (CODGER pode ser NULL).
==============================================================================*/

SELECT
     CAB.NUNOTA
    ,CAB.NUMNOTA
    ,CAB.DTNEG
    ,PAR.CODPARC || ' - ' || PAR.RAZAOSOCIAL AS PARCEIRO
    ,ITE.CODPROD
    ,PRO.DESCRPROD
    ,PRO.CODVOL
    ,ITE.QTDNEG
    ,(ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS,0) AS VLRTOTALITEM
    ,VEN.APELIDO AS VENDEDOR
    ,GER.APELIDO AS GERENTE
FROM TGFCAB CAB
INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
INNER JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
LEFT JOIN TGFVEN GER ON GER.CODVEND = VEN.CODGER
WHERE CAB.DTNEG >= :P_PERIODO.INI
  AND CAB.DTNEG <= :P_PERIODO.FIN
  AND CAB.CODVEND = :A_CODVEND
  AND CAB.TIPMOV = 'V'
  AND CAB.STATUSNOTA = 'L'
  AND CAB.CODTIPOPER IN (1100,2200,1111,1190,1124,2202)
  AND PRO.USOPROD = 'V'
ORDER BY CAB.DTNEG, CAB.NUNOTA
