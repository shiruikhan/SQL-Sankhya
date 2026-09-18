/*==============================================================================
  Nome do Script : SNK_GET_INI_FAT_CON
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula a data de inicio de faturamento de um contrato, considerando
                  pagamento antecipado ou postecipado por periodo mensal/anual.
  Assinatura     : SNK_GET_INI_FAT_CON (P_NUMCONTRATO NUMBER, P_DTREFERENCIA DATE, P_TIPPAG CHAR, P_TIPO CHAR)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_INI_FAT_CON', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_INI_FAT_CON (P_NUMCONTRATO   NUMBER,
                                               P_DTREFERENCIA  DATE,
                                               P_TIPPAG        CHAR,
                                               P_TIPO          CHAR)
RETURN DATE
AS    
  P_DATA_INI      DATE;    
BEGIN
  IF (P_TIPO = 'A') THEN
    P_DATA_INI := P_DTREFERENCIA;    
  ELSE
   P_DATA_INI := TRUNC(P_DTREFERENCIA, 'MM');
  END IF;
  
  IF (P_TIPPAG = 'A') THEN
     IF P_TIPO = 'M' THEN
       P_DATA_INI := ADD_MONTHS(P_DATA_INI, 1);   
     ELSE
       P_DATA_INI := ADD_MONTHS(P_DATA_INI, 12);  
     END IF;     
  ELSIF (P_TIPPAG = 'V') THEN
    IF P_TIPO = 'M' THEN
       P_DATA_INI := ADD_MONTHS(P_DATA_INI, -1);   
     ELSE
       P_DATA_INI := ADD_MONTHS(P_DATA_INI, -12);  
     END IF;
  END IF;
 RETURN P_DATA_INI;  
END;

 
 
