/*==============================================================================
  Nome do Script : EVP_GET_CAMPO_DEC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Alias de ACT_DEC_PARAM (parametro decimal de acao/evento).
  Assinatura     : EVP_GET_CAMPO_DEC (P_CHAVE VARCHAR2, P_NOME VARCHAR2) RETURN
                  FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EVP_GET_CAMPO_DEC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EVP_GET_CAMPO_DEC (P_CHAVE VARCHAR2, P_NOME VARCHAR2)
RETURN FLOAT
IS  
BEGIN
    RETURN ACT_DEC_PARAM(P_CHAVE,P_NOME);        
END;
