CREATE OR REPLACE FUNCTION OBTEM_TOTAIS_MRP (
    P_NUMPS     NUMBER,    -- Número do Plano Mestre de Produção (MPS) de referência
    P_CODPRODPA NUMBER,    -- Código do Produto Acabado (PA); 0 = todos os PAs do plano
    P_CODPRODMP NUMBER,    -- Código da Matéria-Prima (MP); ignorado para tipos de PA
    P_TIPO      VARCHAR2   -- Tipo de total a retornar (ver tabela abaixo)
)
RETURN FLOAT
RESULT_CACHE   -- Cacheia por combinação de argumentos; invalida automaticamente em DML nas tabelas-fonte
/*==============================================================================
  Nome do Script : OBTEM_TOTAIS_MRP
  Tipo           : Function
  Descrição      : Retorna totais analíticos do Plano Mestre de Produção (MPS/MRP)
                   para suporte ao planejamento de produção e compras de matéria-prima.

                   Dependendo do parâmetro P_TIPO, a função retorna um valor
                   referente ao produto acabado (PA) ou à matéria-prima (MP)
                   dentro do plano informado (P_NUMPS).

  Parâmetros     :
    P_NUMPS       — Número do MPS (TPRMPS.NUMPS). Identifica o plano de produção.
    P_CODPRODPA   — Código do PA filtrado. Use 0 para considerar todos os PAs.
    P_CODPRODMP   — Código da MP. Usado nos tipos N, NA, C, E e O.
    P_TIPO        — Tipo do total a retornar:

      'M'  — Meta do PA no mês do MPS (VGFSALDOMRP.QTDPREV)
      'P'  — Quantidade produzida do PA no mês do MPS (VGFSALDOMRP.QTDPRODUZIR)
      'S'  — Saldo a produzir do PA: soma acumulada de períodos anteriores ao MPS.
             Saldo negativo indica que a produção já superou a meta no período;
             neste caso, o valor não deve influenciar o cálculo de MP a comprar.
             O saldo acumula períodos anteriores até que uma ordem de MPS do mês
             devedor seja gerada. O campo "Qtd. Redução Meta" em TGMMET permite
             marcar que o item não será mais produzido, zerando o saldo acumulado.
      'N'  — Necessidade líquida de MP no MPS filtrado (considera composição do PA).
             Calculada como QTDMISTURA × QTDPRODUZIRLIQ. Independente de estoque
             disponível ou pedido de compra.
      'NA' — Necessidade de MP dos planos anteriores ao MPS filtrado.
             Mesma lógica de 'N', mas para períodos anteriores (SAL.DTREF < mês do MPS).
      'C'  — Necessidade de compra de MP no MRP filtrado.
             [A DEFINIR — lógica não implementada nesta versão]
      'E'  — Estoque disponível da MP: saldo (ESTOQUE − RESERVADO) no local 101.
      'O'  — Pedidos de compra abertos e pendentes da MP (QTDNEG − QTDENTREGUE).
             Considera apenas TOP do grupo "Pedido Compra", nota confirmada (STATUSNOTA='L')
             e item pendente. Não filtra por data — traz tudo em aberto.

  Retorno        : FLOAT com o total calculado. Retorna 0 se não houver dados
                   ou se o tipo não for reconhecido.

  Tabelas fonte  : TPRMPS    — Plano Mestre de Produção
                   TPRIMPS   — Itens do MPS (PA planejados)
                   TPRPRC    — Processos de produção
                   TPRLPA    — Lote padrão de produção (PA → processo)
                   TPRLMP    — Composição de MP no lote padrão
                   TPRATV    — Atividades do processo
                   TPROEST   — Etapas do processo (tipo de item)
                   TGFPRO    — Cadastro de produtos
                   TGFCAB    — Cabeçalho de nota (pedidos de compra)
                   TGFITE    — Itens de nota
                   TGFTOP    — Tipos de operação
                   TGFEST    — Posição de estoque (local 101)
                   VGFSALDOMRP — View de saldo do MRP por produto e período

  Uso            : Componentes BI do Cronograma Geral de Produção e do Painel
                   de Acompanhamento de Produção. Chamada diretamente nas queries
                   analíticas para compor colunas de meta, produção, saldo e MP.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 2022
  Última Revisão : Junho/2026 — Performance/robustez (sem alterar assinatura nem
                   pontos de chamada): RESULT_CACHE adicionado; tipos N e NA
                   reescritos em ANSI puro sem GROUP BY/HAVING (elimina o sort
                   por chamada e o risco de TOO_MANY_ROWS, com retorno idêntico);
                   handler WHEN OTHERS de topo retornando 0; variável local
                   P_VALOR → V_VALOR.
                   Abril/2026 — Padronização completa: cabeçalho, keywords,
                   indentação (tabs → espaços) e comentários de seção

  Observações    : - O tipo 'C' (necessidade de compra) está listado no header
                     mas não possui implementação no corpo da função — retorna 0.
                   - O local de estoque 101 está fixo para o tipo 'E'. Ajustar
                     se o layout de locais mudar.
                   - VGFSALDOMRP é uma view intermediária que agrega saldo do MRP
                     por produto e data de referência mensal.
                   - A função usa RESULT_CACHE: o resultado é cacheado por
                     combinação de argumentos e invalidado automaticamente em DML
                     nas tabelas-fonte. Os valores refletem o último COMMIT.
                   - Tipos N e NA mantêm TGFPRO como INNER JOIN apenas para
                     preservar o filtro de produto; TGFPAR foi removido (não
                     influenciava o SUM).
==============================================================================*/
IS
    -- Variável de retorno. Inicializada implicitamente como NULL;
    -- NVL na instrução RETURN garante retorno 0 em caso de NOT FOUND.
    V_VALOR FLOAT;

