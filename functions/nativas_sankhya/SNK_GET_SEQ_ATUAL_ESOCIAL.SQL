/*==============================================================================
  Nome do Script : SNK_GET_SEQ_ATUAL_ESOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a sequencia atual configurada para o eSocial (TFPSAMB).
  Assinatura     : SNK_GET_SEQ_ATUAL_ESOCIAL (sem parametros)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_SEQ_ATUAL_ESOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_SEQ_ATUAL_ESOCIAL 
RETURN NUMBER
AS
P_RET               NUMBER(1);
BEGIN
    SELECT MIN(SEQUENCIA_ATUAL) INTO P_RET FROM TFPSAMB;
    RETURN P_RET;
END;
