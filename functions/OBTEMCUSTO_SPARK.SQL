CREATE OR REPLACE FUNCTION OBTEMCUSTO_SPARK (
    P_CODPROD     IN NUMBER,    -- Código do produto
    P_POREMP      IN CHAR,      -- Filtrar por empresa?   'S' = sim / 'N' = não
    P_CODEMP      IN NUMBER,    -- Código da empresa (usado quando P_POREMP = 'S')
    P_PORLOCAL    IN CHAR,      -- Filtrar por local?     'S' = sim / 'N' = não
    P_CODLOCAL    IN NUMBER,    -- Código do local (usado quando P_PORLOCAL = 'S')
    P_PORCONTROLE IN CHAR,      -- Filtrar por controle?  'S' = sim / 'N' = não
    P_CONTROLE    IN VARCHAR2,  -- Controle (série/lote, usado quando P_PORCONTROLE = 'S')
    P_DATA        IN DATE,      -- Data de referência para buscar o custo vigente
    P_TIPO        IN NUMBER     -- Tipo de custo desejado (ver tabela na seção Retorno)
)
RETURN FLOAT
/*==============================================================================
  Nome do Script : OBTEMCUSTO_SPARK
  Tipo           : Function
  Descrição      : Retorna o custo de um produto conforme critérios de empresa,
                   local de estoque, controle (série/lote) e data de referência.

                   A função busca o registro mais recente em TGFCUS com data
                   de atualização anterior ou igual a P_DATA (MAX(DTATUAL)),
                   garantindo que o custo retornado seja o vigente naquela data.

                   Retorna 0 em qualquer cenário de falha (produto sem custo
                   cadastrado ou erro inesperado).

  Parâmetros     :
    P_CODPROD      — Código do produto (TGFPRO.CODPROD)
    P_POREMP       — 'S' para filtrar por empresa; 'N' para ignorar empresa
    P_CODEMP       — Código da empresa (TGFEMP.CODEMP), ativo quando P_POREMP='S'
    P_PORLOCAL     — 'S' para filtrar por local; 'N' para ignorar local
    P_CODLOCAL     — Código do local de estoque (TGFLOC.CODLOCAL)
    P_PORCONTROLE  — 'S' para filtrar por controle; 'N' para ignorar
    P_CONTROLE     — Identificador do controle (série ou lote do produto)
    P_DATA         — Data de referência: busca o custo mais recente até esta data
    P_TIPO         — Tipo de custo a retornar (ver abaixo)

  Retorno (P_TIPO):
    0  — Custo de reposição      (TGFCUS.CUSREP)
    1  — Custo médio             (TGFCUS.CUSMED)
    2  — Custo variável          (TGFCUS.CUSVARIAVEL)
    3  — Custo sem ICMS          (TGFCUS.CUSSEMICM)
    4  — Custo médio com ICMS    (TGFCUS.CUSMEDICM)
    5  — Entrada sem ICMS        (TGFCUS.ENTRADASEMICMS)
    6  — Entrada com ICMS        (TGFCUS.ENTRADACOMICMS)
    outros — retorna 0

  Tabela fonte   : TGFCUS — histórico de custos de produto do Sankhya
                   (uma linha por produto/empresa/local/controle/data)

  Uso            : Procedures de transferência entre empresas (STP_TRANSFEMP_SPARK),
                   análise de margem e relatórios de custo de produto.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 10/03/2022
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários

  Observações    : - Se não existir custo cadastrado para os critérios informados,
                     todos os campos são retornados como 0 (via NVL na query e
                     valores-padrão nas variáveis declaradas).
                   - A subquery interna usa MAX(DTATUAL) <= P_DATA para garantir
                     que o custo buscado seja o mais recente até a data informada,
                     sem capturar atualizações futuras ao evento avaliado.
                   - Os filtros P_PORLOCAL, P_POREMP e P_PORCONTROLE com valor 'N'
                     ignoram o respectivo critério, permitindo busca consolidada
                     (ex: custo médio geral sem distinção por empresa/local).
==============================================================================*/
IS
    -- Variáveis para receber cada tipo de custo da tabela TGFCUS.
    -- Inicializadas com 0 para garantir retorno seguro em caso de NOT FOUND.
    V_CUSREP          TGFCUS.CUSREP%TYPE         := 0;  -- Custo de reposição
    V_CUSGER          TGFCUS.CUSMED%TYPE          := 0;  -- Custo médio (gerencial)
    V_CUSVARIAVEL     TGFCUS.CUSVARIAVEL%TYPE     := 0;  -- Custo variável
    V_CUSSEMICM       TGFCUS.CUSSEMICM%TYPE       := 0;  -- Custo sem ICMS
    V_CUSMEDICM       TGFCUS.CUSMEDICM%TYPE       := 0;  -- Custo médio com ICMS
    V_ENTRADASEMICMS  TGFCUS.ENTRADASEMICMS%TYPE  := 0;  -- Última entrada sem ICMS
    V_ENTRADACOMICMS  TGFCUS.ENTRADACOMICMS%TYPE  := 0;  -- Última entrada com ICMS

