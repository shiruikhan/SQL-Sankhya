/*==============================================================================
  Nome do Script : SNK_GET_DTREFCUSTOGOL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a ultima data de referencia de custo (TGFCGM) de uma empresa ate a
                  data informada.
  Assinatura     : SNK_GET_DTREFCUSTOGOL ( P_CODEMP INT, P_DTATUAL DATE )
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DTREFCUSTOGOL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DTREFCUSTOGOL ( P_CODEMP INT, P_DTATUAL DATE )
   RETURN DATE AS
   P_RESULT   DATE;
BEGIN
   SELECT MAX( C.DTREF )
     INTO P_RESULT
     FROM TGFCGM C
    WHERE C.CODEMP = P_CODEMP
      AND C.DTREF <= P_DTATUAL;
   RETURN P_RESULT;
END;

 
 
