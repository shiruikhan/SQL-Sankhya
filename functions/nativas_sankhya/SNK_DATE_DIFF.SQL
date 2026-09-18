/*==============================================================================
  Nome do Script : SNK_DATE_DIFF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Diferenca em dias entre duas datas.
  Assinatura     : SNK_DATE_DIFF ( DT_BASE DATE, DT_SUBTRAIR DATE)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_DATE_DIFF', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_DATE_DIFF ( DT_BASE DATE, DT_SUBTRAIR DATE)
RETURN NUMBER
IS
  RESULT  NUMBER(10);
BEGIN
  RESULT := DT_BASE - DT_SUBTRAIR;
  RETURN RESULT;   
END;

 
 
