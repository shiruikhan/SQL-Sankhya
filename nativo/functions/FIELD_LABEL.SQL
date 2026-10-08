/*==============================================================================
  Nome do Script : FIELD_LABEL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o rotulo (DESCRCAMPO) de um campo no dicionario de
                  dados (TDDCAM).
  Assinatura     : FIELD_LABEL (P_NOMETAB VARCHAR,P_NOMECAMPO VARCHAR) RETURN
                  VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FIELD_LABEL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FIELD_LABEL (P_NOMETAB VARCHAR,P_NOMECAMPO VARCHAR)
RETURN VARCHAR
IS
    LABEL VARCHAR(50) := NULL;
BEGIN
    SELECT DESCRCAMPO INTO LABEL
    FROM TDDCAM
    WHERE NOMETAB = P_NOMETAB
        AND NOMECAMPO = P_NOMECAMPO;
    RETURN LABEL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
END;
