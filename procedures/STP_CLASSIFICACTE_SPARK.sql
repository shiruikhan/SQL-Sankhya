CREATE OR REPLACE PROCEDURE STP_CLASSIFICACTE_SPARK AS
/*==============================================================================
  Nome do Script : STP_CLASSIFICACTE_SPARK
  Tipo           : Procedure de Ação Agendada (STP)
  Descrição      : Classifica automaticamente o CODTIPOPER de CT-es pendentes
                   em TGFIXN com base nos CODTIPOPERs das NF-e referenciadas
                   no XML, consultando VW_CTE_AUTORIZADOS.
                   
                   Regras de mapeamento (por prioridade):
                     CODTIPOPER_NFE IN (214, 1125, 1211)                          -> TOP 225
                     CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202)       -> TOP 226
                     CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228,
                                        266, 233, 1119, 1108)                     -> TOP 242
                     CODTIPOPER_NFE IN (201, 221, 209)                            -> TOP 234

  Tabelas        : TGFIXN      -- portal de importacao de XML (CT-e e NF-e)
  Tabela de Log  : AD_LOG_ERROS -- somente erros registrados por CT-e:
                                   CTE_ERR  = erro no processamento do CT-e
                                   LOOP_ERR = erro fatal no loop principal
  Dependencias   : VW_CTE_AUTORIZADOS -- lista CT-es autorizados com CODTIPOPER
                                         das NF-e referenciadas (via TGFCAB.CHAVENFE)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Senior
  Empresa        : Spark Eletronica
  Data de Criacao: Maio/2026
  Ultima Revisao : Set/2026 -- Remocao do log de resultado a cada iteracao
                               (CTE_OK / CTE_SKIP); AD_LOG_ERROS passa a
                               registrar apenas erros (CTE_ERR / LOOP_ERR).
                   Jun/2026 -- Correcao da chave de busca: NUNOTA -> NUARQUIVO.
                               TGFIXN.NUNOTA e nulo em CT-es nao processados
                               (DHPROCAG IS NULL), o que tornava a classificacao
                               inoperante (FN_CLASSIFICA nunca encontrava linhas
                               na view e o UPDATE nao atingia nenhum registro).
                               COMMIT explicito ao final do lote.
                   Jun/2026 -- Filtro STATUS = 0 (Pendente) no loop principal:
                               restringe a classificacao automatica aos CT-es
                               pendentes, preservando CODTIPOPERs ja definidos
                               manualmente em documentos de outros status
                               (ex.: 5 = Confirmado) em producao.

  Observacoes    : A coluna NUNOTA de AD_LOG_ERROS passa a registrar o
                   NUARQUIVO do CT-e (chave natural de TGFIXN), ja que o
                   NUNOTA do documento ainda nao existe nesta fase.

                   Dominio oficial de TGFIXN.STATUS (Portal de Importacao XML):
                     0 = Pendente          3 = Invalido
                     1 = Cancelado         4 = Com divergencia
                     2 = Importado         5 = Confirmado
                   A procedure classifica APENAS CT-es Pendentes (STATUS = 0),
                   alinhada ao filtro da consulta nativa do agendador (ver
                   formulas/regra_processa_xml_cte). Documentos em outros
                   status — em especial 5 (Confirmado) — podem ter CODTIPOPER
                   definido manualmente em producao e nao devem ser alterados
                   pela classificacao automatica.
==============================================================================*/

    -- Variaveis (devem preceder qualquer subprograma)
    V_NEW_TOP   NUMBER;

    -- Registra erros em AD_LOG_ERROS com transacao autonoma.
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

    -- Retorna o CODTIPOPER correto para um CT-e pelo seu NUARQUIVO (chave
    -- natural de TGFIXN; NUNOTA e nulo enquanto o CT-e nao for processado).
    -- Prioridade: 225 > 226 > 242 > 234. Retorna NULL se nenhuma NF-e referenciada existir em TGFCAB.
    FUNCTION FN_CLASSIFICA(P_NUARQUIVO_CTE NUMBER) RETURN NUMBER IS
        V_TOP      NUMBER := NULL;
        V_PRIORITY NUMBER := 999;
    BEGIN
        FOR R IN (
            SELECT CODTIPOPER_NFE
            FROM   VW_CTE_AUTORIZADOS
            WHERE  NRARQUIVO       = P_NUARQUIVO_CTE
              AND  CODTIPOPER_NFE IS NOT NULL
        ) LOOP
            IF R.CODTIPOPER_NFE IN (214, 1125, 1211,241) THEN
                RETURN 225;
            ELSIF R.CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202, 1126) AND V_PRIORITY > 2 THEN
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
    ---------------------------------------------------------------------------
    -- 1. Percorre CT-es nao despachados (DHPROCAG IS NULL)
    ---------------------------------------------------------------------------
    
    FOR CTE_REC IN (
        SELECT NUARQUIVO
        FROM   TGFIXN
        WHERE  TIPO     = 'C'
          AND  DHPROCAG IS NULL
          AND  STATUS   = 0      -- apenas Pendentes: preserva classificacoes
                                 -- manuais de documentos em outros status
    ) LOOP
        BEGIN
            V_NEW_TOP := FN_CLASSIFICA(CTE_REC.NUARQUIVO);

            IF V_NEW_TOP IS NOT NULL THEN
                UPDATE TGFIXN
                   SET CODTIPOPER = V_NEW_TOP
                 WHERE NUARQUIVO  = CTE_REC.NUARQUIVO;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_ERRO(
                    P_OPERACAO      => 'CTE_ERR',
                    P_NUNOTA        => CTE_REC.NUARQUIVO,
                    P_ERR_CODE      => SQLCODE,
                    P_ERR_MSG       => SQLERRM,
                    P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                    P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
                );
        END;
    END LOOP;

    ---------------------------------------------------------------------------
    -- 2. Persiste as classificacoes do lote
    --    Garante a gravacao independente do comportamento transacional do
    --    executor de acoes agendadas do Sankhya.
    ---------------------------------------------------------------------------
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        LOG_ERRO(
            P_OPERACAO      => 'LOOP_ERR',
            P_NUNOTA        => NULL,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20001, 'Erro em STP_CLASSIFICACTE_SPARK: ' || SQLERRM);
END;
