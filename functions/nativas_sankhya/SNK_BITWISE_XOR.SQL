/*==============================================================================
  Nome do Script : SNK_BITWISE_XOR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : XOR bit a bit entre dois numeros, usa SNK_BITWISE_OR.
  Assinatura     : SNK_BITWISE_XOR (a NUMBER, b NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_BITWISE_XOR', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_BITWISE_XOR (a NUMBER, b NUMBER) RETURN NUMBER
AS
BEGIN
	RETURN SNK_BITWISE_OR(a, b) - BITAND(a, b);
END SNK_BITWISE_XOR;
