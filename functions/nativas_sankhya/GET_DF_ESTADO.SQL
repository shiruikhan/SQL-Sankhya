/*==============================================================================
  Nome do Script : GET_DF_ESTADO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Classifica o CFOP por origem (1 = estadual, 2 =
                  interestadual, 3 = exterior).
  Assinatura     : GET_DF_ESTADO (P_CODCFO NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_DF_ESTADO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_DF_ESTADO (P_CODCFO NUMBER)
RETURN NUMBER
IS
  RESULT NUMBER(5);
  VALOR  NUMBER(5);
BEGIN
  VALOR := TRUNC(P_CODCFO/1000, 0);
  RESULT := CASE WHEN VALOR IN (1, 5) THEN 1
                 WHEN VALOR IN (2, 6) THEN 2
                 WHEN VALOR IN (3, 7) THEN 3
                 ELSE 0 END;
  RETURN RESULT;
END;
