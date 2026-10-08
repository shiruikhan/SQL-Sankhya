/*==============================================================================
  Nome do Script : RECEBIMENTO_PESO_CONFERIDO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o peso bruto conferido de uma conferencia (TGWCOI),
                  ignorando recontagem.
  Assinatura     : RECEBIMENTO_PESO_CONFERIDO (P_NUCONFERENCIA NUMBER) RETURN
                  FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'RECEBIMENTO_PESO_CONFERIDO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION RECEBIMENTO_PESO_CONFERIDO (P_NUCONFERENCIA NUMBER)
RETURN FLOAT
IS  
    P_VALOR FLOAT;
BEGIN
    BEGIN
        SELECT SUM (NVL (COI.QTDECONF * (SELECT PESOBRUTO  FROM TGFPRO PRO WHERE PRO.CODPROD = COI.CODPROD), 0))  AS PESOCONFERIDO INTO P_VALOR
        FROM TGWCOI COI
       WHERE COI.RECONTAGEM = 'N' AND COI.NUCONFERENCIA = P_NUCONFERENCIA
    GROUP BY NUCONFERENCIA;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 0;     
    END;
    
    RETURN P_VALOR;        
END;
