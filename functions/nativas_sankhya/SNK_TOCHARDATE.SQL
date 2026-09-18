/*==============================================================================
  Nome do Script : SNK_TOCHARDATE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_CHAR de data no formato DD/MM/YYYY.
  Assinatura     : SNK_TOCHARDATE (P_DATA DATE)
                   RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TOCHARDATE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TOCHARDATE (P_DATA DATE)
RETURN VARCHAR
IS
BEGIN
    RETURN TO_CHAR(P_DATA,'DD/MM/YYYY');
END;
