create or replace PROCEDURE "STP_PREENCHEVLRUNIT_SPARK" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS

/*==============================================================================
  Nome do Script : STP_PREENCHEVLRUNIT_SPARK
  Descrição      : Preenche o valor unitário de um produto em operações de 
                   movimentação interna tomando como base a função 
                   OBTEMCUSTO_SPARK.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 21/03/2022
  Última Revisão : 23/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/

    FIELD_NUNOTA NUMBER;
    FIELD_CODPROD NUMBER;
    V_VLRUNIT NUMBER;

    FIELD_NUNOTA   NUMBER;
    FIELD_CODPROD  NUMBER;
    V_VLRUNIT      NUMBER;

    CURSOR C_PRODUTOS (P_NUNOTA NUMBER) IS
        SELECT CODPROD
        FROM TGFITE
        WHERE NUNOTA = P_NUNOTA;

BEGIN

       FOR I IN 1..P_QTDLINHAS LOOP
           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');  FOR R_PROD IN C_PRODUTOS(FIELD_NUNOTA) LOOP
            FIELD_CODPROD := R_PROD.CODPROD;

            -- Calcula o valor unitário via função
            V_VLRUNIT := OBTEMCUSTO_SPARK(FIELD_CODPROD, 'N', 0, 'N', 0, 'N', NULL, SYSDATE, 1);

            -- Atualiza os registros se o custo for válido
            IF V_VLRUNIT IS NOT NULL THEN
                UPDATE TGFITE
                SET VLRUNIT = NVL(V_VLRUNIT, 0.1),
                    VLRTOT = QTDNEG * NVL(V_VLRUNIT, 0.1)
                WHERE NUNOTA = FIELD_NUNOTA
                  AND CODPROD = FIELD_CODPROD;
            END IF;
        END LOOP;
    END LOOP;

    P_MENSAGEM := 'Registros atualizados com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro: ' || SQLERRM;
END;