/*==============================================================================
  Nome do Script : SNK_DIVIDIR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Divisao segura: retorna 0/dividendo se o divisor for nulo ou zero,
                  evitando ORA-01476.
  Assinatura     : SNK_DIVIDIR (P_DIVIDENDO IN FLOAT, P_DIVISOR IN FLOAT)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_DIVIDIR', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_DIVIDIR (P_DIVIDENDO IN FLOAT, P_DIVISOR IN FLOAT)
RETURN FLOAT
IS
BEGIN
  IF P_DIVISOR IS NULL OR
     P_DIVISOR = 0 THEN
    RETURN NVL(P_DIVIDENDO,0);
  ELSE
    RETURN ROUND(NVL(P_DIVIDENDO,0) / P_DIVISOR, 8);
  END IF;
END;

 
 
