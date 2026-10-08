/*==============================================================================
  Nome do Script : RECEBIMENTO_M3_ARMAZ
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o volume (m3) ja armazenado de um recebimento WMS.
  Assinatura     : RECEBIMENTO_M3_ARMAZ (P_NURECEBIMENTO NUMBER) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'RECEBIMENTO_M3_ARMAZ', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION RECEBIMENTO_M3_ARMAZ (P_NURECEBIMENTO NUMBER)
RETURN FLOAT
IS  
    P_VALOR FLOAT;
BEGIN
    BEGIN
        SELECT SUM (X.M3ARMAZENADO) AS M3ARMAZENADO INTO P_VALOR
                     FROM ( 
                            SELECT SUM (NVL ((SELECT M3 FROM TGFPRO PRO WHERE PRO.CODPROD = ITT.CODPROD) * ITT.QTDVOLPAD, 0)) AS M3ARMAZENADO
                               FROM TGWITT ITT
                                    INNER JOIN TGWREC REC ON (REC.NUTAREFA = ITT.NUTAREFA)
                              WHERE ITT.SITUACAO = 'F' AND REC.NURECEBIMENTO = P_NURECEBIMENTO
                           UNION ALL
                            SELECT SUM (NVL ((SELECT M3 FROM TGFPRO PRO WHERE PRO.CODPROD = ITT.CODPROD) * ITT.QTDVOLPAD, 0)) AS M3ARMAZENADO
                               FROM TGWITT ITT, TGWTRA TRA 
                              WHERE  ITT.SITUACAO = 'F'  AND 
                              TRA.NUTAREFA = ITT.NUTAREFA AND TRA.NURECEBIMENTO = P_NURECEBIMENTO
                            ) X;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 0;     
    END;
    
    RETURN P_VALOR;        
END;
