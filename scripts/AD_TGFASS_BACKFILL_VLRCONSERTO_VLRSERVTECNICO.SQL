/*==============================================================================
  Nome do Script : AD_TGFASS_BACKFILL_VLRCONSERTO_VLRSERVTECNICO
  Tipo           : Script de Atualização (execução única/manual)
  Descrição      : Backfill de VLRCONSERTO e VLRSERVTECNICO nas O.S. de
                   assistência técnica (AD_TGFASS) do ano corrente cujos campos
                   ainda estão 0/nulo — reaplica a mesma regra de negócio da
                   trigger TRG_TGFASS_VLRCONSERTO_SPARK (preço do produto
                   obtido via a function nativa SNK_PRECO, CODTAB 14 para
                   VLRCONSERTO e CODTAB 15 para VLRSERVTECNICO, usando o
                   T_CODPROD da O.S.). Necessário porque a trigger só passou a
                   existir/gerar VLRSERVTECNICO a partir de 17/09/2026 e não
                   reprocessa O.S. já gravadas.
  Tabelas        : AD_TGFASS -- atualizado (VLRCONSERTO, VLRSERVTECNICO)
  Filtro         : EXTRACT(YEAR FROM DTRECEB) = ano atual
                   T_CODPROD preenchido
                   VLRCONSERTO e/ou VLRSERVTECNICO nulo ou 0 (avaliados de
                   forma independente, sem restrição de STATUS — mesma regra
                   da trigger)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : TRG_TGFASS_VLRCONSERTO_SPARK -- mesma regra de negócio
                   SNK_PRECO (function nativa Sankhya) -- resolve o preço
                   vigente do produto na tabela informada (CODTAB, CODPROD)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 22/09/2026

  Observações    : - Execução única/manual; não é objeto de banco (sem
                     CREATE OR REPLACE) — rode direto num client SQL.
                   - "Ano corrente" é definido pela data de recebimento
                     (DTRECEB), não pela conclusão — cobre O.S. abertas neste
                     ano independente do status atual (aberta, em andamento,
                     concluída etc.), igual à trigger, que não restringe por
                     STATUS.
                   - O.S. sem DTRECEB preenchida são ignoradas (não têm como
                     ser classificadas por "ano atual").
                   - VLRCONSERTO e VLRSERVTECNICO são avaliados e atualizados
                     de forma independente por O.S., espelhando a trigger.
                   - SNK_PRECO resolve sempre o preço vigente em SYSDATE (não
                     há preço histórico); o valor preenchido reflete a tabela
                     de preços atual, não a vigente na data de recebimento.
                   - O.S. sem preço encontrado (SNK_PRECO retornando 0) para
                     algum dos campos permanecem inalteradas nesse campo e são
                     apenas contabilizadas no resumo final.
                   - Faz COMMIT ao final do processamento; se ocorrer erro
                     inesperado, faz ROLLBACK, registra em AD_LOG_ERROS e
                     relança a exceção.
                   - Revise o resumo impresso via DBMS_OUTPUT antes de
                     considerar a execução concluída.
==============================================================================*/
SET SERVEROUTPUT ON;

DECLARE
    V_PRECO                       AD_TGFASS.VLRCONSERTO%TYPE;
    V_QTD_VLRCONSERTO_ATUALIZADO  PLS_INTEGER := 0;
    V_QTD_VLRCONSERTO_SEM_PRECO   PLS_INTEGER := 0;
    V_QTD_VLRSERVTEC_ATUALIZADO   PLS_INTEGER := 0;
    V_QTD_VLRSERVTEC_SEM_PRECO    PLS_INTEGER := 0;

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
            V_IDLOG, 'AD_TGFASS_BACKFILL_VLRCONSERTO_VLRSERVTECNICO', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    ---------------------------------------------------------------------------
    -- 1. Percorre as O.S. do ano atual (por DTRECEB) com T_CODPROD preenchido
    ---------------------------------------------------------------------------
    FOR R_ASS IN (
        SELECT  ASS.NUMOS
               ,ASS.T_CODPROD
               ,ASS.VLRCONSERTO
               ,ASS.VLRSERVTECNICO
          FROM AD_TGFASS ASS
         WHERE ASS.T_CODPROD IS NOT NULL
           AND ASS.DTRECEB IS NOT NULL
           AND EXTRACT(YEAR FROM ASS.DTRECEB) = EXTRACT(YEAR FROM SYSDATE)
           AND (NVL(ASS.VLRCONSERTO, 0) = 0 OR NVL(ASS.VLRSERVTECNICO, 0) = 0)
    ) LOOP

        ---------------------------------------------------------------------
        -- 1.1. VLRCONSERTO (CODTAB = 14)
        ---------------------------------------------------------------------
        IF NVL(R_ASS.VLRCONSERTO, 0) = 0 THEN
            V_PRECO := SNK_PRECO(14, R_ASS.T_CODPROD);

            IF NVL(V_PRECO, 0) > 0 THEN
                UPDATE AD_TGFASS
                   SET VLRCONSERTO = V_PRECO
                 WHERE NUMOS = R_ASS.NUMOS;

                V_QTD_VLRCONSERTO_ATUALIZADO := V_QTD_VLRCONSERTO_ATUALIZADO + 1;
            ELSE
                V_QTD_VLRCONSERTO_SEM_PRECO := V_QTD_VLRCONSERTO_SEM_PRECO + 1;
            END IF;
        END IF;

        ---------------------------------------------------------------------
        -- 1.2. VLRSERVTECNICO (CODTAB = 15)
        ---------------------------------------------------------------------
        IF NVL(R_ASS.VLRSERVTECNICO, 0) = 0 THEN
            V_PRECO := SNK_PRECO(15, R_ASS.T_CODPROD);

            IF NVL(V_PRECO, 0) > 0 THEN
                UPDATE AD_TGFASS
                   SET VLRSERVTECNICO = V_PRECO
                 WHERE NUMOS = R_ASS.NUMOS;

                V_QTD_VLRSERVTEC_ATUALIZADO := V_QTD_VLRSERVTEC_ATUALIZADO + 1;
            ELSE
                V_QTD_VLRSERVTEC_SEM_PRECO := V_QTD_VLRSERVTEC_SEM_PRECO + 1;
            END IF;
        END IF;

    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('VLRCONSERTO atualizado em: ' || V_QTD_VLRCONSERTO_ATUALIZADO || ' O.S.');
    DBMS_OUTPUT.PUT_LINE('VLRCONSERTO sem preço encontrado via SNK_PRECO: ' || V_QTD_VLRCONSERTO_SEM_PRECO || ' O.S.');
    DBMS_OUTPUT.PUT_LINE('VLRSERVTECNICO atualizado em: ' || V_QTD_VLRSERVTEC_ATUALIZADO || ' O.S.');
    DBMS_OUTPUT.PUT_LINE('VLRSERVTECNICO sem preço encontrado via SNK_PRECO: ' || V_QTD_VLRSERVTEC_SEM_PRECO || ' O.S.');

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO(
            'BACKFILL_VLRCONSERTO_VLRSERVTECNICO', NULL,
            SQLCODE, SQLERRM,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            DBMS_UTILITY.FORMAT_CALL_STACK
        );
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erro no backfill de VLRCONSERTO/VLRSERVTECNICO em AD_TGFASS: ' || SQLERRM);
END;
/
