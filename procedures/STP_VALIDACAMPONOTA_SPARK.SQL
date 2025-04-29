CREATE OR REPLACE PROCEDURE STP_VALIDACAMPONOTA_SPARK (
    P_NUNOTA        IN  INT,
    P_SUCESSO       OUT VARCHAR2,
    P_MENSAGEM      OUT VARCHAR2,
    P_CODUSULIB     OUT NUMBER
) AS
/*==============================================================================
  Nome do Script : STP_VALIDACAMPONOTA_SPARK
  Descrição      : Valida os campos CST do ICMS e CST do IPI em cada item da nota.
                   Caso qualquer um esteja nulo ou não preenchido (assumido como 9999),
                   interrompe a execução e retorna mensagem de erro.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data Criação   : 16/01/2023
  Última Revisão : 29/04/2025
  Melhorias      : Legibilidade, uso de cursor, tratamento de exceção simplificado.
==============================================================================*/

    CURSOR C_ITENS IS
        SELECT 
            NVL(CODTRIB, 9999) AS CODTRIB,
            NVL(CSTIPI,  9999) AS CSTIPI
        FROM TGFITE
        WHERE NUNOTA = P_NUNOTA;

    V_CODTRIB  NUMBER;
    V_CSTIPI   NUMBER;

BEGIN
    P_SUCESSO  := 'S'; -- Assume sucesso inicialmente
    P_MENSAGEM := NULL;

    -- Verifica se existem itens para a nota
    IF NOT C_ITENS%ISOPEN THEN
        OPEN C_ITENS;
    END IF;

    LOOP
        FETCH C_ITENS INTO V_CODTRIB, V_CSTIPI;
        EXIT WHEN C_ITENS%NOTFOUND;

        IF V_CODTRIB = 9999 OR V_CSTIPI = 9999 THEN
            P_SUCESSO  := 'N';
            P_MENSAGEM := 'Os campos CST do ICMS ou CST do IPI estão zerados e precisam ser preenchidos!';
            CLOSE C_ITENS;
            RETURN;
        END IF;
    END LOOP;

    CLOSE C_ITENS;

EXCEPTION
    WHEN OTHERS THEN
        P_SUCESSO  := 'N';
        P_MENSAGEM := 'Erro ao validar os campos da nota: ' || SQLERRM;
END;