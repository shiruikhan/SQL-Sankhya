/*==============================================================================
  Nome do Script : SNK_TRIM
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Wrapper para a funcao nativa TRIM.
  Assinatura     : SNK_TRIM (VALOR VARCHAR2 )
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TRIM', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TRIM (VALOR VARCHAR2 )
RETURN VARCHAR2
IS
  RESULT  VARCHAR2(4000);
BEGIN
  RESULT := TRIM(VALOR);
  RETURN RESULT;
END;

 
 
