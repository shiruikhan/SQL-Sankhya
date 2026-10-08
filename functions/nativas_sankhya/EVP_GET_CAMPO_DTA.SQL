/*==============================================================================
  Nome do Script : EVP_GET_CAMPO_DTA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Alias de ACT_DTA_PARAM (parametro data de acao/evento).
  Assinatura     : EVP_GET_CAMPO_DTA (P_CHAVE VARCHAR2, P_NOME VARCHAR2) RETURN
                  DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EVP_GET_CAMPO_DTA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EVP_GET_CAMPO_DTA (P_CHAVE VARCHAR2, P_NOME VARCHAR2)
RETURN DATE
IS  
BEGIN
    RETURN ACT_DTA_PARAM(P_CHAVE,P_NOME);        
END;
