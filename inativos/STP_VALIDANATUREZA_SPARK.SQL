CREATE OR REPLACE PROCEDURE STP_VALIDANATUREZA_SPARK (
    P_NUNOTA      IN  NUMBER,
    P_SUCESSO     OUT VARCHAR2,
    P_MENSAGEM    OUT VARCHAR2,
    P_CODUSULIB   OUT NUMBER
) AS
/*==============================================================================
  Nome do Script : STP_VALIDANATUREZA_SPARK
  Descrição      : Regra de negócio para validar a natureza de operação do
                   lançamento fiscal.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 19/01/2023
  Última Revisão : 28/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/
    -- Declaração de variáveis internas
    P_CODNATC NUMBER;
BEGIN
    -- Buscar o código da natureza
    SELECT NVL(CODNAT, 0)
      INTO P_CODNATC
      FROM TGFCAB
     WHERE NUNOTA = P_NUNOTA;

    -- Atualizar o código de natureza no financeiro
    UPDATE TGFFIN
       SET CODNAT = P_CODNATC
     WHERE NUNOTA = P_NUNOTA;

    -- Definir sucesso
    P_SUCESSO := 'S';
    P_MENSAGEM := 'Natureza validada e atualizada com sucesso.';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Tratamento se nota não for encontrada
        P_SUCESSO := 'N';
        P_MENSAGEM := 'Nota fiscal não encontrada para validação.';
    WHEN OTHERS THEN
        -- Tratamento de erro genérico
        P_SUCESSO := 'N';
        P_MENSAGEM := 'Erro ao validar natureza: ' || SQLERRM;
END;
