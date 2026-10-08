/*==============================================================================
  Nome do Script : EVP_GET_CAMPO_TEXTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Alias de ACT_TXT_PARAM (parametro texto de acao/evento).
  Assinatura     : EVP_GET_CAMPO_TEXTO (P_CHAVE VARCHAR2, P_NOME VARCHAR2)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EVP_GET_CAMPO_TEXTO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EVP_GET_CAMPO_TEXTO (P_CHAVE VARCHAR2, P_NOME VARCHAR2)
RETURN VARCHAR2
IS  
BEGIN
    RETURN ACT_TXT_PARAM(P_CHAVE,P_NOME);        
END;
