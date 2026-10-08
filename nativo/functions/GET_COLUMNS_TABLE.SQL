/*==============================================================================
  Nome do Script : GET_COLUMNS_TABLE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Lista as colunas de uma tabela separadas por virgula,
                  excluindo as indicadas.
  Assinatura     : GET_COLUMNS_TABLE (P_TABLE VARCHAR2, P_COLUMNNS_EXCECAO
                  VARCHAR2 DEFAULT '*') RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_COLUMNS_TABLE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_COLUMNS_TABLE (P_TABLE VARCHAR2, P_COLUMNNS_EXCECAO VARCHAR2 DEFAULT '*')
RETURN VARCHAR2
IS  
  P_COLUMN	 VARCHAR2(30);
  P_RESULT	 VARCHAR2(4000);
  CURSOR CUR_COLUMNS IS
    SELECT COLUMN_NAME
    FROM USER_TAB_COLUMNS
    WHERE UPPER(TABLE_NAME) = UPPER(P_TABLE)
      AND INSTR(P_COLUMNNS_EXCECAO, COLUMN_NAME) = 0;  
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
