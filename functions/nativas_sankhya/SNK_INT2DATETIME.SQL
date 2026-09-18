/*==============================================================================
  Nome do Script : SNK_INT2DATETIME
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Combina uma data com um horario no formato decimal (HHMM) em um unico
                  DATE.
  Assinatura     : SNK_INT2DATETIME (P_DEC IN NUMBER, P_DATA IN DATE)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_INT2DATETIME', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_INT2DATETIME (P_DEC IN NUMBER, P_DATA IN DATE)
RETURN DATE
IS
BEGIN
  RETURN TO_DATE(TO_CHAR(P_DATA, 'DD/MM/YYYY') ||' '||TO_CHAR(TO_DATE(LPAD(TO_CHAR(P_DEC),4,'0'),'HH24MI'),'HH24:MI'), 'DD/MM/YYYY HH24:MI');
END;
