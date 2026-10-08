/*==============================================================================
  Nome do Script : TIM_PARAM_TEXT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Parametro texto de TSIPAR por chave (case-insensitive); NULL
                  se nao existir. Usada pelo modulo imobiliario.
  Assinatura     : TIM_PARAM_TEXT (P_CHAVE VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_PARAM_TEXT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_PARAM_TEXT (P_CHAVE VARCHAR2)
RETURN VARCHAR2
IS
    RESULT VARCHAR2(4000) := NULL;
BEGIN
    BEGIN
        SELECT TEXTO INTO RESULT
        FROM TSIPAR
        WHERE UPPER(CHAVE) = UPPER(P_CHAVE);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
           RESULT := NULL; 
    END;
    RETURN RESULT;
END;
