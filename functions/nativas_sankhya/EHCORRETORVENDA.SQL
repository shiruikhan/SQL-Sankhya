/*==============================================================================
  Nome do Script : EHCORRETORVENDA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o corretor logado atende vendas (TIMCOR.CORVENDA).
  Assinatura     : EHCORRETORVENDA RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EHCORRETORVENDA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EHCORRETORVENDA 
RETURN CHAR
IS
  CORRETOR CHAR(1);
BEGIN
  SELECT NVL(CORVENDA, 'N') INTO CORRETOR FROM TIMCOR WHERE CORCODIGO = GET_CORRETORLOGADO();
  RETURN CORRETOR;
END;
