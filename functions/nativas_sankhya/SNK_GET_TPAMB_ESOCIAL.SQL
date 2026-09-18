/*==============================================================================
  Nome do Script : SNK_GET_TPAMB_ESOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o ambiente (producao/homologacao) configurado para o eSocial
                  (TFPSAMB).
  Assinatura     : SNK_GET_TPAMB_ESOCIAL (sem parametros)
                   RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_TPAMB_ESOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_TPAMB_ESOCIAL 
RETURN CHAR
AS
P_RET               CHAR(1);
BEGIN
    SELECT AMBIENTE INTO P_RET FROM TFPSAMB;
    RETURN P_RET;
END;
