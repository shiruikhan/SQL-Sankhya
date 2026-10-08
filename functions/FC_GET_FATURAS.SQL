/*==============================================================================
  Nome do Script : FC_GET_FATURAS
  Tipo           : Function (customizacao -- fora do padrao _SPARK de autoria interna)
  Descricao      : Concatena as parcelas dos titulos de uma nota (TGFFIN:
                  desdobramento, vencimento e valor, separadas por " | "),
                  excluindo os tipos de titulo 34, 35, 36 e 15 e empresas >=
                  500.
  Assinatura     : FC_GET_FATURAS (P_NUNOTA IN TGFCAB.NUNOTA%TYPE) RETURN
                  VARCHAR2
  Observacoes    : - Capturada do banco em 08/10/2026 (copia fiel do objeto
                    em producao, sem alteracoes), via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FC_GET_FATURAS', 'SPARKPRD') FROM dual;
                  - Origem nao confirmada: nome sem sufixo _SPARK, mas criada
                    apos a instalacao e com regras de negocio da Spark; tratada
                    como customizacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION FC_GET_FATURAS (P_NUNOTA IN TGFCAB.NUNOTA%TYPE)
RETURN VARCHAR2 IS

    CURSOR T_ITENS IS 
    SELECT 'Parc=' || FIN. DESDOBRAMENTO || ' Venc='||TO_CHAR(FIN.DTVENC,'DD/MM/YYYY') || ' Valor=' || TO_CHAR(FIN.VLRDESDOB,'FM999G999G990D00') || ' | ' 
    FROM TGFFIN FIN
    WHERE FIN.NUNOTA = P_NUNOTA
    AND FIN.CODTIPTIT NOT IN (34, 35, 36,15)
    AND FIN.CODEMP < 500
    ORDER BY FIN. DESDOBRAMENTO;
    
    
    P_TITULOS VARCHAR2(4000);
    P_NOTA VARCHAR2(4000) := '';
BEGIN
  OPEN T_ITENS;
  LOOP 
     FETCH T_ITENS INTO P_TITULOS;
     EXIT WHEN T_ITENS%NOTFOUND;

     P_NOTA := P_NOTA || P_TITULOS || '';
  END LOOP;
  CLOSE T_ITENS;

  P_NOTA := SUBSTR(P_NOTA, 0, LENGTH(P_NOTA) - 3);

  RETURN P_NOTA;
END;
