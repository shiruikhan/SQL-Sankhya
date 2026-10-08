/*==============================================================================
  Nome do Script : [SPARK] - Distribuição de vendas por Grupo de Produto — P2
  Tipo           : Componente BI — Tabela
  Dashboard      : [SPARK] - Distribuição de vendas por Grupo de Produto
  Descrição      : Lista os produtos do grupo selecionado que o parceiro
                   selecionado em P1 comprou no período, com quantidade,
                   número de notas e valor por produto. É o detalhe
                   (drill-down) de P1: recebe o parceiro em :A_CODPARC
                   (clique na linha) e honra o mesmo grupo e período do
                   painel.

  Parâmetros     : :P_CODGRUPOPROD — grupo de produto (entidade simples,
                   obrigatório); aceita grupo pai ou grupo direto
                   :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)
                   :P_CODVEND — vendedores/gerentes (multilist, obrigatório);
                   filtra TGFCAB.CODVEND e, para gerente, a equipe via
                   TGFVEN.CODGER
                   :A_CODPARC — parceiro selecionado na linha de P1; NULL
                   (painel aberto sem clique) significa "sem filtro de
                   parceiro"
                   :A_CODVEND — vendedor da linha selecionada em P1; NULL
                   significa "sem filtro de vendedor"

  Colunas        : CODVEND / VENDEDOR — vendedor da nota (TGFVEN.APELIDO)
                   CODPROD / DESCRPROD / CODVOL — produto e unidade
                   QTDNEG   — quantidade LÍQUIDA de devolução (vendas -
                              devoluções)
                   QTDNOTAS — notas de venda distintas em que o produto
                              aparece (notas de devolução não entram)
                   VLRTOTAL — valor líquido de devolução (VLRTOT - VLRDESC +
                              AD_VLROUTROS; vendas - devoluções)
                   QTDDEVOLVIDA / VLRDEVOLVIDO — parcela de devolução já
                              abatida em QTDNEG / VLRTOTAL

  Tabelas        : TGFCAB -- cabeçalho da nota (período, parceiro, tipo, status)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (descrição, unidade, grupo)
                   TGFGRU -- grupos de produto (hierarquia CODGRUPAI)
                   TGFVEN -- cadastro de vendedores (CODGER do vendedor da nota)

  Uso            : Painel BI "[SPARK] - Distribuição de vendas por Grupo de
                   Produto" — painel 2 (produtos do parceiro), acionado pelo
                   clique em P1.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 07/10/2026
  Última Revisão : Outubro/2026 — Criação do componente
                   Outubro/2026 — Adicionado parâmetro :P_CODVEND (multilist)
                   com tratativa de gerente (TGFVEN.CODGER).
                   Outubro/2026 — Adicionadas colunas CODVEND e VENDEDOR e o
                   drill :A_CODVEND vindo de P1.
                   Outubro/2026 — Devoluções abatidas de QTDNEG e VLRTOTAL
                   (mesma regra de P1); adicionadas QTDDEVOLVIDA e
                   VLRDEVOLVIDO.

  Observações    : - A granularidade é produto x vendedor. :A_CODVEND (clique
                     em P1) restringe ao vendedor da linha, para que
                     SUM(VLRTOTAL) feche com a linha parceiro x vendedor de P1.
                   - :P_CODVEND: mesma regra de P1 (vendedor da nota na lista
                     OU gerente dele na lista; IN :P_CODVEND sem guarda de
                     NULL).
                   - Mesmo critério de venda e mesma expansão de grupo de P1;
                     SUM(VLRTOTAL) deste painel fecha com o VLRTOTAL da linha
                     do parceiro em P1.
                   - O NULL em :A_CODPARC segue a convenção de RESUMO DE
                     VENDAS POR VENDEDOR (P2): sem clique, lista os produtos
                     do grupo para todos os parceiros.
==============================================================================*/

SELECT  CAB.CODVEND
       ,VEN.APELIDO                                  AS VENDEDOR
       ,ITE.CODPROD
       ,PRO.DESCRPROD
       ,PRO.CODVOL
       ,SUM(CASE WHEN CAB.TIPMOV = 'D' THEN -ITE.QTDNEG ELSE ITE.QTDNEG END) AS QTDNEG
       ,COUNT(DISTINCT CASE WHEN CAB.TIPMOV = 'V' THEN CAB.NUNOTA END)        AS QTDNOTAS
       ,SUM(CASE WHEN CAB.TIPMOV = 'D'
                 THEN -((ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS, 0))
                 ELSE  ((ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS, 0))
            END)                                                            AS VLRTOTAL
       ,SUM(CASE WHEN CAB.TIPMOV = 'D' THEN ITE.QTDNEG ELSE 0 END)            AS QTDDEVOLVIDA
       ,SUM(CASE WHEN CAB.TIPMOV = 'D'
                 THEN (ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS, 0)
                 ELSE 0
            END)                                                            AS VLRDEVOLVIDO
  FROM TGFCAB CAB
       INNER JOIN TGFITE ITE ON ITE.NUNOTA  = CAB.NUNOTA
       INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
       LEFT  JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
 WHERE CAB.DTNEG >= :P_PERIODO.INI
   AND CAB.DTNEG <= :P_PERIODO.FIN
   AND (CAB.CODVEND IN :P_CODVEND OR VEN.CODGER IN :P_CODVEND)
   AND (CAB.CODPARC = :A_CODPARC OR :A_CODPARC IS NULL)
   AND (CAB.CODVEND = :A_CODVEND OR :A_CODVEND IS NULL)
   AND (
           (    CAB.TIPMOV = 'V'
            AND CAB.STATUSNOTA = 'L'
            AND CAB.CODTIPOPER IN (1100,2200,1111,1190,1124,2202)
           )
        OR (    CAB.TIPMOV = 'D'
            AND CAB.CODTIPOPER IN (1200,1201,1216,1217,1272)
            AND (CAB.CODEMP = 501 OR CAB.STATUSNFE <> 'D')
           )
       )
   AND PRO.USOPROD = 'V'
   AND PRO.CODGRUPOPROD IN (
           SELECT  GRU.CODGRUPOPROD
             FROM  TGFGRU GRU
            START  WITH GRU.CODGRUPOPROD = :P_CODGRUPOPROD
          CONNECT  BY NOCYCLE PRIOR GRU.CODGRUPOPROD = GRU.CODGRUPAI
       )
 GROUP BY CAB.CODVEND
         ,VEN.APELIDO
         ,ITE.CODPROD
         ,PRO.DESCRPROD
         ,PRO.CODVOL
 ORDER BY QTDNEG DESC
