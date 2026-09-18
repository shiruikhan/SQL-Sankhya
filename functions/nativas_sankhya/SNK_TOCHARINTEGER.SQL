/*==============================================================================
  Nome do Script : SNK_TOCHARINTEGER
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_CHAR de um numero inteiro.
  Assinatura     : SNK_TOCHARINTEGER (INTEIRO NUMBER)
                   RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TOCHARINTEGER', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TOCHARINTEGER (INTEIRO NUMBER)
RETURN VARCHAR
IS
BEGIN
    RETURN TO_CHAR(INTEIRO);
END;
