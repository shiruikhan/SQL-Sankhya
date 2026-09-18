/*==============================================================================
  Nome do Script : SNK_GET_PK_FOR_REINF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta condicao SQL de igualdade de chave primaria de uma tabela, para
                  comparacao de registros no EFD-Reinf.
  Assinatura     : SNK_GET_PK_FOR_REINF (P_TABELA VARCHAR2, P_COL_EXCESSAO VARCHAR2 := NULL)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PK_FOR_REINF', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PK_FOR_REINF (P_TABELA           VARCHAR2,
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
                  AND INSTR(P_COL, COL.COLUMN_NAME) = 0
                  AND NOT EXISTS(SELECT 1
                                 FROM TRICOL
                                 WHERE NOMETAB = P_TABELA
                                     AND NOMECOL = COL.COLUMN_NAME
                                     AND TIPO IN ('V', 'P'))
                ORDER BY COL.POSITION) LOOP
        IF P_RESULT = ' ' THEN
            P_RESULT := ' AND O.'||COL.COLUMN_NAME||' = N.'||COL.COLUMN_NAME;
        ELSE
            P_RESULT := P_RESULT || ' AND O.'||COL.COLUMN_NAME||' = N.'||COL.COLUMN_NAME;
        END IF;
    END LOOP;
    RETURN P_RESULT;
END;
