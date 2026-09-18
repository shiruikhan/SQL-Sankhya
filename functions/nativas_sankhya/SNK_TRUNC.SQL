/*==============================================================================
  Nome do Script : SNK_TRUNC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Trunca (sem arredondar) um valor FLOAT para um numero de casas decimais.
  Assinatura     : SNK_TRUNC (VALOR FLOAT, CASAS_DECIMAIS NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TRUNC', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TRUNC (VALOR FLOAT, CASAS_DECIMAIS  NUMBER)
RETURN FLOAT
IS
  RESULT  FLOAT;
BEGIN

  RESULT := ROUND(VALOR * POWER( 10 , CASAS_DECIMAIS ),0)/POWER( 10 , CASAS_DECIMAIS);
  RETURN RESULT; 

END;

 
 
