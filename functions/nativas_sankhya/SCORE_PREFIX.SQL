/*==============================================================================
  Nome do Script : SCORE_PREFIX
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna 1 se o valor comeca com o prefixo informado
                  (ignorando . e -), usado como pontuacao em buscas (ex.:
                  NCM).
  Assinatura     : SCORE_PREFIX (p_value VARCHAR2, p_column VARCHAR2) RETURN
                  NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SCORE_PREFIX', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION SCORE_PREFIX (p_value VARCHAR2, p_column VARCHAR2)
RETURN NUMBER IS
    v_clean VARCHAR2(10);
BEGIN
    IF p_column IS NULL OR p_column = '0' THEN
        RETURN 0;
    END IF;

    v_clean := REPLACE(REPLACE(p_column, '.', ''), '-', '');

    IF SUBSTR(p_value, 1, LENGTH(v_clean)) = v_clean THEN
            RETURN 1;
    END IF;
    RETURN 0;
END;
