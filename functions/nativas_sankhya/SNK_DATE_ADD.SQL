/*==============================================================================
  Nome do Script : SNK_DATE_ADD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma um intervalo (ano/mes/dia/hora/minuto/segundo) a uma data.
  Assinatura     : SNK_DATE_ADD (DATA DATE, TIPO VARCHAR2, VALOR NUMBER)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_DATE_ADD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_DATE_ADD (DATA  DATE, TIPO VARCHAR2, VALOR NUMBER)
RETURN DATE
IS
  RESULT DATE;
BEGIN
  IF TIPO = 'YY' THEN  
    RESULT :=  ADD_MONTHS(DATA, (VALOR * 12));
  ELSIF TIPO = 'MM' THEN
    RESULT :=  ADD_MONTHS(DATA, VALOR);
  ELSIF TIPO = 'DD' THEN
    RESULT :=  DATA + VALOR;
  ELSIF TIPO = 'HH' THEN
    RESULT :=  DATA + (VALOR/24);
  ELSIF TIPO = 'MI' THEN
    RESULT :=  DATA + (VALOR/24/60);
  ELSIF TIPO = 'SS' THEN
    RESULT :=  DATA + (VALOR/24/60/60);
  ELSE
    RAISE_APPLICATION_ERROR(-20101, 'Formato de data "'||TIPO||'" n?o aceito.');
  END IF;
  
  RETURN RESULT;
END;

 
 
