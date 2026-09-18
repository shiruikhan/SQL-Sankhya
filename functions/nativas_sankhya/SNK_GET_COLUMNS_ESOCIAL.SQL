/*==============================================================================
  Nome do Script : SNK_GET_COLUMNS_ESOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta condicao SQL comparando colunas antigo/novo (N.col = O.col) de uma
                  tabela, para deteccao de alteracao no eSocial.
  Assinatura     : SNK_GET_COLUMNS_ESOCIAL (P_TABLE VARCHAR2, P_COLUMNNS_EXCECAO VARCHAR2 DEFAULT '*')
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_COLUMNS_ESOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_COLUMNS_ESOCIAL (P_TABLE VARCHAR2, P_COLUMNNS_EXCECAO VARCHAR2 DEFAULT '*')
RETURN VARCHAR2
IS  
  P_RESULT          VARCHAR2(4000);
  P_APELIDO_NEW     VARCHAR2(10) := 'N.';
  P_APELIDO_OLD     VARCHAR2(10) := 'O.';
  P_FORMAT_COLUMN   VARCHAR2(1000);  
BEGIN  
  P_RESULT := ' ';
  
  FOR CUR_COLUMNS IN (SELECT COLUMN_NAME
                             , NULLABLE
                             , CASE WHEN DATA_TYPE IN ('NUMBER', 'FLOAT') THEN '0'
                                    WHEN DATA_TYPE = 'DATE' THEN 'SYSDATE'
                                    ELSE ''' ''' END AS DATA_NVL
                        FROM USER_TAB_COLUMNS
                        WHERE UPPER(TABLE_NAME) = UPPER(P_TABLE)
                            AND INSTR(P_COLUMNNS_EXCECAO, COLUMN_NAME) = 0
                            AND NOT EXISTS(SELECT 1
                                           FROM TFPMON
                                           WHERE NOMETAB = UPPER(P_TABLE)
                                             AND NOMECOLUNA = COLUMN_NAME
                                             AND TIPO = 'V')) LOOP
    
        IF CUR_COLUMNS.NULLABLE = 'Y' THEN
            P_FORMAT_COLUMN := 'NVL('||P_APELIDO_NEW||CUR_COLUMNS.COLUMN_NAME||', '||CUR_COLUMNS.DATA_NVL||') = NVL('||P_APELIDO_OLD||CUR_COLUMNS.COLUMN_NAME||', '||CUR_COLUMNS.DATA_NVL||')';
        ELSE
            P_FORMAT_COLUMN := P_APELIDO_NEW||CUR_COLUMNS.COLUMN_NAME||' = '||P_APELIDO_OLD||CUR_COLUMNS.COLUMN_NAME; 
        END IF;
        
        IF P_RESULT = ' ' THEN
            P_RESULT := P_FORMAT_COLUMN;
        ELSE
            P_RESULT := P_RESULT ||' AND '||P_FORMAT_COLUMN;
        END IF;
    END LOOP;

  RETURN P_RESULT; 
END;
