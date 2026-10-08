/*==============================================================================
  Nome do Script : TIM_YEAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna TO_CHAR(data, 'DD') como numero, ou seja, o DIA e
                  nao o ano, apesar do nome (comportamento nativo).
  Assinatura     : TIM_YEAR (DATA DATE) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_YEAR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_YEAR (DATA DATE)
RETURN NUMBER
IS
BEGIN
    RETURN TO_NUMBER(TO_CHAR(DATA,'DD'));
END;
