/*==============================================================================
  Nome do Script : SNK_REMOVE_CARACTER_ESPECIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Remove caracteres nao imprimiveis (fora das faixas ASCII 32-126 e Latin-1
                  160-255) de uma string.
  Assinatura     : SNK_REMOVE_CARACTER_ESPECIAL (P_INPUT IN VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_REMOVE_CARACTER_ESPECIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_REMOVE_CARACTER_ESPECIAL (P_INPUT IN VARCHAR2)
RETURN VARCHAR2
IS
    V_OUTPUT VARCHAR2(4000) := '';
    V_CHAR   CHAR(1);
    V_ASCII  INTEGER;
BEGIN
    IF P_INPUT IS NULL THEN
        RETURN NULL;
    END IF;

    FOR I IN 1 .. LENGTH(P_INPUT) LOOP
        V_CHAR := SUBSTR(P_INPUT, I, 1);
        V_ASCII := ASCII(V_CHAR);

        IF (V_ASCII BETWEEN 32 AND 126) OR (V_ASCII BETWEEN 160 AND 255) THEN
            V_OUTPUT := V_OUTPUT || V_CHAR;
        END IF;
    END LOOP;

    RETURN V_OUTPUT;
END;
