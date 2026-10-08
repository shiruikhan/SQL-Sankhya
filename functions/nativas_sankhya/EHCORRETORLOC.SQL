/*==============================================================================
  Nome do Script : EHCORRETORLOC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o corretor logado atende locacao
                  (TIMCOR.CORLOCACAO).
  Assinatura     : EHCORRETORLOC RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EHCORRETORLOC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EHCORRETORLOC 
RETURN CHAR
IS
  CORRETOR CHAR(1);
BEGIN
  SELECT NVL(CORLOCACAO, 'N') INTO CORRETOR FROM TIMCOR WHERE CORCODIGO = GET_CORRETORLOGADO();
  RETURN CORRETOR;
END;
