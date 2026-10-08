/*==============================================================================
  Nome do Script : FRMT_NOMEBCO_POLIPRINT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta a identificacao banco/agencia/conta do cedente para o
                  boleto Poliprint.
  Assinatura     : FRMT_NOMEBCO_POLIPRINT (P_NUFIN NUMBER, P_CODCTABCOINT
                  NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FRMT_NOMEBCO_POLIPRINT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FRMT_NOMEBCO_POLIPRINT (P_NUFIN NUMBER, P_CODCTABCOINT NUMBER) 
RETURN VARCHAR2
IS
    V_CODCTABCO VARCHAR2(20);
    V_BCODIGIT VARCHAR2(20);
    V_CODAGE VARCHAR2(20);
    V_AGEDIGIT VARCHAR2(20);
    V_NOMEBCO VARCHAR2(20);
BEGIN
    IF P_CODCTABCOINT IS NULL THEN
        RAISE_APPLICATION_ERROR(-20201, 'Conta bancária e/ou Agencia não informadas no cadastro da conta Nº('||P_CODCTABCOINT||') do financeiro Nº('||P_NUFIN||').');
    END IF;
    SELECT CODAGE, CODCTABCO INTO V_CODAGE, V_CODCTABCO
    FROM TSICTA
    WHERE CODCTABCOINT = P_CODCTABCOINT;
    IF V_CODAGE IS NULL OR V_CODCTABCO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20201, 'Conta bancária e/ou Agencia não informadas no cadastro da conta Nº('||P_CODCTABCOINT||').');
    END IF;
    IF LENGTH(V_CODAGE) > 1 THEN
        V_AGEDIGIT := SUBSTR(V_CODAGE, LENGTH(V_CODAGE), 1);
        V_CODAGE := SUBSTR(V_CODAGE, 0, LENGTH(V_CODAGE) - 1)||'-'||V_AGEDIGIT;
    ELSE
        V_CODAGE := V_CODAGE||'-?';
    END IF;
    IF LENGTH(V_CODCTABCO) > 1 THEN
        V_BCODIGIT := SUBSTR(V_CODCTABCO, LENGTH(V_CODCTABCO), 1);
        V_CODCTABCO := SUBSTR(V_CODCTABCO, 0, LENGTH(V_CODCTABCO) - 1)||'-'||V_BCODIGIT;
    ELSE
        V_CODCTABCO := V_CODCTABCO||'-?';
    END IF;
    V_CODCTABCO := REGEXP_REPLACE(TRIM(V_CODCTABCO), '^(0+)', '0');
    IF V_CODCTABCO NOT LIKE '0%' THEN
        V_CODCTABCO := '0'||V_CODCTABCO;
    END IF;
    V_NOMEBCO := V_CODAGE||' / '||V_CODCTABCO;
    V_NOMEBCO := REGEXP_REPLACE(V_NOMEBCO, '-+', '-');
    V_NOMEBCO := TRIM(V_NOMEBCO);
    RETURN V_NOMEBCO;
END;
