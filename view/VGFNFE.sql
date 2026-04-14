/*==============================================================================
  Nome do Script : VGFNFE
  Tipo           : VIEW
  Descrição      : Retorna as notas fiscais eletrônicas (NF-e) de vendas ativas,
                   emitidas com autorização recente, para integração com sistemas
                   externos de e-commerce e marketplace.

                   Para cada nota, expõe a chave de acesso, o pedido externo,
                   o identificador de armazém e o XML da NF-e para envio ao
                   cliente. O GROUP BY sobre o cabeçalho resolve possíveis
                   duplicações causadas pelo JOIN com TGFITE (uma nota pode
                   ter múltiplos itens).

  Tabelas fonte  : TGFCAB  — cabeçalho da nota fiscal
                   TGFITE  — itens da nota (JOIN para garantir existência de itens)
                   TGFNFE  — XML e dados da NF-e autorizada

  Colunas        :
    NUNOTA          — número único da nota no Sankhya
    CODVEND         — código do vendedor responsável pela nota
    PEDIDOEXTERNO   — número do pedido no sistema externo (AD_PEDIDOMKTPLACE)
    AD_WAREHOUSEID  — identificador do armazém no sistema externo
    CHAVENFE        — chave de acesso da NF-e (44 dígitos)
    NOTAXML         — XML da NF-e para envio ao cliente (TGFNFE.XMLENVCLI)

  Filtros ativos : TIPMOV = 'V'            — apenas notas de venda
                   CODVEND = 42            — vendedor específico (integração e-commerce)
                   STATUSNFE = 'A'         — NF-e autorizada pela SEFAZ
                   CHAVENFE IS NOT NULL    — nota com chave de acesso emitida
                   DHPROTOC > SYSDATE - 4  — protocolo de autorização nos últimos 4 dias

  Uso            : Integração com o site e marketplace da Spark para:
                   - Atualizar o status do pedido externo como "nota emitida"
                   - Fornecer a chave NF-e e o XML ao cliente

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 2022
  Última Revisão : Abril/2026 — Padronização de cabeçalho, comentários e formatação

  Observações    : - O CODVEND = 42 é fixo e específico para a integração
                     e-commerce vigente. Ajustar se o vendedor mudar ou se
                     for necessário expandir para múltiplos canais.
                   - O JOIN com TGFITE não filtra colunas de TGFITE — serve
                     apenas para garantir que a nota tenha ao menos um item
                     registrado. O GROUP BY elimina as linhas duplicadas.
                   - XMLENVCLI em TGFNFE é o XML específico para o cliente
                     (versão reduzida/formatada do XML da NF-e).
                   - O filtro de 4 dias em DHPROTOC limita o volume da view
                     às notas recentes — ajustar o período conforme a frequência
                     de sincronização com o sistema externo.
==============================================================================*/

CREATE OR REPLACE VIEW VGFNFE AS

SELECT
    -- =========================================================================
    -- Identificação da nota no Sankhya
    -- =========================================================================
    C.NUNOTA,

    -- =========================================================================
    -- Identificação do canal de venda
    -- =========================================================================
    C.CODVEND,                       -- Código do vendedor (fixo: 42 = e-commerce)

    -- =========================================================================
    -- Campos de integração com o sistema externo
    -- =========================================================================
    C.AD_PEDIDOMKTPLACE AS PEDIDOEXTERNO,  -- Número do pedido no marketplace externo
    C.AD_WAREHOUSEID,                       -- Identificador do armazém no sistema externo

    -- =========================================================================
    -- Dados fiscais da NF-e
    -- =========================================================================
    C.CHAVENFE,    -- Chave de acesso da NF-e (44 dígitos) para rastreamento fiscal

    -- XML da NF-e no formato para envio ao cliente (XMLENVCLI).
    -- Buscado por subquery correlacionada em TGFNFE para evitar JOIN adicional
    -- que pudesse multiplicar linhas quando há mais de um registro por nota.
    (
        SELECT NFE.XMLENVCLI
        FROM   TGFNFE NFE
        WHERE  NFE.NUNOTA = C.NUNOTA
    ) AS NOTAXML

FROM TGFCAB C
-- JOIN com TGFITE garante que apenas notas com itens registrados são retornadas.
-- O GROUP BY a seguir resolve as duplicações decorrentes deste JOIN (1 nota : N itens).
LEFT JOIN TGFITE ITE ON C.NUNOTA = ITE.NUNOTA

WHERE C.TIPMOV    IN ('V')             -- Apenas movimentos de venda
  AND C.CODVEND   IN (42)              -- Vendedor e-commerce (ajustar se necessário)
  AND C.STATUSNFE  = 'A'              -- NF-e autorizada pela SEFAZ
  AND C.CHAVENFE IS NOT NULL          -- Nota com chave de acesso emitida
  AND C.DHPROTOC  > TRUNC(SYSDATE) - 4 -- Protocolo de autorização nos últimos 4 dias

GROUP BY
    C.NUNOTA,
    C.CODVEND,
    C.AD_PEDIDOMKTPLACE,
    C.AD_WAREHOUSEID,
    C.CHAVENFE;
