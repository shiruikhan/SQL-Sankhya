CREATE OR REPLACE PROCEDURE STP_ALTCAMOUTROS_SPARK_COMP (
    P_NUNOTA     INT,            -- Número da nota fiscal
    P_SEQUENCIA  INT,            -- Sequência da linha (não utilizado atualmente)
    P_SUCESSO    OUT VARCHAR,    -- Indicador de sucesso ('S' ou 'N')
    P_MENSAGEM   OUT VARCHAR2,   -- Mensagem para exibição ao usuário
    P_CODUSULIB  OUT NUMBER      -- Código do usuário que liberou (não utilizado atualmente)
) AS
/*==============================================================================
  Nome do Script : Stp_ALTCAMOUTROS_SPARK_COMP
  Descrição      : Atualiza o campo VLROUTROS da tabela TGFCAB com a soma do
                   campo AD_VLROUTROSCOMP dos itens da nota na TGFITE.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 23/08/2022
  Última Revisão : 02/07/2025
  Melhorias      : Estrutura padronizada, comentários explicativos, tratamento limpo.
==============================================================================*/

    P_VLROUTROS NUMBER;

BEGIN
    -- Inicializa como sucesso
    P_SUCESSO := 'S';

    -- Calcula a soma de valores adicionais dos itens da nota
    SELECT NVL(SUM(AD_VLROUTROSCOMP), 0)
      INTO P_VLROUTROS
      FROM TGFITE
     WHERE NUNOTA = P_NUNOTA;

    -- Atualiza o campo VLROUTROS no cabeçalho da nota
    IF P_VLROUTROS >= 0 THEN
        UPDATE TGFCAB
           SET VLROUTROS = P_VLROUTROS
         WHERE NUNOTA = P_NUNOTA;
    END IF;

    -- (opcional) valores de mensagem ou controle podem ser atribuídos aqui
    -- P_MENSAGEM := 'Atualização realizada com sucesso.';
    -- P_CODUSULIB := 0;

EXCEPTION
    WHEN OTHERS THEN
        P_SUCESSO := 'N';
        P_MENSAGEM := 'Erro ao atualizar valor de VLROUTROS: ' || SQLERRM;
END;