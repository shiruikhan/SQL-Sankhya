/*==============================================================================
  Nome do Script : GET_VALOR_TGFAJA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o valor de ajuste de apuracao de imposto (TGFAJA)
                  para empresa/data/imposto/UF.
  Assinatura     : GET_VALOR_TGFAJA (P_CODEMP IN NUMBER, P_DTREF IN DATE,
                  P_TIPIMPOSTO IN VARCHAR, P_TIPAPURACAO IN NUMBER, P_CODUF IN
                  NUMBER) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_VALOR_TGFAJA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_VALOR_TGFAJA (P_CODEMP IN NUMBER, P_DTREF IN DATE, P_TIPIMPOSTO IN VARCHAR, P_TIPAPURACAO IN NUMBER, P_CODUF IN NUMBER)
RETURN FLOAT
IS
  V_RESULT FLOAT;
BEGIN
  BEGIN
    SELECT ROUND(VLRAJUSTE, 2) INTO V_RESULT
      FROM TGFAJA AJA
    WHERE CODEMP = P_CODEMP
      AND DTREF = P_DTREF
      AND TIPIMPOSTO = P_TIPIMPOSTO
      AND TIPAPURACAO = P_TIPAPURACAO
      AND CODUF = P_CODUF
      AND SEQUENCIA = 1;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    V_RESULT := 0;
  END;
  RETURN V_RESULT;
END;
