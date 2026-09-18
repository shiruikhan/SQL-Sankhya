/*==============================================================================
  Nome do Script : SNK_GET_VLRITENS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o valor liquido dos itens de uma nota, excluindo itens embutidos em
                  kit (USOPROD = 'D').
  Assinatura     : SNK_GET_VLRITENS ( P_NUNOTA IN INTEGER )
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_VLRITENS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_VLRITENS ( P_NUNOTA IN INTEGER ) 
RETURN FLOAT IS
  V_RESULT FLOAT;
BEGIN
  SELECT NVL(SUM( ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED + ITE.VLRSUBST + ITE.VLRIPI ),0)
  INTO V_RESULT
  FROM TGFITE ITE
  WHERE ITE.NUNOTA = P_NUNOTA 
    AND ITE.SEQUENCIA > 0 
    AND ITE.USOPROD <> 'D';
    
  RETURN V_RESULT;                     
END;

 
 
