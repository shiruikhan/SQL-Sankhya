/*==============================================================================
  Nome do Script : OPTION_LABEL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a descricao da opcao de um campo de lista (TDDOPC)
                  para um valor.
  Assinatura     : OPTION_LABEL (P_NOMETAB VARCHAR2, P_NOMECAMPO VARCHAR2,
                  P_VALOR VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OPTION_LABEL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION OPTION_LABEL (P_NOMETAB VARCHAR2, P_NOMECAMPO VARCHAR2, P_VALOR VARCHAR2)
RETURN VARCHAR2
IS
    V_NUCAMPO NUMBER;
    V_OPCAO VARCHAR2(100);
BEGIN
    IF P_VALOR IS NULL THEN
        RETURN NULL;
    END IF;
    BEGIN
        SELECT NUCAMPO INTO V_NUCAMPO
        FROM TDDCAM 
        WHERE NOMETAB = P_NOMETAB 
            AND NOMECAMPO = P_NOMECAMPO;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    BEGIN
        SELECT OPCAO INTO V_OPCAO
        FROM TDDOPC
        WHERE VALOR = P_VALOR AND NUCAMPO = V_NUCAMPO;
        RETURN V_OPCAO;
   EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
   END;
END;