BEGIN
    -- =========================================================================
    -- BUSCA DO CUSTO VIGENTE NA DATA INFORMADA:
    -- Localiza o registro de custo mais recente em TGFCUS com DTATUAL <= P_DATA,
    -- respeitando os filtros opcionais de empresa, local e controle.
    --
    -- A subquery com MAX(DTATUAL) garante que, entre os registros que atendem
    -- os critérios e têm data anterior ou igual à referência, apenas o mais
    -- recente seja retornado (custo vigente naquela data).
    -- =========================================================================
    BEGIN
        SELECT NVL(CUSREP,         0),
               NVL(CUSMED,         0),
               NVL(CUSVARIAVEL,    0),
               NVL(CUSSEMICM,      0),
               NVL(CUSMEDICM,      0),
               NVL(ENTRADASEMICMS, 0),
               NVL(ENTRADACOMICMS, 0)
          INTO V_CUSREP,
               V_CUSGER,
               V_CUSVARIAVEL,
               V_CUSSEMICM,
               V_CUSMEDICM,
               V_ENTRADASEMICMS,
               V_ENTRADACOMICMS
          FROM TGFCUS
         WHERE CODPROD  = P_CODPROD
           -- Filtro opcional por controle (série/lote)
           AND (P_PORCONTROLE = 'N' OR CONTROLE  = P_CONTROLE)
           -- Filtro opcional por local de estoque
           AND (P_PORLOCAL    = 'N' OR CODLOCAL  = P_CODLOCAL)
           -- Filtro opcional por empresa
           AND (P_POREMP      = 'N' OR CODEMP    = P_CODEMP)
           -- Seleciona apenas o registro com a data mais recente até P_DATA
           AND DTATUAL = (
               SELECT MAX(DTATUAL)
                 FROM TGFCUS CN
                WHERE CODPROD  = P_CODPROD
                  AND DTATUAL <= P_DATA
                  AND (P_PORCONTROLE = 'N' OR CONTROLE = P_CONTROLE)
                  AND (P_PORLOCAL    = 'N' OR CODLOCAL = P_CODLOCAL)
                  AND (P_POREMP      = 'N' OR CODEMP   = P_CODEMP)
           );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Produto sem custo cadastrado para os critérios informados.
            -- Variáveis já estão em 0; nenhuma ação necessária.
            NULL;
    END;

    -- =========================================================================
    -- SELEÇÃO DO TIPO DE CUSTO A RETORNAR:
    -- Baseada no parâmetro P_TIPO. Qualquer valor não mapeado retorna 0.
    -- =========================================================================
    CASE P_TIPO
        WHEN 0 THEN RETURN V_CUSREP;          -- Custo de reposição
        WHEN 1 THEN RETURN V_CUSGER;          -- Custo médio
        WHEN 2 THEN RETURN V_CUSVARIAVEL;     -- Custo variável
        WHEN 3 THEN RETURN V_CUSSEMICM;       -- Custo sem ICMS
        WHEN 4 THEN RETURN V_CUSMEDICM;       -- Custo médio com ICMS
        WHEN 5 THEN RETURN V_ENTRADASEMICMS;  -- Entrada sem ICMS
        WHEN 6 THEN RETURN V_ENTRADACOMICMS;  -- Entrada com ICMS
        ELSE        RETURN 0;                 -- Tipo desconhecido
    END CASE;

EXCEPTION
    WHEN OTHERS THEN
        -- Retorna 0 em qualquer falha inesperada para não interromper
        -- o processo chamador com erro de função.
        RETURN 0;

END OBTEMCUSTO_SPARK;
