/*==============================================================================
  Nome do Script : SNK_DIF_SEG
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Diferenca em segundos entre dois timestamps.
  Assinatura     : SNK_DIF_SEG ( P_DTINI IN TIMESTAMP, P_DTFIN IN TIMESTAMP)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_DIF_SEG', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_DIF_SEG (
                                          P_DTINI     IN   TIMESTAMP,
                                          P_DTFIN     IN   TIMESTAMP) 
RETURN FLOAT IS
   P_DIF_SEG   NUMBER(12,4);
BEGIN

   WITH dif_seg AS (
      SELECT P_DTFIN - P_DTINI diff 
        FROM dual
      )
         SELECT
               EXTRACT(HOUR FROM diff) * 3600 + 
               EXTRACT(MINUTE FROM diff) * 60 + 
               EXTRACT(SECOND FROM diff)  dif_seg
           INTO
               P_DIF_SEG
   FROM dif_seg;
   RETURN P_DIF_SEG;

EXCEPTION WHEN OTHERS THEN
    RETURN -1;
END SNK_DIF_SEG;
