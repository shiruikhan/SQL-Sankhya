CREATE OR REPLACE PROCEDURE STP_CLASSIFICACTE_SPARK AS
/*==============================================================================
  Nome do Script : STP_CLASSIFICACTE_SPARK
  Tipo           : Procedure de Ação Agendada (STP)
  Descrição      : Classifica automaticamente o CODTIPOPER de CT-es pendentes
                   em TGFIXN com base nos CODTIPOPERs das NF-e referenciadas
                   no XML, consultando VW_CTE_AUTORIZADOS.

                   Executa em lote, substituindo os dois pontos de disparo da
                   EVP_CLASSIFICACTE_SPARK (AFTER_INSERT e AFTER_UPDATE):
                   — Processa todos os CT-es (TIPO='C') ainda não despachados
                     pelo agendador (DHPROCAG IS NULL) cujas NF-e referenciadas
                     já existam em TGFCAB.
                   — Ideal para ser executada periodicamente como ação agendada
                     no Sankhya, garantindo que CT-es importados antes do
                     processamento das NF-e sejam classificados retroativamente.

                   Regras de mapeamento (por prioridade):
                     CODTIPOPER_NFE IN (214, 1125, 1211)                          -> TOP 225
                     CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202)       -> TOP 226
                     CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228,
                                        266, 233, 1119, 1108)                     -> TOP 242
                     CODTIPOPER_NFE IN (201, 221, 209)                            -> TOP 234

  Tabelas        : TGFIXN      -- portal de importacao de XML (CT-e e NF-e)
  Tabela de Log  : AD_LOG_ERROS -- erros registrados com operacao, NUNOTA,
                                   codigo/mensagem do erro, backtrace e call stack
  Dependencias   : VW_CTE_AUTORIZADOS -- lista CT-es autorizados com CODTIPOPER
                                         das NF-e referenciadas (via TGFCAB.CHAVENFE)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Senior
  Empresa        : Spark Eletronica
  Data de Criacao: Maio/2026
  Ultima Revisao : Maio/2026 -- Adaptacao de EVP_CLASSIFICACTE_SPARK para STP
==============================================================================*/

    -- Variaveis (devem preceder qualquer subprograma)
    V_NEW_TOP NUMBER;

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_NUNOTA        NUMBER,
        P_ERR_CODE      NUMBER,
        P_ERR_MSG       VARCHAR2,
        P_ERR_BACKTRACE VARCHAR2,
        P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'STP_CLASSIFICACTE_SPARK', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

    -- Retorna o CODTIPOPER correto para um CT-e pelo seu NUNOTA.
    -- Prioridade: 225 > 226 > 242 > 234. Retorna NULL se nenhuma NF-e referenciada existir em TGFCAB.
    FUNCTION FN_CLASSIFICA(P_NUNOTA_CTE NUMBER) RETURN NUMBER IS
        V_TOP      NUMBER := NULL;
        V_PRIORITY NUMBER := 999;
    BEGIN
        FOR R IN (
            SELECT CODTIPOPER_NFE
            FROM   VW_CTE_AUTORIZADOS
            WHERE  NUNOTA          = P_NUNOTA_CTE
              AND  CODTIPOPER_NFE IS NOT NULL
        ) LOOP
            IF R.CODTIPOPER_NFE IN (214, 1125, 1211) THEN
                RETURN 225;
            ELSIF R.CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202) AND V_PRIORITY > 2 THEN
                V_TOP := 226; V_PRIORITY := 2;
            ELSIF R.CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228, 266, 233, 1119, 1108) AND V_PRIORITY > 3 THEN
                V_TOP := 242; V_PRIORITY := 3;
            ELSIF R.CODTIPOPER_NFE IN (201, 221, 209) AND V_PRIORITY > 4 THEN
                V_TOP := 234; V_PRIORITY := 4;
            END IF;
        END LOOP;
        RETURN V_TOP;
    END FN_CLASSIFICA;

BEGIN
    -- Percorre CT-es nao despachados (DHPROCAG IS NULL).
    -- O Sankhya define CODTIPOPER=225 como padrao na criacao do registro em TGFIXN,
    -- portanto o filtro usa DHPROCAG IS NULL em vez de CODTIPOPER IS NULL.
    FOR CTE_REC IN (
        SELECT NUNOTA
        FROM   TGFIXN
        WHERE  TIPO     = 'C'
          AND  DHPROCAG IS NULL
    ) LOOP
        BEGIN
            V_NEW_TOP := FN_CLASSIFICA(CTE_REC.NUNOTA);

            IF V_NEW_TOP IS NOT NULL THEN
                UPDATE TGFIXN
                   SET CODTIPOPER = V_NEW_TOP
                 WHERE NUNOTA     = CTE_REC.NUNOTA;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_ERRO(
                    P_OPERACAO      => 'CLASSIFICACAO_CTE',
                    P_NUNOTA        => CTE_REC.NUNOTA,
                    P_ERR_CODE      => SQLCODE,
                    P_ERR_MSG       => SQLERRM,
                    P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                    P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
                );
        END;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO(
            P_OPERACAO      => 'LOOP_PRINCIPAL',
            P_NUNOTA        => NULL,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20001, 'Erro em STP_CLASSIFICACTE_SPARK: ' || SQLERRM);
END;
