/*==============================================================================
  Nome do Script : SNK_MOD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Wrapper para a funcao nativa MOD.
  Assinatura     : SNK_MOD (VLR_DIVIDENDO NUMBER, VLR_DIVISOR NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_MOD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_MOD (VLR_DIVIDENDO NUMBER, VLR_DIVISOR NUMBER)
RETURN NUMBER
IS
  RESULT  NUMBER;
BEGIN
  RESULT := MOD(VLR_DIVIDENDO, VLR_DIVISOR);
  RETURN RESULT;
END;

 
 
