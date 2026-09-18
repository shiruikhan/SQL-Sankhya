/*==============================================================================
  Nome do Script : SNK_INSTR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Wrapper para a funcao nativa INSTR (posicao de substring).
  Assinatura     : SNK_INSTR (P_STR IN VARCHAR2, P_SUBSTR IN VARCHAR2, P_START INT, P_OCURRENCE INT)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_INSTR', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_INSTR (P_STR IN VARCHAR2, P_SUBSTR IN VARCHAR2, P_START INT, P_OCURRENCE INT)
RETURN FLOAT
IS
BEGIN
  RETURN INSTR(P_STR, P_SUBSTR, P_START, P_OCURRENCE);
END;
