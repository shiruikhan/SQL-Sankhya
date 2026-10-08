create or replace PROCEDURE STP_BUSCAATRIBML_SPARK (
    P_CODUSU     IN  NUMBER,
    P_IDSESSAO   IN  VARCHAR2,
    P_QTDLINHAS  IN  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_BUSCAATRIBML_SPARK
  Descrição      : Busca e insere atributos do produto relacionados ao Mercado
                   Livre, evitando duplicidade com base no campo IDATRIBUTO.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 21/05/2025
  Última Revisão : 21/05/2025
==============================================================================*/

    -- Variáveis para armazenamento dos parâmetros extraídos da sessão
    FIELD_CODPROD    NUMBER;
    FIELD_ID         NUMBER;
    FIELD_IDANUNCIO  NUMBER;
    V_MLB            AD_MKTPMELI.CATEGORY_ID%TYPE;

BEGIN
    -- Extração dos parâmetros da sessão
    FIELD_CODPROD   := ACT_INT_FIELD(P_IDSESSAO, 1, 'CODPROD');
    FIELD_ID        := ACT_INT_FIELD(P_IDSESSAO, 1, 'ID');
    FIELD_IDANUNCIO := ACT_INT_FIELD(P_IDSESSAO, 1, 'IDANUNCIO');

    -- Busca do Category ID (MLB) na tabela principal
    SELECT CATEGORY_ID
      INTO V_MLB
      FROM AD_MKTPMELI
     WHERE CODPROD   = FIELD_CODPROD
       AND IDANUNCIO = FIELD_IDANUNCIO
       AND ID        = FIELD_ID;

    -- Inserção de atributos não existentes (verifica duplicidade por IDATRIBUTO)
    INSERT INTO AD_MKTPMELIATRIB (
        DESCRATRIB, CODPROD, IDANUNCIO, HIERARCHY, TAGS, IDATRIBUTO, ID
    )
    SELECT 
        A.DESCRATRIB,
        FIELD_CODPROD,
        FIELD_IDANUNCIO,
        A.HIERARCHY,
        A.TAGS,
        A.IDATRIBUTO,
        FIELD_ID
      FROM AD_CADMKTATRIB A
     WHERE A.MLB = V_MLB
       AND NOT EXISTS (
           SELECT 1
             FROM AD_MKTPMELIATRIB B
            WHERE B.CODPROD    = FIELD_CODPROD
              AND B.IDANUNCIO = FIELD_IDANUNCIO
              AND B.ID        = FIELD_ID
              AND B.IDATRIBUTO = A.IDATRIBUTO
       );

    -- Verificação do resultado da inserção
    IF SQL%ROWCOUNT = 0 THEN
        P_MENSAGEM := 'Nenhum novo atributo foi inserido para o produto ' || V_MLB || '.';
    ELSE
        P_MENSAGEM := 'Foram inseridos ' || SQL%ROWCOUNT || ' novos atributos para o anúncio.';
    END IF;

-- Tratamento de exceções
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        P_MENSAGEM := 'Produto ou anúncio não encontrado para os parâmetros informados.';
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro inesperado: ' || SQLERRM;
END;