/*==============================================================================
  Nome do Script : SNK_TONUMBER
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Wrapper para a funcao nativa TO_NUMBER.
  Assinatura     : SNK_TONUMBER (CNRO IN VARCHAR)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TONUMBER', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TONUMBER (CNRO IN VARCHAR) RETURN NUMBER
AS
BEGIN
   RETURN TO_NUMBER(CNRO);
END;
