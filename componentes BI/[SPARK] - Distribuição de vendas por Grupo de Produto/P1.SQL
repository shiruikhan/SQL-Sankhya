/*==============================================================================
  Nome do Script : [SPARK] - Distribuição de vendas por Grupo de Produto — P1
  Tipo           : Componente BI — Tabela
  Dashboard      : [SPARK] - Distribuição de vendas por Grupo de Produto
  Descrição      : Relaciona os parceiros que compraram o grupo de produto
                   selecionado no período, com a quantidade de produtos, a
                   quantidade de notas emitidas e o valor vendido. Considera
                   apenas os itens que pertencem ao grupo selecionado (os
                   demais itens das mesmas notas ficam de fora). É o painel
                   de entrada: o clique na linha (parceiro x vendedor)
                   aciona o P2 (:A_CODPARC e :A_CODVEND).

  Parâmetros     : :P_CODGRUPOPROD — grupo de produto (entidade simples,
                   obrigatório); aceita grupo pai (sintético) ou grupo direto
                   (analítico)
                   :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)
                   :P_CODVEND — vendedores/gerentes (multilist, obrigatório);
                   filtra TGFCAB.CODVEND e, para gerente, a equipe via
                   TGFVEN.CODGER

  Colunas        : CODPARC     — código do parceiro (chave do drill para o P2)
                   PARCEIRO    — código + razão social do parceiro
                   CODVEND     — código do vendedor da nota (chave do drill
                                 para o P2, :A_CODVEND)
                   VENDEDOR    — apelido do vendedor (TGFVEN.APELIDO)
                   QTDPRODUTOS — quantidade LÍQUIDA de devolução (vendas -
                                 devoluções) dos itens do grupo
                   QTDNOTAS    — notas de venda distintas com ao menos um item
                                 do grupo (notas de devolução não entram)
                   VLRTOTAL    — valor líquido de devolução dos itens do grupo
                                 (VLRTOT - VLRDESC + AD_VLROUTROS; vendas -
                                 devoluções)
                   QTDDEVOLVIDA / VLRDEVOLVIDO — parcela de devolução já
                                 abatida em QTDPRODUTOS / VLRTOTAL

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo, status)
                   TGFITE -- itens da nota (quantidade e valores)
                   TGFPRO -- cadastro de produtos (grupo, filtro USOPROD)
                   TGFGRU -- grupos de produto (hierarquia CODGRUPAI)
                   TGFPAR -- cadastro de parceiros (razão social)
                   TGFVEN -- cadastro de vendedores (CODGER do vendedor da nota)

  Uso            : Painel BI "[SPARK] - Distribuição de vendas por Grupo de
                   Produto" — painel 1 (parceiros). O clique na linha aciona o
                   P2 com :A_CODPARC e :A_CODVEND.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 07/10/2026
  Última Revisão : Outubro/2026 — Criação do componente
                   Outubro/2026 — Adicionado parâmetro :P_CODVEND (multilist)
                   com tratativa de gerente (TGFVEN.CODGER).
                   Outubro/2026 — Adicionadas colunas CODVEND e VENDEDOR; a
                   linha passa a ser parceiro x vendedor.
                   Outubro/2026 — Devoluções abatidas de QTDPRODUTOS e
                   VLRTOTAL; adicionadas QTDDEVOLVIDA e VLRDEVOLVIDO.

  Observações    : - A granularidade é parceiro x vendedor: parceiro atendido
                     por mais de um vendedor no período aparece em uma linha
                     por vendedor.
                   - :P_CODVEND segue o padrão multilist do BI (IN :P_CODVEND,
                     sem guarda de NULL). A nota entra se o vendedor da nota
                     (CAB.CODVEND) estiver na lista OU se o gerente dele
                     (VEN.CODGER) estiver: selecionar um gerente traz as
                     vendas dele e de toda a equipe subordinada.
                   - Critério de venda idêntico ao de RESUMO DE VENDAS POR
                     VENDEDOR (TIPMOV 'V', STATUSNOTA 'L', CODTIPOPER de venda,
                     USOPROD 'V').
                   - Devoluções (TIPMOV 'D', CODTIPOPER 1200,1201,1216,1217,
                     1272; 1206 fora de propósito, como no Faturamento por
                     período Gestão) entram com sinal negativo, no período em
                     que a devolução ocorreu (DTNEG da nota de devolução), e
                     com a regra (CODEMP = 501 OR STATUSNFE <> 'D') de
                     p2.sql daquele componente. Os filtros de grupo, vendedor
                     (CAB.CODVEND / CODGER) e parceiro valem para a nota de
                     devolução. Parceiro com devolução e sem venda no período
                     aparece com valores negativos.
                   - O grupo é expandido pela hierarquia TGFGRU (CODGRUPAI) em
                     qualquer profundidade: se o grupo informado for pai,
                     entram todos os descendentes; se for direto, entra só ele.
                   - O mesmo filtro de grupo/período/critério de venda é
                     repetido em P2 e P3; manter os três sincronizados.
==============================================================================*/

SELECT  PAR.CODPARC
       ,PAR.CODPARC || ' - ' || PAR.RAZAOSOCIAL      AS PARCEIRO
       ,CAB.CODVEND
       ,VEN.APELIDO                                  AS VENDEDOR
       ,SUM(CASE WHEN CAB.TIPMOV = 'D' THEN -ITE.QTDNEG ELSE ITE.QTDNEG END) AS QTDPRODUTOS
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
       INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
       LEFT  JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
 WHERE CAB.DTNEG >= :P_PERIODO.INI
   AND CAB.DTNEG <= :P_PERIODO.FIN
   AND (CAB.CODVEND IN :P_CODVEND OR VEN.CODGER IN :P_CODVEND)
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
 GROUP BY PAR.CODPARC
         ,PAR.RAZAOSOCIAL
         ,CAB.CODVEND
         ,VEN.APELIDO
 ORDER BY VLRTOTAL DESC
