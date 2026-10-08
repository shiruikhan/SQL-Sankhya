/*==============================================================================
  Nome do Script : TIM_MONTHEXT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o nome do mes por extenso de uma data.
  Assinatura     : TIM_MONTHEXT (DATA DATE) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_MONTHEXT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_MONTHEXT (DATA DATE)
RETURN VARCHAR2
IS
    V_MON NUMBER;
    V_RET VARCHAR2(20);
BEGIN
    V_MON := TIM_MONTH(DATA);
    SELECT CASE 
                WHEN V_MON = 1 THEN
                    'Janeiro'
                WHEN V_MON = 2 THEN
                    'Fevereiro'
                WHEN V_MON = 3 THEN
                    'Março'
                WHEN V_MON = 4 THEN
                    'Abril'
                WHEN V_MON = 5 THEN
                    'Maio'
                WHEN V_MON = 6 THEN
                    'Junho'
                WHEN V_MON = 7 THEN
                    'Julho'
                WHEN V_MON = 8 THEN
                    'Agosto'
                WHEN V_MON = 9 THEN
                    'Setembro'
                WHEN V_MON = 10 THEN
                    'Outubro'
                WHEN V_MON = 11 THEN
                    'Novembro'
                WHEN V_MON = 12 THEN
                    'Dezembro'
                END INTO V_RET
    FROM DUAL;
    RETURN V_RET;
END;
