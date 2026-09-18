/*==============================================================================
  Nome do Script : SNK_FORMAT_DATE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_CHAR de data com o formato informado.
  Assinatura     : SNK_FORMAT_DATE (DATA DATE, FORMATO VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_FORMAT_DATE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_FORMAT_DATE (DATA DATE, FORMATO  VARCHAR2)
RETURN VARCHAR2
IS
  RESULT    VARCHAR2(40);
BEGIN
  RESULT := TO_CHAR(DATA, FORMATO);
  RETURN RESULT;
END;

 
 
