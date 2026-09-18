/*==============================================================================
  Nome do Script : SNK_GET_PK_FOR_ESOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta condicao SQL de igualdade de chave primaria (O.col = N.col) de uma
                  tabela, para comparacao de registros no eSocial.
  Assinatura     : SNK_GET_PK_FOR_ESOCIAL (P_TABELA VARCHAR2, P_COL_EXCESSAO VARCHAR2 := NULL)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PK_FOR_ESOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PK_FOR_ESOCIAL (P_TABELA           VARCHAR2,
                                                  P_COL_EXCESSAO     VARCHAR2 := NULL)
RETURN VARCHAR2
AS
    P_RESULT    VARCHAR2(1000) := ' ';
    P_COL       VARCHAR2(4000);
BEGIN
    P_COL := ','||REPLACE(P_COL_EXCESSAO, ' ', '')||',';
    FOR COL IN (SELECT COLUMN_NAME
                FROM USER_CONS_COLUMNS COL
                     INNER JOIN USER_CONSTRAINTS CONS ON CONS.CONSTRAINT_NAME = COL.CONSTRAINT_NAME AND CONS.CONSTRAINT_TYPE = 'P'
                WHERE COL.TABLE_NAME = P_TABELA
                  AND INSTR(P_COL_EXCESSAO, COL.COLUMN_NAME) = 0
                ORDER BY COL.POSITION) LOOP
        IF P_RESULT = ' ' THEN
            P_RESULT := ' AND O.'||COL.COLUMN_NAME||' = N.'||COL.COLUMN_NAME;
        ELSE
            P_RESULT := P_RESULT || ' AND O.'||COL.COLUMN_NAME||' = N.'||COL.COLUMN_NAME;
        END IF;
    END LOOP;
    RETURN P_RESULT;
END;
