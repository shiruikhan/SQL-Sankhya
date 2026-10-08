/*==============================================================================
  Nome do Script : TIM_TODATE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_DATE de string no formato DD/MM/YYYY.
  Assinatura     : TIM_TODATE (DATA VARCHAR) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_TODATE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_TODATE (DATA VARCHAR)
RETURN DATE
IS
BEGIN
    RETURN TO_DATE(DATA, 'DD/MM/YYYY');
END;
