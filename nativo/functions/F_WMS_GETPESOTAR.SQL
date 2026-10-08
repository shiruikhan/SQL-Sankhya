/*==============================================================================
  Nome do Script : F_WMS_GETPESOTAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o peso de uma tarefa WMS (peso do produto x
                  quantidade, ajustado pela conversao de volume).
  Assinatura     : F_WMS_GETPESOTAR ( P_PESOPROD IN FLOAT, P_QTD IN FLOAT,
                  P_VOA_DIVMULT IN VARCHAR, P_VOA_QTD IN FLOAT) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_WMS_GETPESOTAR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_WMS_GETPESOTAR (
  P_PESOPROD IN FLOAT,
  P_QTD IN FLOAT,
  P_VOA_DIVMULT IN VARCHAR,
  P_VOA_QTD IN FLOAT) RETURN FLOAT
IS 
  L_PESOTOT FLOAT;
BEGIN
  L_PESOTOT := (P_PESOPROD * P_QTD);  
  IF P_VOA_QTD IS NOT NULL THEN
      IF P_VOA_DIVMULT = 'D' THEN
          L_PESOTOT := L_PESOTOT / P_VOA_QTD;
      ELSE
          L_PESOTOT := L_PESOTOT * P_VOA_QTD;
      END IF;
  END IF;
  RETURN L_PESOTOT;
END;
