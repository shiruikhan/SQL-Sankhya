/*==============================================================================
  Nome do Script : EVP_GET_CAMPO_INT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Alias de ACT_INT_PARAM (parametro inteiro de acao/evento).
  Assinatura     : EVP_GET_CAMPO_INT (P_CHAVE VARCHAR2, P_NOME VARCHAR2) RETURN
                  NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EVP_GET_CAMPO_INT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EVP_GET_CAMPO_INT (P_CHAVE VARCHAR2, P_NOME VARCHAR2)
RETURN NUMBER
IS  
BEGIN
    RETURN ACT_INT_PARAM(P_CHAVE,P_NOME);        
END;
