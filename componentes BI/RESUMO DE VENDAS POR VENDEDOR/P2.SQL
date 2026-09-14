/*==============================================================================
  Nome do Script : RESUMO DE VENDAS POR VENDEDOR — P1 (Resumo)
  Tipo           : Componente BI — Tabela
  Dashboard      : Resumo de Vendas por Vendedor
  Descrição      : Consolida, por vendedor, o total de notas faturadas, o total
                   de produtos vendidos e o total faturado no período.
                   Identifica também o gerente responsável pelo vendedor
                   (TGFVEN.CODGER, auto-relacionamento para outro CODVEND).
                   É a consulta "master"; o detalhe nota a nota está em P2,
                   acionado pelo clique sobre o vendedor (:A_CODVEND).

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)
                   :P_VENDEDOR — filtra um vendedor específico (opcional)
                   :P_GERENTE — filtra pelos vendedores subordinados a um
                   gerente (TGFVEN.CODGER), opcional

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (filtro USOPROD)
                   TGFVEN -- cadastro de vendedores (nome); auto-relacionada
                            por CODGER para identificar o gerente

  Uso            : Painel BI "Resumo de Vendas por Vendedor" — linha de
                   resumo; drill para P2 pelo campo CODVEND (:A_CODVEND).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Setembro/2026 — Adicionada identificação do gerente do
                   vendedor via TGFVEN.CODGER.
                   Setembro/2026 — Adicionado parâmetro :P_GERENTE para
                   filtrar por gerente.

  Observações    : - CODTIPOPER de venda e STATUSNOTA = 'L' seguem o mesmo
                     critério usado nos demais componentes de faturamento do
                     repositório (ex.: RESUMO DE RESULTADO DE VENDAS,
                     FATURAMENTO POR PERIODO).
                   - TOTALFATURAMENTO soma valor líquido do item (VLRTOT -
                     VLRDESC) mais outros valores (AD_VLROUTROS), mesma regra
                     usada em Faturamento por período Gestão/p2.sql.
                   - Lista ordenada por faturamento decrescente para
                     facilitar o ranking de vendedores.
                   - GER é o próprio TGFVEN relacionado por CODGER = CODVEND
                     do gerente; LEFT JOIN porque nem todo vendedor tem
                     gerente cadastrado (CODGER pode ser NULL).
                   - :P_GERENTE filtra por VEN.CODGER (o gerente do
                     vendedor), não pelo próprio CODVEND do gerente — um
                     vendedor que também seja gerente de outros não aparece
                     sozinho ao filtrar por ele, a menos que também tenha um
                     CODGER preenchido igual ao parâmetro.
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
      AND (CAB.CODVEND = :P_VENDEDOR OR :P_VENDEDOR IS NULL)
)
SELECT
     VEN.CODVEND
    ,VEN.APELIDO
    ,GER.CODVEND AS CODGER
    ,GER.APELIDO AS GERENTE
    ,COUNT(DISTINCT VND.NUNOTA) AS TOTALNOTAS
    ,SUM(VND.QTDNEG)            AS TOTALPRODUTOS
    ,SUM(VND.VLRITEM)           AS TOTALFATURAMENTO
FROM VENDAS VND
INNER JOIN TGFVEN VEN ON VEN.CODVEND = VND.CODVEND
LEFT JOIN TGFVEN GER ON GER.CODVEND = VEN.CODGER
WHERE (VEN.CODGER = :P_GERENTE OR :P_GERENTE IS NULL)
GROUP BY
     VEN.CODVEND
    ,VEN.APELIDO
    ,GER.CODVEND
    ,GER.APELIDO
ORDER BY TOTALFATURAMENTO DESC
