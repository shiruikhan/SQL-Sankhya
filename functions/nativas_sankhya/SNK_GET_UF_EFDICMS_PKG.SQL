/*==============================================================================
  Nome do Script : SNK_GET_UF_EFDICMS_PKG
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a UF corrente armazenada no pacote de sessao EFDICMS_PKG.
  Assinatura     : SNK_GET_UF_EFDICMS_PKG (sem parametros)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_UF_EFDICMS_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_UF_EFDICMS_PKG 
RETURN VARCHAR2
AS
BEGIN
    RETURN EFDICMS_PKG.V_UF;
END;
