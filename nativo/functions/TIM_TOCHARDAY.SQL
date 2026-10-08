/*==============================================================================
  Nome do Script : TIM_TOCHARDAY
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_CHAR de data com formato DD (dia).
  Assinatura     : TIM_TOCHARDAY (DATA DATE) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_TOCHARDAY', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_TOCHARDAY (DATA DATE)
RETURN VARCHAR2
IS
BEGIN
    RETURN TO_CHAR(DATA,'DD');
END;
