CREATE OR REPLACE TRIGGER TRG_INC_UPD_CMF_SPARK
BEFORE INSERT OR UPDATE OF NOMECID ON TSICID
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_CMF_SPARK
  Tipo           : Trigger
  Descrição      : Preenche automaticamente o campo CODMUNFIS da tabela TSICID
                   ao inserir ou alterar o nome da cidade (NOMECID). Busca o ID
                   correspondente em AD_TGSMDF comparando o município de forma
                   case-insensitive e accent-insensitive (remoção de caracteres
                   não alfanuméricos + NLSSORT BINARY_AI). Erros não bloqueiam
                   a operação; são registrados em AD_LOG_ERROS.
  Tabela         : TSICID
  Evento         : BEFORE INSERT OR UPDATE OF NOMECID
  Tabelas        : TSICID (alvo), AD_TGSMDF (leitura), AD_LOG_ERROS (log)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : AD_TGSMDF

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Jun/2026
  Última Revisão : Jun/2026 — Adiciona LOG_ERRO autônoma; trata NO_DATA_FOUND
                              e TOO_MANY_ROWS sem bloquear a operação
==============================================================================*/
DECLARE
    V_SORT_RAW   RAW(2000);
    V_ID_MATCH   AD_TGSMDF.ID%TYPE;

    ---------------------------------------------------------------------------
    -- Registra erros em AD_LOG_ERROS com transacao autonoma, garantindo que
    -- o log persista mesmo que a transacao principal sofra ROLLBACK
    ---------------------------------------------------------------------------
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_ERR_CODE      NUMBER,
        P_ERR_MSG       VARCHAR2,
        P_ERR_BACKTRACE VARCHAR2,
        P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1
          INTO V_IDLOG
          FROM AD_LOG_ERROS;

        INSERT INTO AD_LOG_ERROS (
             IDLOG
            ,DHLOG
            ,TRIGGER_NAME
            ,OPERACAO
            ,ERROR_CODE
            ,ERROR_MESSAGE
            ,ERROR_BACKTRACE
            ,CALL_STACK
        ) VALUES (
             V_IDLOG
            ,SYSDATE
            ,'TRG_INC_UPD_CMF_SPARK'
            ,P_OPERACAO
            ,P_ERR_CODE
            ,P_ERR_MSG
            ,P_ERR_BACKTRACE
            ,P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    -- Executa somente em INSERT ou quando o campo NOMECID for alterado
    IF INSERTING OR (UPDATING('NOMECID') AND NVL(:NEW.NOMECID, '§') <> NVL(:OLD.NOMECID, '§')) THEN

        IF :NEW.NOMECID IS NOT NULL THEN

            -- Normaliza o NOMECID removendo caracteres nao alfanumericos e aplicando comparacao accent-insensitive
            V_SORT_RAW := NLSSORT(REGEXP_REPLACE(:NEW.NOMECID, '[^[:alnum:]]', ''), 'NLS_SORT=BINARY_AI');

            -- Busca o ID em AD_TGSMDF cujo MUNICIPIO normalizado corresponde ao NOMECID normalizado
            BEGIN
                SELECT ID
                  INTO V_ID_MATCH
                  FROM AD_TGSMDF
                 WHERE NLSSORT(REGEXP_REPLACE(MUNICIPIO, '[^[:alnum:]]', ''), 'NLS_SORT=BINARY_AI') = V_SORT_RAW
                   AND UF = :NEW.UF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ID_MATCH := NULL;
                WHEN TOO_MANY_ROWS THEN
                    V_ID_MATCH := NULL;
                    LOG_ERRO(
                        P_OPERACAO      => CASE WHEN INSERTING THEN 'INSERT' ELSE 'UPDATE' END,
                        P_ERR_CODE      => -1,
                        P_ERR_MSG       => 'TOO_MANY_ROWS ao buscar municipio "' || :NEW.NOMECID || '" UF=' || :NEW.UF || ' em AD_TGSMDF',
                        P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                        P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
                    );
            END;

            -- Se encontrou correspondencia, atualiza o CODMUNFIS do registro atual
            IF V_ID_MATCH IS NOT NULL THEN
                :NEW.CODMUNFIS := V_ID_MATCH;
            END IF;

        END IF;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Erros inesperados nao bloqueiam a gravacao do cadastro de cidade
        LOG_ERRO(
            P_OPERACAO      => CASE WHEN INSERTING THEN 'INSERT' ELSE 'UPDATE' END,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
END TRG_INC_UPD_CMF_SPARK;
/
