CREATE OR REPLACE PROCEDURE "STP_CORCSTIPI_SPARK" (
    P_CODUSU NUMBER,       
    P_IDSESSAO VARCHAR2,    
    P_QTDLINHAS NUMBER,   
    P_MENSAGEM OUT VARCHAR2 
) AS
    -- Parâmetros do Botão 1
    PARAM_P_CSTIPI VARCHAR2(4000);
    PARAM_P_CODENQENT NUMBER;
    PARAM_P_CODENQSAI NUMBER;
    FIELD_NUNOTA NUMBER;
    FIELD_SEQUENCIA NUMBER;
    V_CODCFO TGFITE.CODCFO%TYPE;

    -- Parâmetros do Botão 2 (Audicon)
    P_CORRENTE VARCHAR(100);
    P_COUNT_CAB INT;
    P_COUNT_FIN INT;

BEGIN
    -- Captura dos parâmetros de tela
    PARAM_P_CSTIPI    := ACT_TXT_PARAM(P_IDSESSAO, 'P_CSTIPI');
    PARAM_P_CODENQENT := ACT_INT_PARAM(P_IDSESSAO, 'P_CODENQENT');
    PARAM_P_CODENQSAI := ACT_INT_PARAM(P_IDSESSAO, 'P_CODENQSAI');

    FOR I IN 1..P_QTDLINHAS 
    LOOP                   
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');       

        -------------------------------------------------------------------------
        -- 1. DESBLOQUEIO CONTÁBIL
        -------------------------------------------------------------------------
        -- Verifica se o nro único está no mês corrente (com carência de 5 dias)
        SELECT CASE WHEN TRUNC(MAX(REFERENCIA),'MM') = TRUNC(SYSDATE,'MM') THEN 'S' 
                    WHEN TRUNC(MAX(REFERENCIA),'MM') <> TRUNC(SYSDATE-5,'MM') THEN  'N' 
                    ELSE 'NSA' END INTO P_CORRENTE 
        FROM TCBINT WHERE NUNICO = FIELD_NUNOTA AND ORIGEM IN ('E');

        -- Qtde de lançamentos CAB vinculados ao Nro Único
        SELECT COUNT(NUNICO) INTO P_COUNT_CAB 
        FROM TCBINT 
        WHERE NUNICO = FIELD_NUNOTA AND ORIGEM IN ('E') AND REFERENCIA = TRUNC(SYSDATE,'MM');

        -- Qtde de lançamentos FIN (baixa/automático) vinculados
        SELECT COUNT(NUNICO) INTO P_COUNT_FIN 
        FROM TCBINT 
        WHERE NUNICO IN (SELECT DISTINCT(NUFIN) FROM TGFFIN WHERE NUNOTA = FIELD_NUNOTA) 
          AND ORIGEM IN ('B','F') AND REFERENCIA = TRUNC(SYSDATE,'MM');

        -- Validação de mês fechado
        IF P_CORRENTE = 'N' THEN
            RAISE_APPLICATION_ERROR(-20001, 'O nro único: '||FIELD_NUNOTA||' possui contabilização em mês fechado. Solicitar à Equipe Contábil Audicon a liberação!');
        
        -- Se estiver no mês corrente e possuir lançamentos, executa a exclusão
        ELSIF P_CORRENTE = 'S' AND P_COUNT_CAB > 0 THEN
            
            -- Exclui LCTOS Origem 'E' na TCBLAN
            DELETE TCBLAN 
            WHERE CODEMP||'-'||REFERENCIA||'-'||NUMLANC||'-'||TIPLANC||'-'||NUMLOTE||'-'||VLRLANC||'-'||SEQUENCIA IN (
                SELECT CODEMP||'-'||REFERENCIA||'-'||NUMLANC||'-'||TIPLANC||'-'||NUMLOTE||'-'||VLRLANC||'-'||SEQUENCIA 
                FROM TCBINT 
                WHERE NUNICO = FIELD_NUNOTA AND ORIGEM IN ('E') AND REFERENCIA = TRUNC(SYSDATE,'MM')
            ) AND REFERENCIA = TRUNC(SYSDATE,'MM');
            
            -- Exclui LCTOS Origem 'E' na TCBINT
            DELETE TCBINT 
            WHERE NUNICO = FIELD_NUNOTA AND ORIGEM IN ('E') AND REFERENCIA = TRUNC(SYSDATE,'MM');
            
            -- Exclui LCTOS de Pagto ou Financeiro Automático se existirem
            IF P_COUNT_FIN > 0 THEN
                DELETE TCBLAN 
                WHERE CODEMP||'-'||REFERENCIA||'-'||NUMLANC||'-'||TIPLANC||'-'||NUMLOTE||'-'||VLRLANC||'-'||SEQUENCIA IN (
                    SELECT CODEMP||'-'||REFERENCIA||'-'||NUMLANC||'-'||TIPLANC||'-'||NUMLOTE||'-'||VLRLANC||'-'||SEQUENCIA 
                    FROM TCBINT 
                    WHERE NUNICO IN (SELECT DISTINCT(NUFIN) FROM TGFFIN WHERE NUNOTA = FIELD_NUNOTA) AND ORIGEM IN ('B','F') AND REFERENCIA = TRUNC(SYSDATE,'MM')
                ) AND REFERENCIA = TRUNC(SYSDATE,'MM');

                DELETE TCBINT 
                WHERE NUNICO IN (SELECT DISTINCT(NUFIN) FROM TGFFIN WHERE NUNOTA = FIELD_NUNOTA) AND ORIGEM IN ('B','F') AND REFERENCIA = TRUNC(SYSDATE,'MM');
            END IF;
        END IF;

        -------------------------------------------------------------------------
        -- 2. ALTERAÇÃO DO CST E IPI
        -------------------------------------------------------------------------
        IF PARAM_P_CSTIPI = 5 AND PARAM_P_CODENQENT IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20101, FC_FORMATAHTML('Não Foi Possível prosseguir com a Alteração!', 'A CST do IPI é suspensão não consta informado o Código Enq. Legal IPI Entrada.', 'Favor preencher o campo Código Enq. Legal IPI Entrada e tente novamente!'));
        END IF;

        IF PARAM_P_CSTIPI = 55 AND PARAM_P_CODENQSAI IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20101, FC_FORMATAHTML('Não Foi Possível prosseguir com a Alteração!', 'A CST do IPI é suspensão não consta informado o Código Enq. Legal IPI Saida.', 'Favor preencher o campo Código Enq. Legal IPI Saida e tente novamente!'));
        END IF;

        SELECT CODCFO INTO V_CODCFO FROM TGFITE WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;

        IF PARAM_P_CSTIPI < 50 AND V_CODCFO > 3999 AND PARAM_P_CSTIPI <> -1 THEN 
            RAISE_APPLICATION_ERROR(-20101, FC_FORMATAHTML('Não Foi Possível prosseguir com a Alteração!', 'A CST do IPI é de entrada e o CFOP refere-se ao de saida', 'Favor preencher o campo de CST do IPI de forma correta!'));
        END IF;

        IF PARAM_P_CSTIPI >= 50 AND V_CODCFO < 3999 AND PARAM_P_CSTIPI <> -1 THEN 
            RAISE_APPLICATION_ERROR(-20101, FC_FORMATAHTML('Não Foi Possível prosseguir com a Alteração!', 'A CST do IPI é de Saída e o CFOP refere-se ao de Entrada', 'Favor preencher o campo de CST do IPI de forma correta!'));
        END IF;

        IF PARAM_P_CODENQENT IS NOT NULL THEN 
            UPDATE TGFITE SET CODENQIPI = PARAM_P_CODENQENT WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;
        END IF;

        IF PARAM_P_CODENQSAI IS NOT NULL THEN 
            UPDATE TGFITE SET CODENQIPI = PARAM_P_CODENQSAI WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;
        END IF;

        -- Atualiza efetivamente a CST do IPI
        UPDATE TGFITE 
        SET CSTIPI = PARAM_P_CSTIPI
        WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;

    END LOOP;

    P_MENSAGEM :='Alteração da CST do IPI e liberação contábil realizadas com sucesso!';
END;