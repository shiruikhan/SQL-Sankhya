/*==============================================================================
  Nome do Script : AD_SPKCAE_BACKFILL_VLRCONSERTO
  Tipo           : Script de Atualização (execução única/manual)
  Descrição      : Backfill de VLRCONSERTO nos lançamentos de AD_SPKCAE já
                   concluídos (STATUS = 'C') no ano corrente, cujo campo ainda
                   está 0/nulo — reaplica a mesma regra de negócio da trigger
                   TRG_SPKCAE_VLRCONSERTO_SPARK (busca o NUTAB da tabela padrão
                   de preços de serviços em VGFTAB.CODTAB = 14 e o preço em
                   TGFEXC.VLRVENDA pelo T_CODPROD do lançamento).
                   Necessário porque a trigger só passou a existir a partir de
                   14/09/2026 e não reprocessa lançamentos já gravados.
  Tabelas        : AD_SPKCAE       -- atualizado (VLRCONSERTO)
                   VGFTAB, TGFEXC  -- leitura (localização do preço)
  Filtro         : STATUS = 'C'
                   VLRCONSERTO nulo ou 0
                   T_CODPROD preenchido
                   EXTRACT(YEAR FROM DTCONCLUSAO) = ano atual
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : TRG_SPKCAE_VLRCONSERTO_SPARK -- mesma regra de negócio

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Setembro/2026 — Criação

  Observações    : - Execução única/manual; não é objeto de banco (sem
                     CREATE OR REPLACE) — rode direto num client SQL.
                   - Lançamentos sem DTCONCLUSAO preenchida são ignorados (não
                     têm como ser classificados por "ano atual").
                   - Lançamentos sem preço localizado em TGFEXC permanecem
                     inalterados e são apenas contabilizados no resumo final.
                   - Faz COMMIT ao final do processamento; se ocorrer erro
                     inesperado, faz ROLLBACK, registra em AD_LOG_ERROS e
                     relança a exceção.
                   - Revise o resumo impresso via DBMS_OUTPUT antes de
                     considerar a execução concluída.
==============================================================================*/
SET SERVEROUTPUT ON;

DECLARE
    V_NUTAB           VGFTAB.NUTAB%TYPE;
    V_VLRVENDA        TGFEXC.VLRVENDA%TYPE;
    V_QTD_ATUALIZADOS PLS_INTEGER := 0;
    V_QTD_SEM_PRECO   PLS_INTEGER := 0;

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
            V_IDLOG, 'AD_SPKCAE_BACKFILL_VLRCONSERTO', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    ---------------------------------------------------------------------------
    -- 1. Localiza o NUTAB da tabela padrão de preços de serviços (CODTAB = 14)
    ---------------------------------------------------------------------------
    BEGIN
        SELECT TAB.NUTAB
          INTO V_NUTAB
          FROM VGFTAB TAB
         WHERE TAB.CODTAB = 14;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_NUTAB := NULL;
    END;

    IF V_NUTAB IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Tabela de preços CODTAB = 14 não encontrada em VGFTAB. Nada foi atualizado.');
    ELSE

        ---------------------------------------------------------------------------
        -- 2. Percorre os lançamentos concluídos do ano atual sem VLRCONSERTO
        ---------------------------------------------------------------------------
        FOR R_CAE IN (
            SELECT  CAE.NUMOS
                   ,CAE.T_CODPROD
              FROM AD_SPKCAE CAE
             WHERE CAE.STATUS = 'C'
               AND NVL(CAE.VLRCONSERTO, 0) = 0
               AND CAE.T_CODPROD IS NOT NULL
               AND CAE.DTCONCLUSAO IS NOT NULL
               AND EXTRACT(YEAR FROM CAE.DTCONCLUSAO) = EXTRACT(YEAR FROM SYSDATE)
        ) LOOP

            BEGIN
                SELECT EXC.VLRVENDA
                  INTO V_VLRVENDA
                  FROM TGFEXC EXC
                 WHERE EXC.NUTAB = V_NUTAB
                   AND EXC.CODPROD = R_CAE.T_CODPROD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_VLRVENDA := NULL;
            END;

            IF V_VLRVENDA IS NOT NULL THEN
                UPDATE AD_SPKCAE
                   SET VLRCONSERTO = V_VLRVENDA
                 WHERE NUMOS = R_CAE.NUMOS;

                V_QTD_ATUALIZADOS := V_QTD_ATUALIZADOS + 1;
            ELSE
                V_QTD_SEM_PRECO := V_QTD_SEM_PRECO + 1;
            END IF;

        END LOOP;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Lançamentos atualizados: ' || V_QTD_ATUALIZADOS);
        DBMS_OUTPUT.PUT_LINE('Lançamentos sem preço encontrado em TGFEXC: ' || V_QTD_SEM_PRECO);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO(
            'BACKFILL_VLRCONSERTO', NULL,
            SQLCODE, SQLERRM,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            DBMS_UTILITY.FORMAT_CALL_STACK
        );
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erro no backfill de VLRCONSERTO em AD_SPKCAE: ' || SQLERRM);
END;
/
