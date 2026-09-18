/*==============================================================================
  Nome do Script : SNK_GET_ROTINA_FEC_CTB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a rotina contabil corrente armazenada no pacote de sessao
                  TCBBFC_LOG_PKG.
  Assinatura     : SNK_GET_ROTINA_FEC_CTB (sem parametros)
                   RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ROTINA_FEC_CTB', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ROTINA_FEC_CTB 
RETURN CHAR
AS
BEGIN
  RETURN (TCBBFC_LOG_PKG.V_ROTINACTB);
END;
