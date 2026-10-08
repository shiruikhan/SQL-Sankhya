/*==============================================================================
  Nome do Script : GET_CORRETORLOGADO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo do corretor vinculado ao usuario logado
                  (TSIUSU.CORCODIGO).
  Assinatura     : GET_CORRETORLOGADO RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_CORRETORLOGADO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_CORRETORLOGADO 
RETURN NUMBER
IS
  CORRETOR NUMBER(10, 0);
BEGIN
  SELECT CORCODIGO INTO CORRETOR FROM TSIUSU WHERE CODUSU = STP_GET_CODUSULOGADO();
  RETURN CORRETOR;
END;
