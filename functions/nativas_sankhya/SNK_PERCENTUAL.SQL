/*==============================================================================
  Nome do Script : SNK_PERCENTUAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula percentual seguro entre dividendo e divisor, retornando 0 se o
                  divisor for nulo ou zero.
  Assinatura     : SNK_PERCENTUAL (P_DIVIDENDO IN FLOAT, P_DIVISOR IN FLOAT)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_PERCENTUAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_PERCENTUAL (P_DIVIDENDO IN FLOAT, P_DIVISOR IN FLOAT)
RETURN FLOAT
IS
BEGIN
  IF P_DIVISOR IS NULL OR
     P_DIVISOR = 0 THEN
    RETURN( 0 );
  ELSE
    RETURN ROUND(NVL(P_DIVIDENDO,0) / P_DIVISOR * 100, 8);
  END IF;
END;

 
 
