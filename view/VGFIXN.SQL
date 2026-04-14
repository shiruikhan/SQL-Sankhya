/*==============================================================================
  Nome do Script : VW_CTE_AUTORIZADOS
  Arquivo        : VGFIXN.SQL
  Tipo           : VIEW
  Descrição      : Retorna todos os CT-e autorizados que possuem documentos
                   fiscais referenciados (NF-e) em seu XML de origem (DOCSREF).
                   Para cada CT-e, extrai cada chave de acesso referenciada
                   usando XMLTABLE e busca o CODTIPOPER da NF-e correspondente
                   na tabela TGFCAB.

                   Esta view é o ponto central para identificar a qual tipo de
                   operação pertence a NF-e transportada pelo CT-e, viabilizando
                   a classificação automática do conhecimento de transporte.

  Tabelas fonte  : TGFIXN  — arquivo de XML importado (CT-e, NF-e)
                   TGFCAB  — cabeçalho de nota (para busca de CODTIPOPER da NF-e)

  Colunas        :
    NRARQUIVO       — número do arquivo XML importado (alias de NUARQUIVO)
    NUMNOTA         — número da nota fiscal no documento
    NUNOTA          — número único da nota no Sankhya
    CHAVEACESSO     — chave de acesso do CT-e (44 dígitos)
    DHIMPORT        — data e hora de importação do XML
    DHPROCESS       — data e hora de processamento do CT-e
    XML             — XML completo do CT-e importado
    TIPO            — tipo do documento ('C' = CT-e)
    CODUSUIMP       — usuário que realizou a importação
    CODUSUPROC      — usuário que realizou o processamento
    CODTIPOPER      — tipo de operação vinculado ao CT-e no Sankhya
    SITUACAOCTE     — situação do CT-e ('A' = Autorizado)
    ULTEVEDFE       — último evento DFe registrado
    DOCSREF         — XML com as chaves de acesso dos documentos referenciados
    CHAVEACESSO_REF — chave de acesso da NF-e referenciada (extraída do XML)
    CODTIPOPER_NFE  — tipo de operação da NF-e referenciada (via TGFCAB)
    NR_SEQUENCIA    — número de sequência do documento referenciado no XML
    CNPJREMET       — CNPJ do remetente
    CNPJDEST        — CNPJ do destinatário
    CFOPXML         — CFOP extraído do XML do CT-e

  Filtros ativos : TIPO = 'C'           — apenas CT-e (não NF-e, MDF-e, etc.)
                   SITUACAOCTE = 'A'    — apenas documentos autorizados
                   DOCSREF IS NOT NULL  — apenas CT-e com documentos referenciados

  Uso            : - Regra de processamento automático de CT-e
                     (formulas/regra_processa_xml_cte.sql)
                   - Evento EVP_CLASSIFICACTE_SPARK: classificação automática
                     do CT-e com base no CODTIPOPER da NF-e referenciada

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 2023
  Última Revisão : Abril/2026 — Padronização de cabeçalho, comentários e formatação

  Observações    : - Um CT-e pode referenciar múltiplas NF-e. Neste caso, a view
                     retorna uma linha por chave referenciada (XMLTABLE expande
                     a lista de chaves do XML em linhas individuais).
                   - A subquery de CODTIPOPER_NFE usa ROWNUM = 1 para evitar
                     duplicações quando há mais de uma nota com a mesma chave.
                   - O arquivo se chama VGFIXN.SQL pois é baseado na tabela
                     TGFIXN (importações de XML do Sankhya).
==============================================================================*/

CREATE OR REPLACE VIEW VW_CTE_AUTORIZADOS AS

SELECT
    -- =========================================================================
    -- Campos de identificação do CT-e no Sankhya
    -- =========================================================================
    X.NUARQUIVO  AS NRARQUIVO,   -- Número do arquivo XML importado
    X.NUMNOTA,                   -- Número da nota no documento
    X.NUNOTA,                    -- Número único da nota no Sankhya (FK para TGFCAB)
    X.CHAVEACESSO,               -- Chave de acesso do CT-e (44 dígitos)

    -- =========================================================================
    -- Datas de processamento
    -- =========================================================================
    X.DHIMPORT,                  -- Data/hora de importação do XML no Sankhya
    X.DHPROCESS,                 -- Data/hora de processamento do CT-e

    -- =========================================================================
    -- Conteúdo do documento
    -- =========================================================================
    X.XML,                       -- XML completo do CT-e
    X.TIPO,                      -- Tipo do documento: 'C' = CT-e
    X.CODUSUIMP,                 -- Usuário responsável pela importação
    X.CODUSUPROC,                -- Usuário responsável pelo processamento
    X.CODTIPOPER,                -- Tipo de operação do CT-e vinculado no Sankhya
    X.SITUACAOCTE,               -- Situação: 'A' = Autorizado
    X.ULTEVEDFE,                 -- Último evento DFe (cancelamento, correção, etc.)

    -- =========================================================================
    -- Documentos referenciados (NF-e transportadas pelo CT-e)
    -- =========================================================================
    X.DOCSREF,                   -- XML com a lista de chaves de acesso referenciadas

    -- Chave de acesso individual extraída do DOCSREF via XMLTABLE
    -- (uma linha por NF-e referenciada no CT-e)
    T.CHAVEACESSO_REF,

    -- Busca o CODTIPOPER da NF-e referenciada no Sankhya.
    -- ROWNUM = 1 evita duplicação quando múltiplas notas compartilham a mesma chave.
    (
        SELECT CODTIPOPER
        FROM   TGFCAB
        WHERE  CHAVENFE = T.CHAVEACESSO_REF
        AND    ROWNUM   = 1
    ) AS CODTIPOPER_NFE,

    -- Posição sequencial do documento dentro do XML de referências
    T.NR_SEQUENCIA,

    -- =========================================================================
    -- Dados de emitente e destinatário do CT-e
    -- =========================================================================
    X.CNPJREMET,                 -- CNPJ do remetente da carga
    X.CNPJDEST,                  -- CNPJ do destinatário da carga
    X.CFOPXML                    -- CFOP extraído diretamente do XML do CT-e

FROM TGFIXN X,
     /*
      * XMLTABLE: expande o XML de documentos referenciados (DOCSREF) em linhas.
      * Para cada elemento <chaveAcesso> dentro de <docsRef>, gera uma linha
      * com a chave de acesso (CHAVEACESSO_REF) e sua posição (NR_SEQUENCIA).
      *
      * Exemplo de estrutura XML esperada em DOCSREF:
      *   <docsRef>
      *     <chaveAcesso>3524...</chaveAcesso>
      *     <chaveAcesso>3524...</chaveAcesso>
      *   </docsRef>
      */
     XMLTABLE(
         '/docsRef/chaveAcesso'
         PASSING XMLTYPE(X.DOCSREF)
         COLUMNS
             CHAVEACESSO_REF  VARCHAR2(50)  PATH '.',          -- Valor do nó (chave de 44 dígitos)
             NR_SEQUENCIA     FOR ORDINALITY                   -- Posição sequencial no XML
     ) T

-- =========================================================================
-- Filtros: apenas CT-e autorizados com documentos referenciados no XML
-- =========================================================================
WHERE X.TIPO        = 'C'    -- CT-e (Knowledge of Electronic Transport)
  AND X.SITUACAOCTE = 'A'    -- Situação: Autorizado (descarta cancelados, denegados)
  AND X.DOCSREF IS NOT NULL; -- Apenas CT-e com NF-e(s) referenciadas no XML
