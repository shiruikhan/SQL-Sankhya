/*==============================================================================
  Nome do Script : TIM_FORMATATELEFONE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata um telefone brasileiro (com/sem DDD, DDI e zero) em
                  mascara padrao.
  Assinatura     : TIM_FORMATATELEFONE (P_TELEFONE VARCHAR) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_FORMATATELEFONE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_FORMATATELEFONE (P_TELEFONE VARCHAR)
RETURN VARCHAR
IS
    P_TELF VARCHAR(100);
BEGIN

    -- 97823734         8
    -- 997823734        9
    -- 3497823734       10
    -- 34997823734      11
    -- 553497823734     12
    -- 5534997823734    13

    -- 03497823734       11
    -- 034997823734      12
    -- 5503497823734     13
    -- 55034997823734    14
    
    P_TELF := REGEXP_REPLACE(P_TELEFONE, '\D+','', 1,0);

    IF LENGTH(P_TELF) >= 8 AND LENGTH(P_TELF) <= 14 THEN
    
        IF LENGTH(P_TELF) = 14 THEN
            P_TELF := '+'||SUBSTR(P_TELF,1,2)||' ('||SUBSTR(P_TELF,3,3)||') '||SUBSTR(P_TELF,6,1)||' '||SUBSTR(P_TELF,7,4)||'-'||SUBSTR(P_TELF,11,4);
        ELSIF LENGTH(P_TELF) = 13 AND SUBSTR(P_TELF,3,1) = '0' THEN
            P_TELF := '+'||SUBSTR(P_TELF,1,2)||' ('||SUBSTR(P_TELF,3,3)||') '||' '||SUBSTR(P_TELF,6,4)||'-'||SUBSTR(P_TELF,10,4);
        ELSIF LENGTH(P_TELF) = 13 THEN
            P_TELF := '+'||SUBSTR(P_TELF,1,2)||' ('||SUBSTR(P_TELF,3,2)||') '||SUBSTR(P_TELF,5,1)||' '||SUBSTR(P_TELF,6,4)||'-'||SUBSTR(P_TELF,10,4);
        ELSIF LENGTH(P_TELF) = 12 AND P_TELF LIKE '0%' THEN
            P_TELF := '('||SUBSTR(P_TELF,1,3)||') '||SUBSTR(P_TELF,4,1)||' '||SUBSTR(P_TELF,5,4)||'-'||SUBSTR(P_TELF,9,4);
        ELSIF LENGTH(P_TELF) = 12 THEN
            P_TELF := '+'||SUBSTR(P_TELF,1,2)||' ('||SUBSTR(P_TELF,3,2)||') '||SUBSTR(P_TELF,5,4)||'-'||SUBSTR(P_TELF,9,4);
        ELSIF LENGTH(P_TELF) = 11 AND P_TELF LIKE '0%' THEN
            P_TELF := '('||SUBSTR(P_TELF,1,3)||') '||SUBSTR(P_TELF,4,4)||'-'||SUBSTR(P_TELF,8,4);
        ELSIF LENGTH(P_TELF) = 11 THEN
            P_TELF := '('||SUBSTR(P_TELF,1,2)||') '||SUBSTR(P_TELF,3,1)||' '||SUBSTR(P_TELF,4,4)||'-'||SUBSTR(P_TELF,8,4);
        ELSIF LENGTH(P_TELF) = 10 THEN
            P_TELF := '('||SUBSTR(P_TELF,1,2)||') '||' '||SUBSTR(P_TELF,3,4)||'-'||SUBSTR(P_TELF,7,4);
        ELSIF LENGTH(P_TELF) = 9 THEN
            P_TELF := SUBSTR(P_TELF,1,1)||' '||SUBSTR(P_TELF,2,4)||'-'||SUBSTR(P_TELF,6,4);
        ELSIF LENGTH(P_TELF) = 8 THEN
            P_TELF := SUBSTR(P_TELF,1,4)||'-'||SUBSTR(P_TELF,5,4);
        END IF;
    ELSE
        P_TELF := P_TELEFONE;
    END IF;
    
    RETURN P_TELF;
END;
