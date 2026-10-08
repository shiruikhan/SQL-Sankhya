/*==============================================================================
  Nome do Script : GET_DIA_PROXMES
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o dia N do mes seguinte a uma data (ultimo dia do
                  mes + N).
  Assinatura     : GET_DIA_PROXMES (P_DAY NUMBER, P_DATE DATE) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_DIA_PROXMES', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_DIA_PROXMES (P_DAY NUMBER, P_DATE  DATE)
RETURN DATE
IS 
  RESULT DATE;
BEGIN
  SELECT LAST_DAY(P_DATE) + P_DAY INTO RESULT
  FROM DUAL;
  RETURN RESULT; 
END;
