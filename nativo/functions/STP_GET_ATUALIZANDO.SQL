/*==============================================================================
  Nome do Script : STP_GET_ATUALIZANDO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Le a variavel de sessao VARIAVEIS_PKG.V_ATUALIZANDO
                  (processo de atualizacao em andamento).
  Assinatura     : STP_GET_ATUALIZANDO RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'STP_GET_ATUALIZANDO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION STP_GET_ATUALIZANDO 
RETURN BOOLEAN
IS 
BEGIN  
  RETURN VARIAVEIS_PKG.V_ATUALIZANDO;
END;
