/*==============================================================================
  Nome do Script : SNK_GET_DATE_PART
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Extrai uma parte (ano/mes/dia etc.) de uma data como numero.
  Assinatura     : SNK_GET_DATE_PART (DATA DATE, TIPO CHAR)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DATE_PART', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DATE_PART (DATA DATE, TIPO CHAR)
RETURN NUMBER
IS
  RESULT    NUMBER(5);
  FORMATO   VARCHAR(4);
BEGIN
  IF TIPO = 'YY' THEN
    FORMATO := 'YYYY';
  ELSE
    FORMATO := TIPO;
  END IF;
  RESULT := TO_NUMBER(TO_CHAR(DATA, FORMATO));
  RETURN RESULT;
END;

 
 
