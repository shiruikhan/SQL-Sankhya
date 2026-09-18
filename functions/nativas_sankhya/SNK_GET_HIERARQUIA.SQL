/*==============================================================================
  Nome do Script : SNK_GET_HIERARQUIA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta a lista de codigos ancestrais de um registro hierarquico generico,
                  navegando via SQL dinamico (EXECUTE IMMEDIATE) recursivamente.
  Assinatura     : SNK_GET_HIERARQUIA (P_TABELA IN VARCHAR2, P_CAMPO VARCHAR2, P_CAMPOPAI VARCHAR2, P_CODIGO IN INT)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_HIERARQUIA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_HIERARQUIA (P_TABELA IN VARCHAR2, P_CAMPO VARCHAR2, P_CAMPOPAI VARCHAR2, P_CODIGO IN INT) 
RETURN VARCHAR2
IS 
  P_CODPAI  NUMBER;
  P_CODIGOS VARCHAR2(250);
  P_SQL     VARCHAR2(400);
BEGIN
  P_SQL := 'SELECT MAX('||P_CAMPOPAI||') FROM '||P_TABELA||' WHERE '||P_CAMPOPAI|| ' > 0 AND '||P_CAMPO||' = ';
  P_CODIGOS := P_CODIGO; 
  P_CODPAI := P_CODIGO;
  WHILE P_CODPAI IS NOT NULL 
  LOOP
    EXECUTE IMMEDIATE(P_SQL||P_CODPAI) INTO P_CODPAI;
    IF P_CODPAI IS NOT NULL THEN 
      P_CODIGOS := P_CODIGOS||','||P_CODPAI;
    END IF;
  END LOOP;
  RETURN P_CODIGOS; 
END;

 
 
