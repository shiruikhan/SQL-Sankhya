/*==============================================================================
  Nome do Script : SNK_GET_CODEMP_TGFAJA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o CODEMP de um ajuste de estoque/financeiro (TGFAJA).
  Assinatura     : SNK_GET_CODEMP_TGFAJA (P_NUAJA NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CODEMP_TGFAJA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CODEMP_TGFAJA (P_NUAJA    NUMBER)
RETURN NUMBER
AS
    P_RESULT    NUMBER(10) := 0;
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  BEGIN
    SELECT A.CODEMP INTO P_RESULT
    FROM TGFAJA A
    WHERE A.NUAJA = P_NUAJA;
  EXCEPTION WHEN NO_DATA_FOUND THEN
      P_RESULT := 0;
  END;
  COMMIT;
  RETURN P_RESULT;
END;
