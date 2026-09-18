/*==============================================================================
  Nome do Script : SNK_VAL_DATA_INTERVALO_CON
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se uma data esta dentro do intervalo de faturamento vigente de um
                  contrato (mensal ou anual).
  Assinatura     : SNK_VAL_DATA_INTERVALO_CON (P_NUMCONTRATO NUMBER, P_DTREFERENCIA DATE, P_TIPPAG CHAR, P_TIPO CHAR, P_DATA_VAL DATE)
                   RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_VAL_DATA_INTERVALO_CON', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_VAL_DATA_INTERVALO_CON (P_NUMCONTRATO   NUMBER,
                                                      P_DTREFERENCIA  DATE,
                                                      P_TIPPAG        CHAR,
                                                      P_TIPO          CHAR,
                                                      P_DATA_VAL      DATE)
RETURN CHAR
AS  
  P_RESULT        CHAR(1);  
  P_DATA_INI      DATE;
  P_DATA_FIN      DATE;  
BEGIN   
  P_DATA_INI := SNK_GET_INI_FAT_CON(P_NUMCONTRATO, P_DTREFERENCIA, P_TIPPAG, P_TIPO);
  
  IF P_TIPO = 'M' THEN       
    P_DATA_FIN := LAST_DAY(P_DATA_INI); 
  ELSE       
    P_DATA_FIN := ADD_MONTHS(P_DATA_INI, 12) - 1;
  END IF;
  
  P_RESULT := CASE WHEN P_DATA_VAL BETWEEN P_DATA_INI AND P_DATA_FIN THEN 'S' ELSE 'N' END;
  RETURN P_RESULT;  
END;

 
 
