/*==============================================================================
  Nome do Script : SNK_GET_CUS_VAR_TIT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o custo variavel de titulo financeiro de uma nota (percentual
                  sobre valor + valor fixo por titulo).
  Assinatura     : SNK_GET_CUS_VAR_TIT (P_NUNOTA NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CUS_VAR_TIT', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CUS_VAR_TIT (P_NUNOTA NUMBER)
RETURN NUMBER
IS
 P_CUSVARTIT NUMBER;
BEGIN
   BEGIN
     SELECT SUM((NVL(TIT.PERCCUSVAR,0) * FIN.VLRDESDOB)
                 + (NVL(TIT.VLRCUSVAR,0) * 100))
     INTO P_CUSVARTIT 
     FROM TGFFIN FIN, TGFTIT TIT
     WHERE FIN.NUNOTA = P_NUNOTA 
       AND FIN.CODTIPTIT = TIT.CODTIPTIT;
   EXCEPTION WHEN OTHERS THEN
     P_CUSVARTIT := 0;
   END;
   
   RETURN P_CUSVARTIT;
END;

 
 
