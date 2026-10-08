/*==============================================================================
  Nome do Script : F_WMS_QTDVOLPAD2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Variacao de F_WMS_QTDVOLPAD que considera o controle (lote)
                  e arredonda em 4 casas.
  Assinatura     : F_WMS_QTDVOLPAD2 ( P_CODPROD NUMBER, P_CONTROLE VARCHAR,
                  P_QTD IN FLOAT, P_VOLQTD VARCHAR, P_VOLPAD VARCHAR) RETURN
                  FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_WMS_QTDVOLPAD2', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_WMS_QTDVOLPAD2 (
  P_CODPROD NUMBER,
  P_CONTROLE VARCHAR,
  P_QTD IN FLOAT,
  P_VOLQTD VARCHAR,
  P_VOLPAD VARCHAR) RETURN FLOAT
IS 
  L_DIVMUL VARCHAR(1);
  L_QUANTIDADE FLOAT;
BEGIN
  IF P_VOLQTD <> P_VOLPAD THEN
      L_DIVMUL := 0;
      L_QUANTIDADE := 0;
      
      SELECT MAX(DIVIDEMULTIPLICA),MAX(QUANTIDADE) INTO L_DIVMUL, L_QUANTIDADE FROM TGFVOA WHERE CODPROD = P_CODPROD AND CODVOL = P_VOLQTD AND CONTROLE = P_CONTROLE;
      
            IF L_DIVMUL = 'D' THEN
                RETURN ROUND(P_QTD / L_QUANTIDADE, 4);
            ELSE
                RETURN ROUND(P_QTD * L_QUANTIDADE, 4);
            END IF;
  END IF;
  RETURN P_QTD;
EXCEPTION
   WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20101, 'Unidade alternativa '|| P_VOLQTD || ' n¿o encontrada para o produto ' || P_CODPROD);
END;
