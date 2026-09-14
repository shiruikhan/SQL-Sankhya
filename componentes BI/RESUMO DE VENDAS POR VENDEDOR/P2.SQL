/*==============================================================================
  Nome do Script : RESUMO DE VENDAS POR VENDEDOR — P2 (Resumo por Vendedor)
  Tipo           : Componente BI — Tabela
  Dashboard      : Resumo de Vendas por Vendedor
  Descrição      : Consolida, por vendedor, o total de notas faturadas, o total
                   de produtos vendidos e o total faturado no período.
                   Identifica também o gerente responsável pelo vendedor
                   (TGFVEN.CODGER, auto-relacionamento para outro CODVEND).
                   É o nível intermediário do painel: pode ser aberto direto
                   (filtrando manualmente por :P_VENDEDOR / :P_GERENTE) ou
                   como drill-down de P1, recebendo o gerente clicado em
                   :A_CODGER. O detalhe nota a nota está em P3, acionado pelo
                   clique sobre o vendedor (:A_CODVEND).

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)
                   :P_VENDEDOR — filtra um vendedor específico (opcional)
                   :P_GERENTE — filtra pelos vendedores subordinados a um
                   gerente (TGFVEN.CODGER), uso manual (opcional)
                   :A_CODGER — gerente selecionado na linha de P1 (clique);
                   opcional para permitir abertura direta do painel

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (filtro USOPROD)
                   TGFVEN -- cadastro de vendedores (nome); auto-relacionada
                            por CODGER para identificar o gerente

  Uso            : Painel BI "Resumo de Vendas por Vendedor" — resumo por
                   vendedor; drill de entrada a partir de P1 (:A_CODGER) e
                   drill de saída para P3 pelo campo CODVEND (:A_CODVEND).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Setembro/2026 — Adicionada identificação do gerente do
                   vendedor via TGFVEN.CODGER.
                   Setembro/2026 — Adicionado parâmetro :P_GERENTE para
                   filtrar por gerente.
                   Setembro/2026 — Renumerado de P1 para P2 e adicionado
                   :A_CODGER para servir de drill-down do novo painel de
                   resumo por gerente (P1).

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
                   - :P_GERENTE e :A_CODGER filtram a mesma coluna
                     (VEN.CODGER) por dois caminhos distintos — prompt manual
                     e clique vindo de P1 — e podem ser usados
                     independentemente (painel aberto direto não tem
                     :A_CODGER; drill a partir de P1 não tem :P_GERENTE).
                   - :A_CODGER = -1 replica o sentinel "SEM GERENTE" de P1:
                     ao clicar naquela linha, filtra vendedores com
                     VEN.CODGER IS NULL. Um :A_CODGER NULL (painel aberto
                     direto) significa "sem filtro", nunca "sem gerente".
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
  AND (
        (:A_CODGER = -1 AND VEN.CODGER IS NULL)
     OR VEN.CODGER = :A_CODGER
     OR :A_CODGER IS NULL
      )
GROUP BY
     VEN.CODVEND
    ,VEN.APELIDO
    ,GER.CODVEND
    ,GER.APELIDO
ORDER BY TOTALFATURAMENTO DESC
