/*==============================================================================
  Nome do Script : SNK_TODATE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_DATE de uma string no formato DD/MM/YYYY.
  Assinatura     : SNK_TODATE (DATA VARCHAR)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TODATE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TODATE (DATA VARCHAR)
RETURN DATE
IS
BEGIN
    RETURN TO_DATE(DATA, 'DD/MM/YYYY');
END;
