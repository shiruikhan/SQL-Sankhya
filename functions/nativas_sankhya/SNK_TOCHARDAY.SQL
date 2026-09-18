/*==============================================================================
  Nome do Script : SNK_TOCHARDAY
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o dia (DD) de uma data como string.
  Assinatura     : SNK_TOCHARDAY (DATA DATE)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TOCHARDAY', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TOCHARDAY (DATA DATE)
RETURN VARCHAR2
IS
BEGIN
    RETURN TO_CHAR(DATA,'DD');
END;
