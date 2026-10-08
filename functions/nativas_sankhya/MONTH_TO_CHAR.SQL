/*==============================================================================
  Nome do Script : MONTH_TO_CHAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o nome do mes por extenso a partir do numero
                  (formato completo ou resumido).
  Assinatura     : MONTH_TO_CHAR (MES NUMBER, RESUMIDO NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'MONTH_TO_CHAR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION MONTH_TO_CHAR (MES NUMBER, RESUMIDO NUMBER)
RETURN VARCHAR2
IS
    RESULT VARCHAR2(20);
BEGIN
    IF MES = 1 THEN
        RESULT := 'Janeiro';
    ELSIF MES = 2 THEN
        RESULT := 'Fevereiro';
    ELSIF MES = 3 THEN
        RESULT := 'Março';
    ELSIF MES = 4 THEN
        RESULT := 'Abril';
    ELSIF MES = 5 THEN
        RESULT := 'Maio';        
    ELSIF MES = 6 THEN
        RESULT := 'Junho';
    ELSIF MES = 7 THEN
        RESULT := 'Julho';
    ELSIF MES = 8 THEN
        RESULT := 'Agosto';
    ELSIF MES = 9 THEN
        RESULT := 'Setembro';
    ELSIF MES = 10 THEN
        RESULT := 'Outubro';
    ELSIF MES = 11 THEN
        RESULT := 'Novembro';
    ELSIF MES = 12 THEN
        RESULT := 'Dezembro';
    END IF;
    IF RESUMIDO > 0 THEN
        RETURN SUBSTR(RESULT, 0, 3);
    ELSE
        RETURN RESULT;
    END IF;
END;