BEGIN

    -- =========================================================================
    -- TIPO 'E' — ESTOQUE DISPONÍVEL DA MATÉRIA-PRIMA
    -- Calcula o saldo livre (ESTOQUE − RESERVADO) da MP no local 101.
    -- Retorna 0 se a MP não tiver registro de estoque nesse local.
    -- =========================================================================
    IF P_TIPO = 'E' AND P_CODPRODMP > 0 THEN
        BEGIN
            SELECT SUM(E.ESTOQUE - E.RESERVADO)
              INTO V_VALOR
              FROM TGFEST E
             WHERE E.CODLOCAL = 101            -- Local de estoque principal de MP
               AND E.CODPROD  = P_CODPRODMP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_VALOR := 0;
        END;
    END IF;

    -- =========================================================================
    -- TIPO 'S' — SALDO A PRODUZIR DO PA (ACUMULADO DE PERÍODOS ANTERIORES)
    -- Soma o saldo de todos os períodos anteriores ao mês de início do MPS
    -- informado. Saldo negativo indica produção acima da meta em meses passados.
    -- =========================================================================
    IF P_TIPO = 'S' THEN
        BEGIN
            SELECT SALDO
              INTO V_VALOR
              FROM (
                  SELECT SUM(SALDO) AS SALDO
                    FROM VGFSALDOMRP
                   WHERE CODPROD = P_CODPRODPA
                     -- Considera apenas períodos anteriores ao mês do MPS
                     AND DTREF < (
                         SELECT TRUNC(DTINICMPS, 'MM')
                           FROM TPRMPS
                          WHERE NUMPS = P_NUMPS
                     )
              ) D;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_VALOR := 0;
        END;
    END IF;

    -- =========================================================================
    -- TIPOS 'P' e 'M' — PRODUÇÃO E META DO PA NO MÊS DO MPS
    -- 'P': quantidade produzida (QTDPRODUZIR) no mês de referência do MPS.
    -- 'M': quantidade prevista/meta (QTDPREV) no mês de referência do MPS.
    -- Ambas filtradas pelo mês exato de início do plano (TRUNC(..., 'MM')).
    -- =========================================================================
    IF P_TIPO IN ('P', 'M') THEN
        BEGIN
            SELECT SUM(
                       CASE WHEN P_TIPO = 'P'
                            THEN QTDPRODUZIR   -- Quantidade efetivamente produzida
                            ELSE QTDPREV       -- Quantidade prevista (meta)
                       END
                   )
              INTO V_VALOR
              FROM VGFSALDOMRP
             WHERE CODPROD = P_CODPRODPA
               -- Filtra exatamente o mês de início do MPS
               AND DTREF = (
                   SELECT TRUNC(DTINICMPS, 'MM')
                     FROM TPRMPS
                    WHERE NUMPS = P_NUMPS
               );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_VALOR := 0;
        END;
    END IF;

    -- =========================================================================
    -- TIPO 'N' — NECESSIDADE LÍQUIDA DE MP NO MPS FILTRADO
    -- Calcula a necessidade de MP multiplicando o fator de mistura (QTDMISTURA)
    -- pela quantidade líquida a produzir (QTDPRODUZIRLIQ) de cada PA no plano.
    -- Considera apenas necessidade positiva (valores <= 0 retornam 0).
    -- P_CODPRODPA = 0 retorna a necessidade consolidada de todos os PAs do plano.
    -- =========================================================================
    IF P_TIPO = 'N' THEN
        BEGIN
            -- Agregado escalar: JOIN em ANSI puro, sem GROUP BY/HAVING.
            SELECT SUM(LMP.QTDMISTURA * NVL(I.QTDPRODUZIRLIQ, 0))
              INTO V_VALOR
              FROM TPRMPS  MPS
              INNER JOIN TPRIMPS  I   ON I.NUMPS       = MPS.NUMPS
              INNER JOIN TPRPRC   PRC ON PRC.IDPROC    = I.IDPROC
              INNER JOIN TPRLPA   LPA ON LPA.CODPRODPA = I.CODPROD
                                     AND LPA.IDPROC    = I.IDPROC
              INNER JOIN TPRLMP   LMP ON LMP.CODPRODPA = LPA.CODPRODPA
                                     AND LMP.CODPRODMP = P_CODPRODMP
              INNER JOIN TPRATV   ATV ON ATV.IDPROC    = I.IDPROC
                                     AND ATV.IDEFX     = LMP.IDEFX
              INNER JOIN TPROEST  EST ON EST.IDEFX     = ATV.IDEFX
                                     AND EST.TIPOITENS = 'PA'
              INNER JOIN TGFPRO   PRO ON PRO.CODPROD   = LMP.CODPRODMP
             WHERE MPS.NUMPS = P_NUMPS
               -- Se P_CODPRODPA = 0, considera todos os PAs do plano
               AND (P_CODPRODPA = 0 OR LMP.CODPRODPA = P_CODPRODPA);

            -- Preserva a semântica do antigo HAVING > 0: valores <= 0 retornam 0
            IF NVL(V_VALOR, 0) <= 0 THEN
                V_VALOR := 0;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_VALOR := 0;
        END;
    END IF;

    -- =========================================================================
    -- TIPO 'NA' — NECESSIDADE DE MP DOS PLANOS ANTERIORES AO MPS FILTRADO
    -- Calcula a necessidade acumulada de MP proveniente de saldos de períodos
    -- anteriores ao mês do MPS informado. Usa VGFSALDOMRP para obter o saldo
    -- histórico de cada PA e o multiplica pelo fator de composição da MP.
    -- Considera apenas saldos positivos (valores <= 0 retornam 0).
    -- =========================================================================
    IF P_TIPO = 'NA' THEN
        BEGIN
            -- Agregado escalar: JOIN em ANSI puro, sem GROUP BY/HAVING.
            SELECT SUM(LMP.QTDMISTURA * NVL(SAL.SALDO, 0))
              INTO V_VALOR
              FROM TPRMPS     MPS
              INNER JOIN TPRIMPS     I   ON I.NUMPS       = MPS.NUMPS
              INNER JOIN VGFSALDOMRP SAL ON SAL.CODPROD   = I.CODPROD
              INNER JOIN TPRPRC      PRC ON PRC.IDPROC    = I.IDPROC
              INNER JOIN TPRLPA      LPA ON LPA.CODPRODPA = I.CODPROD
                                        AND LPA.IDPROC    = I.IDPROC
              INNER JOIN TPRLMP      LMP ON LMP.CODPRODPA = LPA.CODPRODPA
                                        AND LMP.CODPRODMP = P_CODPRODMP
              INNER JOIN TPRATV      ATV ON ATV.IDPROC    = I.IDPROC
                                        AND ATV.IDEFX     = LMP.IDEFX
              INNER JOIN TPROEST     EST ON EST.IDEFX     = ATV.IDEFX
                                        AND EST.TIPOITENS = 'PA'
              INNER JOIN TGFPRO      PRO ON PRO.CODPROD   = LMP.CODPRODMP
             WHERE MPS.NUMPS = P_NUMPS
               -- Se P_CODPRODPA = 0, considera todos os PAs do plano
               AND (NVL(P_CODPRODPA, 0) = 0 OR LMP.CODPRODPA = P_CODPRODPA)
               -- Apenas períodos anteriores ao mês do MPS
               AND SAL.DTREF < (
                       SELECT TRUNC(MPS2.DTINICMPS, 'MM')
                         FROM TPRMPS MPS2
                        WHERE MPS2.NUMPS = P_NUMPS
                   );

            -- Preserva a semântica do antigo HAVING > 0: valores <= 0 retornam 0
            IF NVL(V_VALOR, 0) <= 0 THEN
                V_VALOR := 0;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_VALOR := 0;
        END;
    END IF;

    -- =========================================================================
    -- TIPO 'O' — PEDIDOS DE COMPRA EM ABERTO DA MP
    -- Soma a quantidade pendente de recebimento (QTDNEG − QTDENTREGUE) em
    -- pedidos de compra confirmados (STATUSNOTA = 'L') e com item pendente.
    -- Não filtra por data: traz tudo em aberto. Para excluir um pedido do
    -- cálculo, desmarcar o campo PENDENTE no item ou fechar o pedido.
    -- =========================================================================
    IF P_TIPO = 'O' THEN
        BEGIN
            SELECT SUM(I.QTDNEG - I.QTDENTREGUE)
              INTO V_VALOR
              FROM TGFCAB C
              INNER JOIN TGFITE I   ON C.NUNOTA     = I.NUNOTA
              INNER JOIN TGFTOP TPO ON TPO.CODTIPOPER = C.CODTIPOPER
                                   AND TPO.DHALTER    = C.DHTIPOPER
             WHERE UPPER(TPO.GRUPO) = 'PEDIDO COMPRA'  -- Apenas TOPs do grupo de compra
               AND C.STATUSNOTA     = 'L'              -- Nota confirmada/liberada
               AND I.PENDENTE       = 'S'              -- Item com recebimento pendente
               AND I.CODPROD        = P_CODPRODMP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_VALOR := 0;
        END;
    END IF;

    -- =========================================================================
    -- RETORNO FINAL:
    -- NVL garante 0 quando nenhum dos blocos IF foi executado
    -- (P_TIPO inválido ou desconhecido) ou quando V_VALOR ficou NULL.
    -- =========================================================================
    RETURN NVL(V_VALOR, 0);

EXCEPTION
    -- Função de relatório: nunca propagar erro ao SELECT chamador.
    -- Qualquer falha inesperada retorna 0 (mesma filosofia do NO_DATA_FOUND).
    WHEN OTHERS THEN
        RETURN 0;

END OBTEM_TOTAIS_MRP;
