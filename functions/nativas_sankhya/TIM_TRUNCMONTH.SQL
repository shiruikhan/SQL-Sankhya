/*==============================================================================
  Nome do Script : TIM_TRUNCMONTH
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Trunca a data para o primeiro dia do mes.
  Assinatura     : TIM_TRUNCMONTH (DATA DATE) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_TRUNCMONTH', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_TRUNCMONTH (DATA DATE)
RETURN DATE
IS
BEGIN
    RETURN TRUNC(DATA,'MM');
END;
