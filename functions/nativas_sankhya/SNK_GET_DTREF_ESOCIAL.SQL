/*==============================================================================
  Nome do Script : SNK_GET_DTREF_ESOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a menor data de referencia configurada para o eSocial (TFPSAMB).
  Assinatura     : SNK_GET_DTREF_ESOCIAL (sem parametros)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DTREF_ESOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DTREF_ESOCIAL 
RETURN DATE
AS
P_RET               DATE;
BEGIN
    SELECT MIN(REFERENCIA) INTO P_RET FROM TFPSAMB;
    RETURN P_RET;
END;
