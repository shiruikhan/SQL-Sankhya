/*==============================================================================
  Nome do Script : SNK_FORMAT_MOEDA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata um valor FLOAT como moeda no padrao brasileiro (separador de
                  milhar e decimal).
  Assinatura     : SNK_FORMAT_MOEDA (P_VALOR FLOAT)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_FORMAT_MOEDA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_FORMAT_MOEDA (P_VALOR FLOAT)
RETURN VARCHAR2
AS
  RESULT VARCHAR2(4000);
BEGIN
  IF P_VALOR IS NOT NULL THEN
    RESULT := TO_CHAR(P_VALOR, 'FM999G999G999D90', 'nls_numeric_characters='',.''');
  END IF;
  RETURN RESULT;
END;

 
 
