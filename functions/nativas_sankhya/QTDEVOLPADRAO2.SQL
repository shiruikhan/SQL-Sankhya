/*==============================================================================
  Nome do Script : QTDEVOLPADRAO2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Versao de QTDEVOLPADRAO que considera tambem o controle
                  (lote/serie) na conversao de volume.
  Assinatura     : QTDEVOLPADRAO2 (P_CODPRO NUMBER, P_QTD FLOAT, P_CODVOL
                  VARCHAR2, P_CONTROLE VARCHAR2) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'QTDEVOLPADRAO2', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION QTDEVOLPADRAO2 (P_CODPRO NUMBER, P_QTD FLOAT, P_CODVOL VARCHAR2, P_CONTROLE VARCHAR2)
  RETURN FLOAT
IS
  P_CODVOLPRO        TGFPRO.CODVOL%TYPE;
  P_DECQTD           NUMBER;
  QTD                FLOAT;
  P_DIVIDEMULTIPLICA VARCHAR2(1);
  P_QUANTIDADE       FLOAT;
  BEGIN
    QTD := P_QTD;

    SELECT CODVOL, DECQTD
        INTO P_CODVOLPRO, P_DECQTD FROM TGFPRO WHERE CODPROD = P_CODPRO;

    IF P_CODVOL <> P_CODVOLPRO
    THEN
      SELECT DIVIDEMULTIPLICA, QUANTIDADE
          INTO P_DIVIDEMULTIPLICA, P_QUANTIDADE
      FROM TGFVOA
      WHERE CODVOL = P_CODVOL
        AND CODPROD = P_CODPRO
        AND NVL(CONTROLE, ' ') = NVL(P_CONTROLE, ' ');

      IF P_DIVIDEMULTIPLICA = 'D'
      THEN
        QTD := ROUND(QTD / P_QUANTIDADE, P_DECQTD);
      ELSE
        QTD := ROUND(QTD * P_QUANTIDADE, P_DECQTD);
      END IF;
    END IF;
    RETURN (QTD);
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RETURN (QTD);
  END;
