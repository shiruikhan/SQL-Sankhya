create or replace PROCEDURE STP_NFREFDEV_SPARK (
    P_CODUSU    NUMBER,       
    P_IDSESSAO  VARCHAR2,  
    P_QTDLINHAS NUMBER,    
    P_MENSAGEM  OUT VARCHAR2 
) AS
    FIELD_NUNOTA     NUMBER;
    V_CODTIPOPER     NUMBER;
    V_NUNOTA_ORIG    NUMBER;
    V_SEQUENCIA_ORIG NUMBER;
    V_VLRUNIT_ORIG   FLOAT;
    V_COUNT_SUCC     NUMBER := 0;
    V_COUNT_FAIL     NUMBER := 0;
 
    /*******************************************************************
    Autor: Lucas Gabriel 
    Data: 18/03/2025
    Objetivo: Buscar as últimas notas para referência do produto na nota 
    de devolução.
    Alteração: Refatoração para validar CODEMP, atualizar VLRUNIT e 
    melhorar tratamento de erros.
    *******************************************************************/
 
BEGIN
    FOR I IN 1..P_QTDLINHAS 
    LOOP                   
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        
        BEGIN
            SELECT CODTIPOPER 
            INTO V_CODTIPOPER 
            FROM TGFCAB 
            WHERE NUNOTA = FIELD_NUNOTA;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                V_CODTIPOPER := 0;
        END;
 
        IF V_CODTIPOPER <> 305 THEN 
            P_MENSAGEM := 'Erro: A nota ' || FIELD_NUNOTA || ' não é TOP 305. Operação cancelada.';
            RETURN;
        END IF;
 
        FOR R_ITEM IN (
            SELECT 
                CAB.NUNOTA,
                ITE.SEQUENCIA,
                ITE.CODPROD,
                CAB.CODPARC,
                CAB.CODEMP,
                CAB.DTENTSAI,
                ITE.QTDNEG
            FROM TGFCAB CAB
            INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
            WHERE CAB.NUNOTA = FIELD_NUNOTA
              AND NOT EXISTS (
                SELECT 1 
                FROM TGFVAR VAR 
                WHERE VAR.NUNOTA = CAB.NUNOTA
                  AND VAR.SEQUENCIA = ITE.SEQUENCIA
              )
        ) 
        LOOP 
            BEGIN
                -- Busca a nota de origem (Compra mais recente)
                SELECT NUNOTA, SEQUENCIA, VLRUNIT
                INTO V_NUNOTA_ORIG, V_SEQUENCIA_ORIG, V_VLRUNIT_ORIG
                FROM (
                    SELECT 
                        C.NUNOTA, 
                        I.SEQUENCIA,
                        I.VLRUNIT
                    FROM TGFCAB C 
                    INNER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA
                    WHERE C.CODPARC = R_ITEM.CODPARC 
                      AND I.CODPROD = R_ITEM.CODPROD 
                      AND C.CODEMP  = R_ITEM.CODEMP -- Validação de Empresa
                      AND C.TIPMOV  = 'C'
                      AND C.DTENTSAI < R_ITEM.DTENTSAI
                    ORDER BY C.DTENTSAI DESC, C.NUNOTA DESC
                ) WHERE ROWNUM = 1;

                -- Insere o vínculo na TGFVAR
                INSERT INTO TGFVAR (
                    NUNOTA, 
                    SEQUENCIA, 
                    NUNOTAORIG, 
                    SEQUENCIAORIG
                ) VALUES (
                    R_ITEM.NUNOTA, 
                    R_ITEM.SEQUENCIA, 
                    V_NUNOTA_ORIG, 
                    V_SEQUENCIA_ORIG
                );

                -- Atualiza o valor unitário e total na TGFITE
                UPDATE TGFITE 
                SET VLRUNIT = V_VLRUNIT_ORIG,
                    VLRTOT  = V_VLRUNIT_ORIG * R_ITEM.QTDNEG
                WHERE NUNOTA = R_ITEM.NUNOTA 
                  AND SEQUENCIA = R_ITEM.SEQUENCIA;

                V_COUNT_SUCC := V_COUNT_SUCC + 1;

            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    -- Não encontrou nota de origem
                    V_COUNT_FAIL := V_COUNT_FAIL + 1;
                WHEN OTHERS THEN
                    -- Outro erro inesperado
                    P_MENSAGEM := 'Erro ao processar item ' || R_ITEM.CODPROD || ': ' || SQLERRM;
                    RETURN;
            END;
        END LOOP;
    END LOOP;
 
    -- Mensagem final com resumo
    IF V_COUNT_SUCC > 0 THEN
        P_MENSAGEM := V_COUNT_SUCC || ' itens vinculados e atualizados com sucesso.';
    ELSE
        P_MENSAGEM := 'Nenhum item foi vinculado.';
    END IF;

    IF V_COUNT_FAIL > 0 THEN
        P_MENSAGEM := P_MENSAGEM || ' (' || V_COUNT_FAIL || ' itens sem origem encontrada).';
    END IF;

END;
