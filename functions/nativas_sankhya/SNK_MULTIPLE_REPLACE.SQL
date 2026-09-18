/*==============================================================================
  Nome do Script : SNK_MULTIPLE_REPLACE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Substitui nomes de coluna em um texto SQL por bind variables (':coluna'),
                  para montagem dinamica de comandos.
  Assinatura     : SNK_MULTIPLE_REPLACE (P_TABLE VARCHAR2, P_TEXT VARCHAR2,P_COLUMNNS_REPLACE VARCHAR2 DEFAULT '*')
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_MULTIPLE_REPLACE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_MULTIPLE_REPLACE (P_TABLE VARCHAR2,  P_TEXT VARCHAR2,P_COLUMNNS_REPLACE VARCHAR2 DEFAULT '*')
RETURN VARCHAR2
IS  
  P_COLUMN          VARCHAR2(30);
  P_RESULT          VARCHAR2(4000);
  CURSOR CUR_COLUMNS IS
    SELECT COLUMN_NAME
    FROM USER_TAB_COLUMNS
    WHERE UPPER(TABLE_NAME) = UPPER(P_TABLE)
      AND INSTR(P_COLUMNNS_REPLACE, COLUMN_NAME) <> 0
    ORDER BY COLUMN_ID;  
BEGIN  
  P_RESULT := ' ';
  P_COLUMN := '';
  OPEN CUR_COLUMNS;
  LOOP
    FETCH CUR_COLUMNS INTO P_COLUMN;
  EXIT WHEN CUR_COLUMNS%NOTFOUND;
    IF P_RESULT = ' ' THEN
        P_RESULT :=  REPLACE(P_TEXT,' '||P_COLUMN,':'||P_COLUMN);
    ELSE
        P_RESULT := REPLACE(P_RESULT,' '||P_COLUMN, ':'||P_COLUMN);
        P_RESULT := REPLACE(P_RESULT,'::', ':');
    END IF;
  END LOOP;
  CLOSE CUR_COLUMNS;

  RETURN P_RESULT; 
END;
