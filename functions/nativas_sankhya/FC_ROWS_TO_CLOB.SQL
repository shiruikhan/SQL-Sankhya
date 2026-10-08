/*==============================================================================
  Nome do Script : FC_ROWS_TO_CLOB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Executa dinamicamente um SELECT de coluna unica e concatena
                  todas as linhas em um CLOB.
  Assinatura     : FC_ROWS_TO_CLOB ( P_COLUMNNAME IN VARCHAR2, P_FROM IN
                  VARCHAR2, P_WHERE IN VARCHAR2) RETURN CLOB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FC_ROWS_TO_CLOB', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FC_ROWS_TO_CLOB (
   P_COLUMNNAME   IN VARCHAR2,
   P_FROM         IN VARCHAR2,
   P_WHERE        IN VARCHAR2)
   RETURN CLOB
IS
   TYPE CURTYP IS REF CURSOR;

   V_SQL_STMT   VARCHAR2 (200);
   REC          VARCHAR2 (4000);
   V_CLOB       CLOB;
   V_TMP_CLOB   CLOB;
   CUR          CURTYP;
BEGIN
   V_SQL_STMT :=
      'SELECT ' || P_COLUMNNAME || ' AS TEXT ' || P_FROM || ' ' || P_WHERE;

   OPEN CUR FOR V_SQL_STMT;

   LOOP
      FETCH CUR INTO REC;

      EXIT WHEN CUR%NOTFOUND;

      IF (V_CLOB IS NULL)
      THEN                                                       -- FIRST ITEM
         V_CLOB := REC;
      ELSE                                                  -- SUBSEQUENT ITEM
         V_TMP_CLOB := REC;
         V_CLOB := V_CLOB || V_TMP_CLOB;                    -- PREPEND NEWLINE
      END IF;
   END LOOP;

   CLOSE CUR;

   RETURN (V_CLOB);
END;
