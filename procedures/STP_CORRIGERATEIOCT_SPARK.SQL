/*==============================================================================
  Nome do Script : STP_CORRIGERATEIOCT_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : Corrigir o valor do rateio do frete, pois estão corrigindo manualmente a cada lançamento de CTE. O objetivo da personalização é corrigir o CTE se encontrar a nota. Caso contrário, segue o fluxo sem travar os lançamentos de CTE.
  Autor          : Lucas Gabriel - DM TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 20/01/2025, última alteração em 26/08/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_CORRIGERATEIOCT_SPARK" (
    P_TIPOEVENTO INT,   
    P_IDSESSAO VARCHAR2, 
    P_CODUSU INT         
) AS
    BEFORE_INSERT INT;
    AFTER_INSERT  INT;
    BEFORE_DELETE INT;
    AFTER_DELETE  INT;
    BEFORE_UPDATE INT;
    AFTER_UPDATE  INT;
    BEFORE_COMMIT INT;
    V_CHAVE        TGFNCT.CHAVENFE%TYPE;
    V_VLRNOTA      TGFCAB.VLRNOTA%TYPE;
    V_EXISTE       INT;
BEGIN
    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;

    /*******************************************************************************
    Autor: Lucas Gabriel - DM TECH
    Data: 20/01/2025
    Objetivo: Corrigir o valor do rateio do frete, pois estão corrigindo manualmente 
    a cada lançamento de CTE. O objetivo da personalização é corrigir o CTE se encontrar 
    a nota. Caso contrário, segue o fluxo sem travar os lançamentos de CTE.
    ********************************************************************************/

    IF P_TIPOEVENTO = AFTER_INSERT THEN
        BEGIN
            V_CHAVE := NULL;

            /*Tenta obter a chave NFe correspondente*/
            BEGIN
                SELECT CHAVENFE
                INTO V_CHAVE
                FROM TGFNCT NCT
                WHERE NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA')
                  AND SEQUENCIA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'SEQUENCIA');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    /*Se a chave não for encontrada, retorna sem fazer nada*/
                    RETURN;
            END;

            /*Verifica se a chave tem o comprimento correto*/
            IF LENGTH(V_CHAVE) = 44 THEN
                /* Verifica se a chave existe na tabela TGFCAB*/
                BEGIN
                    SELECT COUNT(*)
                    INTO V_EXISTE
                    FROM TGFCAB
                    WHERE CHAVENFE = V_CHAVE;

                    /*Se a chave não existir, retorna*/
                    IF V_EXISTE = 0 THEN
                        RETURN;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN;
                END;

                /*Obtém o valor da nota*/
                SELECT MAX(VLRNOTA)
                INTO V_VLRNOTA
                FROM TGFCAB
                WHERE CHAVENFE = V_CHAVE;

                /* Atualiza o valor da nota na tabela TGFNCT*/
                UPDATE TGFNCT
                SET VLRNOTA = V_VLRNOTA
                WHERE NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA')
                  AND SEQUENCIA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'SEQUENCIA');
            ELSE
                /*Se o comprimento da chave for inválido, retorna*/
                RETURN;
            END IF;
        END;
    END IF;
END;
