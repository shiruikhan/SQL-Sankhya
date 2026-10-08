/*==============================================================================
  Nome do Script : TIM_TOCHARDATE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_CHAR de data no formato DD/MM/YYYY.
  Assinatura     : TIM_TOCHARDATE (P_DATA DATE) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_TOCHARDATE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_TOCHARDATE (P_DATA DATE)
RETURN VARCHAR
IS
BEGIN
    RETURN TO_CHAR(P_DATA,'DD/MM/YYYY');
END;
