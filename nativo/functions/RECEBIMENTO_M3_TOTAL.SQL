/*==============================================================================
  Nome do Script : RECEBIMENTO_M3_TOTAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o volume (m3) total das notas de um recebimento WMS.
  Assinatura     : RECEBIMENTO_M3_TOTAL (P_NURECEBIMENTO NUMBER) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'RECEBIMENTO_M3_TOTAL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION RECEBIMENTO_M3_TOTAL (P_NURECEBIMENTO NUMBER)
RETURN FLOAT
IS  
    P_VALOR FLOAT;
BEGIN
    BEGIN
        SELECT SUM (NVL (ITE.M3, 0)) AS M3TOTAL INTO P_VALOR
      FROM TGFITE ITE
           INNER JOIN TGWRXN RXN ON (RXN.NUNOTA = ITE.NUNOTA)
           WHERE RXN.NURECEBIMENTO =  P_NURECEBIMENTO
            GROUP BY RXN.NURECEBIMENTO;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 0;     
    END;
    
    RETURN P_VALOR;        
END;
