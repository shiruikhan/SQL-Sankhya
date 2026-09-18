/*==============================================================================
  Nome do Script : SNK_GET_PERIODO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Classifica uma data em quinzena (1/2) ou decada do mes (1/2/3) conforme o
                  dia.
  Assinatura     : SNK_GET_PERIODO (P_DATA DATE, P_TIPO CHAR)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PERIODO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PERIODO (P_DATA DATE, P_TIPO CHAR)
RETURN NUMBER
IS
  P_RESULT NUMBER(5);
BEGIN
  P_RESULT := 0;
  IF P_TIPO = 'Q' THEN
    SELECT CASE WHEN TO_CHAR(P_DATA, 'DD') BETWEEN 1 AND 15 THEN 1
                ELSE 2 END                                      
      INTO P_RESULT
    FROM DUAL;
  ELSIF P_TIPO = 'D' THEN
    SELECT CASE WHEN TO_CHAR(P_DATA, 'DD') BETWEEN 1 AND 10 THEN 1
                WHEN TO_CHAR(P_DATA, 'DD') BETWEEN 11 AND 20 THEN 2
                ELSE 3 END
      INTO P_RESULT
    FROM DUAL;
  END IF;
  RETURN P_RESULT;  
END;

 
 
