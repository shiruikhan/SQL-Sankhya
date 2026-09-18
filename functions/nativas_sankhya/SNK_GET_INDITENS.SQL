/*==============================================================================
  Nome do Script : SNK_GET_INDITENS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o indice de rateio entre o valor total da nota (com acrescimos) e
                  a soma dos itens.
  Assinatura     : SNK_GET_INDITENS ( P_NUNOTA IN INTEGER )
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_INDITENS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_INDITENS ( P_NUNOTA IN INTEGER ) 
RETURN FLOAT IS
  V_VLRNOTA FLOAT;
  V_VLROUTROS FLOAT;
  V_VLRITENS FLOAT;
  V_RESULT FLOAT;
BEGIN
  SELECT NVL(VLRNOTA,0), NVL(VLROUTROS,0) 
    INTO V_VLRNOTA, V_VLROUTROS 
  FROM TGFCAB 
  WHERE NUNOTA = P_NUNOTA;
  
  V_VLRITENS := SNK_GET_VLRITENS( P_NUNOTA );
  
  V_RESULT := CASE WHEN V_VLRITENS = 0 THEN 1 ELSE ( V_VLRNOTA + V_VLROUTROS ) / V_VLRITENS END;
  
  RETURN V_RESULT;                      
END;

 
 
