CREATE OR REPLACE PROCEDURE STP_REGRA_VALID_AVISTA_SPARK (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) IS
/*==============================================================================
  Nome do Script : STP_REGRA_VALID_AVISTA_SPARK
  Tipo           : Procedure (Regra de Negócio)
  Descrição      : Procedure para validação de venda à vista. Verifica se títulos
                   vencidos no dia são recebimento à vista ou requerem confirmação.
                   Exceções (não exigem liberação do financeiro):
                   - títulos com CODTIPTIT 34, 35 e 36;
                   - notas do e-commerce (TGFCAB.CODVEND = 6): sempre à vista,
                     já validadas pela plataforma.

  Parâmetros     : P_NUNOTA      — número único da nota fiscal
                   P_SUCESSO     — indicador de sucesso da regra (OUT)
                   P_MENSAGEM    — mensagem de retorno ao usuário (OUT)
                   P_CODUSULIB   — código do usuário liberador (OUT)
  Tabelas        : TGFFIN, TGFCAB
  Uso            : Regra de negócio do Sankhya (validação financeira à vista)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Exceção para vendas do e-commerce (CODVEND = 6)

  Observações    : CODVEND do e-commerce (6) e CODTIPTIT 34, 35 e 36 são valores
                   fixos no código. P_CODUSULIB não é preenchido por esta regra.
==============================================================================*/
    V_CODVEND_ECOMMERCE CONSTANT TGFCAB.CODVEND%TYPE := 6;
    V_CODVEND           TGFCAB.CODVEND%TYPE;
    V_VALIDO            BOOLEAN := TRUE;

    CURSOR C_DTVENC IS
        SELECT  FIN.DTVENC
               ,FIN.CODTIPTIT
        FROM    TGFFIN FIN
        WHERE   FIN.NUNOTA = P_NUNOTA;
BEGIN
    ---------------------------------------------------------------------------
    -- 1. Identifica o vendedor da nota (CODVEND = 6 => venda do e-commerce)
    ---------------------------------------------------------------------------
    BEGIN
        SELECT  CAB.CODVEND
        INTO    V_CODVEND
        FROM    TGFCAB CAB
        WHERE   CAB.NUNOTA = P_NUNOTA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_CODVEND := NULL;
    END;

    ---------------------------------------------------------------------------
    -- 2. Valida os títulos com vencimento no dia (e-commerce dispensa a regra)
    ---------------------------------------------------------------------------
    IF NVL(V_CODVEND, -1) <> V_CODVEND_ECOMMERCE THEN
        FOR R_FIN IN C_DTVENC LOOP
            IF TRUNC(R_FIN.DTVENC) = TRUNC(SYSDATE) AND R_FIN.CODTIPTIT NOT IN (34,35,36) THEN
                V_VALIDO := FALSE;
                EXIT;
            END IF;
        END LOOP;
    END IF;

    ---------------------------------------------------------------------------
    -- 3. Retorno da regra
    ---------------------------------------------------------------------------
    IF V_VALIDO THEN
        P_SUCESSO := 'S';
    ELSE
        P_MENSAGEM := 'É necessária confirmação do recebimento pelo financeiro';
        P_SUCESSO := 'N';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'STP_REGRA_VALID_AVISTA_SPARK - NUNOTA ' || P_NUNOTA || ': ' || SQLERRM);
END STP_REGRA_VALID_AVISTA_SPARK;
