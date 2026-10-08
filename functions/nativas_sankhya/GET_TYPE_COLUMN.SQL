/*==============================================================================
  Nome do Script : GET_TYPE_COLUMN
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o tipo de dado de uma coluna de tabela (com
                  tamanho/precisao).
  Assinatura     : GET_TYPE_COLUMN (P_TABELA VARCHAR2, P_COLUNA VARCHAR2)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TYPE_COLUMN', 'SPARKPRD') FROM dual;
                  - Acentos aparecem como ? no DDL exportado; nao foi verificado
                    se o caractere esta corrompido no proprio banco ou apenas
                    na exportacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TYPE_COLUMN (P_TABELA   VARCHAR2,
                                           P_COLUNA   VARCHAR2)
RETURN VARCHAR2
IS
  P_RESULT           VARCHAR2(255);
  P_TYPE             VARCHAR2(50);
  P_DATA_PRECISION   VARCHAR2(50);
  P_DATA_LENGTH      VARCHAR2(50);
  P_DATA_SCALE       VARCHAR2(50);
BEGIN
  BEGIN  
    SELECT DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE
      INTO P_TYPE, P_DATA_LENGTH, P_DATA_PRECISION, P_DATA_SCALE
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = UPPER(P_TABELA)
      AND COLUMN_NAME = UPPER(P_COLUNA);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20101, 'A coluna solicitada n?o existe na tabela');
  END;
  
  IF INSTR(P_TYPE, 'CHAR') > 0 THEN
    P_RESULT := P_TYPE||'('||P_DATA_LENGTH||')';
  ELSIF P_TYPE = 'NUMBER' THEN
    P_RESULT := P_TYPE||'('||P_DATA_PRECISION||', '||P_DATA_SCALE||')';
  ELSE
    P_RESULT := P_TYPE;
  END IF;
   
  RETURN P_RESULT;   
END;
