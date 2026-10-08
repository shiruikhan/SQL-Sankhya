/*==============================================================================
  Nome do Script : FC_RATEIOFRETE_SAPARK
  Tipo           : Function (customizacao -- fora do padrao _SPARK de autoria interna)
  Descricao      : Calcula o percentual (0 a 1, 6 casas) do valor das notas
                  vinculadas (TGFNCT/TGFCAB pela chave NF-e) que e base de
                  DIFAL, considerando as TOPs 201, 221, 224, 231 e 209 sobre o
                  total. Criada por Lucas Gabriel (ONTIME TECH) em 04/08/2025
                  para apoiar o calculo do DIFAL. O sufixo SAPARK parece erro
                  de digitacao de SPARK.
  Assinatura     : FC_RATEIOFRETE_SAPARK ( P_NUNOTA IN NUMBER ) RETURN NUMBER
  Observacoes    : - Capturada do banco em 08/10/2026 (copia fiel do objeto
                    em producao, sem alteracoes), via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FC_RATEIOFRETE_SAPARK', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FC_RATEIOFRETE_SAPARK (
    P_NUNOTA IN NUMBER
) RETURN NUMBER
AS
    V_CALC_DIFAL NUMBER := 0;
    V_TOTAL      NUMBER := 0;
    V_PERC       NUMBER := 0;
/******************************************************************************
Autor: Lucas Gabriel - ONTIME TECH
Data:04/08/2025
Objetivo:apoiar no calculo do DIFAL
******************************************************************************/
BEGIN
    SELECT 
        SUM(CASE WHEN C.CODTIPOPER IN (201, 221, 224 , 231,209) THEN C.VLRNOTA ELSE 0 END),
        SUM(C.VLRNOTA)
    INTO 
        V_CALC_DIFAL,
        V_TOTAL
    FROM TGFNCT NCT
    INNER JOIN TGFCAB C
        ON C.CHAVENFE = NCT.CHAVENFE
    WHERE NCT.NUNOTA = P_NUNOTA;

    IF V_TOTAL <> 0 THEN
        V_PERC := ROUND(V_CALC_DIFAL / V_TOTAL, 6);
    ELSE
        V_PERC := 0;
    END IF;

    RETURN V_PERC;
END;
