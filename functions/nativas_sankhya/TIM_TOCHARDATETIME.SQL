/*==============================================================================
  Nome do Script : TIM_TOCHARDATETIME
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : TO_CHAR de data no formato DD/MM/YYYY HH24:MI:SS.
  Assinatura     : TIM_TOCHARDATETIME (P_DATA DATE) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_TOCHARDATETIME', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_TOCHARDATETIME (P_DATA DATE)
RETURN VARCHAR
IS
BEGIN
    RETURN TO_CHAR(P_DATA,'DD/MM/YYYY HH24:MI:SS');
END;
