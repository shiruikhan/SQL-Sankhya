/*==============================================================================
  Nome do Script : GET_ADIARATUALIZACAOESTOQUE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Le a variavel de sessao
                  VARIAVEIS_PKG.V_ADIARATUALIZACAOESTOQUE.
  Assinatura     : GET_ADIARATUALIZACAOESTOQUE RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_ADIARATUALIZACAOESTOQUE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_ADIARATUALIZACAOESTOQUE 
RETURN VARCHAR2
IS 
BEGIN  
  RETURN VARIAVEIS_PKG.V_ADIARATUALIZACAOESTOQUE;
END;
