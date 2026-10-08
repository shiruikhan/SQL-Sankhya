/*==============================================================================
  Nome do Script : TIM_MONTH
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o mes (numero) de uma data.
  Assinatura     : TIM_MONTH (DATA DATE) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_MONTH', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_MONTH (DATA DATE)
RETURN NUMBER
IS
BEGIN
    RETURN TO_NUMBER(TO_CHAR(DATA,'MM'));
END;
