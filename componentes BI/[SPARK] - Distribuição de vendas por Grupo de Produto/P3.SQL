/*==============================================================================
  Nome do Script : [SPARK] - Distribuição de vendas por Grupo de Produto — P3
  Tipo           : Componente BI — Gráfico (mapa de calor do Brasil)
  Dashboard      : [SPARK] - Distribuição de vendas por Grupo de Produto
  Descrição      : Distribuição geográfica das vendas do grupo de produto
                   selecionado, por estado (UF do parceiro), em quantidade
                   de produtos. Alimenta o mapa de calor do Brasil, no mesmo
                   formato de saída do GEOGUESSER (INFORMATIVO DE GESTÃO
                   ASSISTÊNCIA (DETALHES)): QTD, CODUF e UF.

  Parâmetros     : :P_CODGRUPOPROD — grupo de produto (entidade simples,
                   obrigatório); aceita grupo pai ou grupo direto
                   :P_PERIODO.INI / :P_PERIODO.FIN — período sobre DTNEG
                   (obrigatório)
                   :P_CODVEND — vendedores/gerentes (multilist, obrigatório);
                   filtra TGFCAB.CODVEND e, para gerente, a equipe via
                   TGFVEN.CODGER

  Colunas        : QTD   — quantidade LÍQUIDA de devolução (vendas -
                           devoluções) dos itens do grupo no estado
                   CODUF — código da UF (TSICID.UF = TSIUFS.CODUF)
                   UF    — sigla da UF

  Tabelas        : TGFCAB -- cabeçalho da nota (período, parceiro, tipo, status)
                   TGFITE -- itens da nota (quantidade)
                   TGFPRO -- cadastro de produtos (grupo, filtro USOPROD)
                   TGFGRU -- grupos de produto (hierarquia CODGRUPAI)
                   TGFPAR -- cadastro de parceiros (cidade)
                   TSICID -- cidades (UF)
                   TSIUFS -- unidades federativas (sigla)
                   TGFVEN -- cadastro de vendedores (CODGER do vendedor da nota)

  Uso            : Painel BI "[SPARK] - Distribuição de vendas por Grupo de
                   Produto" — painel 3 (mapa de calor).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 07/10/2026
  Última Revisão : Outubro/2026 — Criação do componente
                   Outubro/2026 — Adicionado parâmetro :P_CODVEND (multilist)
                   com tratativa de gerente (TGFVEN.CODGER).
                   Outubro/2026 — QTD passa a abater as devoluções (mesma
                   regra de P1).

  Observações    : - :P_CODVEND: mesma regra de P1 (vendedor da nota na lista
                     OU gerente dele na lista; IN :P_CODVEND sem guarda de
                     NULL).
                   - Mesmo critério de venda, de devolução e mesma expansão
                     de grupo de P1. UF cujas devoluções superem as vendas no
                     período fica com QTD negativa.
                   - O mapa não é filtrado por :A_CODPARC: mostra a
                     distribuição do grupo para todos os parceiros, e não
                     apenas do parceiro clicado em P1.
                   - A UF vem do cadastro do parceiro (TGFPAR.CODCID), como
                     no GEOGUESSER e no DASHBOARD DE VENDAS. Parceiros sem
                     cidade/UF cadastrada não aparecem no mapa, então a soma
                     de QTD pode ficar abaixo do total de P1.
==============================================================================*/

SELECT  SUM(CASE WHEN CAB.TIPMOV = 'D' THEN -ITE.QTDNEG ELSE ITE.QTDNEG END) AS QTD
       ,CID.UF          AS CODUF
       ,UFS.UF          AS UF
  FROM TGFCAB CAB
       INNER JOIN TGFITE ITE ON ITE.NUNOTA  = CAB.NUNOTA
       INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
       INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
       INNER JOIN TSICID CID ON CID.CODCID  = PAR.CODCID
       INNER JOIN TSIUFS UFS ON UFS.CODUF   = CID.UF
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
 GROUP BY CID.UF
         ,UFS.UF
 ORDER BY QTD DESC
