/*==============================================================================
  Nome do Script : GET_INDICE_AJUSTE_NOTA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o indice de ajuste de itens (1 - |juros - desconto|
                  / total) de uma nota.
  Assinatura     : GET_INDICE_AJUSTE_NOTA ( P_NUNOTA IN INTEGER ) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_INDICE_AJUSTE_NOTA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_INDICE_AJUSTE_NOTA ( P_NUNOTA IN INTEGER ) RETURN FLOAT IS
RESULT FLOAT;
BEGIN
   BEGIN
     SELECT
       1 - ABS( ( CAB.VLRJURO - CAB.VLRDESCTOT ) / (SELECT SUM(ITE.VLRTOT-ITE.VLRDESC) FROM TGFITE ITE WHERE ITE.NUNOTA = CAB.NUNOTA) ) INTO RESULT 
     FROM
       TGFCAB CAB
     WHERE NUNOTA = P_NUNOTA;
     RETURN RESULT;
   EXCEPTION
     WHEN NO_DATA_FOUND OR ZERO_DIVIDE THEN
       RETURN 0;
     WHEN OTHERS THEN
       RAISE;
   END;
END GET_INDICE_AJUSTE_NOTA;
