/*==============================================================================
  Nome do Script : TIM_PARAM_BOL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Parametro logico de TSIPAR por chave (case-insensitive); 'N'
                  se nao existir. Usada pelo modulo imobiliario.
  Assinatura     : TIM_PARAM_BOL (P_CHAVE VARCHAR2) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_PARAM_BOL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_PARAM_BOL (P_CHAVE VARCHAR2)
RETURN CHAR
IS
    RESULT CHAR(1) := 'N';
BEGIN
    BEGIN
        SELECT LOGICO INTO RESULT
        FROM TSIPAR
        WHERE UPPER(CHAVE) = UPPER(P_CHAVE);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
           RESULT := 'N'; 
    END;
    RETURN RESULT;
END;
