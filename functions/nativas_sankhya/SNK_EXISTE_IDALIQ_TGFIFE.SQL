/*==============================================================================
  Nome do Script : SNK_EXISTE_IDALIQ_TGFIFE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se um IDALIQ existe em TGFIFE.
  Assinatura     : SNK_EXISTE_IDALIQ_TGFIFE (P_IDALIQ NUMBER)
                   RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_EXISTE_IDALIQ_TGFIFE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_EXISTE_IDALIQ_TGFIFE (P_IDALIQ NUMBER)
RETURN BOOLEAN
IS 
  P_COUNT NUMBER(10);
  PRAGMA AUTONOMOUS_TRANSACTION;
  P_RETURN BOOLEAN := FALSE;
BEGIN
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFIFE
  WHERE IDALIQ = P_IDALIQ;
  
  IF P_COUNT > 0 THEN
    P_RETURN := TRUE;
  END IF;
  COMMIT;
  RETURN P_RETURN;
END;
