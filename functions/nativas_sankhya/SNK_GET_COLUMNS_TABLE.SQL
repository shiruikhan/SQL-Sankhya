/*==============================================================================
  Nome do Script : SNK_GET_COLUMNS_TABLE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a lista de colunas de uma tabela concatenada por virgula,
                  excluindo as colunas informadas.
  Assinatura     : SNK_GET_COLUMNS_TABLE (P_TABLE VARCHAR2, P_COLUMNNS_EXCECAO VARCHAR2 DEFAULT '*')
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_COLUMNS_TABLE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_COLUMNS_TABLE (P_TABLE VARCHAR2, P_COLUMNNS_EXCECAO VARCHAR2 DEFAULT '*')
RETURN VARCHAR2
IS  
  P_COLUMN   VARCHAR2(30);
  P_RESULT   VARCHAR2(4000);
  CURSOR CUR_COLUMNS IS
    SELECT COLUMN_NAME
    FROM USER_TAB_COLUMNS
    WHERE UPPER(TABLE_NAME) = UPPER(P_TABLE)
      AND INSTR(P_COLUMNNS_EXCECAO, COLUMN_NAME) = 0
    ORDER BY COLUMN_ID;  
BEGIN  
  P_RESULT := ' ';
  P_COLUMN := '';
  OPEN CUR_COLUMNS;
  LOOP
    FETCH CUR_COLUMNS INTO P_COLUMN;
  EXIT WHEN CUR_COLUMNS%NOTFOUND;
  IF P_RESULT = ' ' THEN
    P_RESULT := P_COLUMN;
  ELSE
    P_RESULT := P_RESULT ||', '||P_COLUMN;
  END IF;
  END LOOP;
  CLOSE CUR_COLUMNS;
  RETURN P_RESULT; 
END;
