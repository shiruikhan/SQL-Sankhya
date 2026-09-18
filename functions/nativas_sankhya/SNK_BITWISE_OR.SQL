/*==============================================================================
  Nome do Script : SNK_BITWISE_OR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : OR bit a bit entre dois numeros, via BITAND.
  Assinatura     : SNK_BITWISE_OR (a NUMBER, b NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_BITWISE_OR', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_BITWISE_OR (a NUMBER, b NUMBER) RETURN NUMBER
AS
BEGIN
   RETURN a + b - BITAND(a, b);
END SNK_BITWISE_OR;
