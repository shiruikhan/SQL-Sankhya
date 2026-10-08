/*==============================================================================
  Nome do Script : VOLUMEALT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Converte quantidade entre volume padrao e volume alternativo
                  de um produto (TGFVOA), com fallback sem controle.
  Assinatura     : VOLUMEALT (P_CODMP IN NUMBER, P_QTD IN FLOAT, P_CODVOL
                  VARCHAR2, P_CONTROLE VARCHAR2, P_TIPO STRING DEFAULT 'SET' )
                  RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'VOLUMEALT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION VOLUMEALT (P_CODMP IN NUMBER, P_QTD IN FLOAT, P_CODVOL VARCHAR2, P_CONTROLE VARCHAR2, P_TIPO STRING DEFAULT 'SET' )
RETURN FLOAT
IS 
   P_CODVOLPRO  TGFPRO.CODVOL%TYPE;
   P_DECQTD     NUMBER;
   QTD          FLOAT;
   P_DIVIDEMULTIPLICA VARCHAR2(1);
   P_QUANTIDADE FLOAT;
BEGIN
  QTD := P_QTD; 

  SELECT CODVOL, DECQTD 
  INTO P_CODVOLPRO, P_DECQTD
  FROM TGFPRO
  WHERE CODPROD = P_CODMP;

  IF P_CODVOL <> P_CODVOLPRO THEN
    BEGIN
      SELECT DIVIDEMULTIPLICA, QUANTIDADE 
      INTO P_DIVIDEMULTIPLICA, P_QUANTIDADE 
      FROM TGFVOA 
      WHERE CODVOL = P_CODVOL 
      AND CODPROD = P_CODMP
      AND CONTROLE = P_CONTROLE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        IF P_CONTROLE <> ' ' THEN
          SELECT DIVIDEMULTIPLICA, QUANTIDADE 
          INTO P_DIVIDEMULTIPLICA, P_QUANTIDADE 
          FROM TGFVOA 
          WHERE CODVOL = P_CODVOL 
          AND CODPROD = P_CODMP
          AND CONTROLE = ' ';
        ELSE
          RETURN( QTD ); 
        END IF;
    END;    
	IF P_TIPO = 'SET' THEN
      IF P_DIVIDEMULTIPLICA = 'D' THEN
        QTD := ROUND(QTD / P_QUANTIDADE, P_DECQTD);
      ELSE
        QTD := ROUND(QTD * P_QUANTIDADE, P_DECQTD);
      END IF;
	ELSE
	  IF P_DIVIDEMULTIPLICA = 'D' THEN
        QTD := ROUND(QTD * P_QUANTIDADE, P_DECQTD);
      ELSE
        QTD := ROUND(QTD / P_QUANTIDADE, P_DECQTD);
      END IF;
	END IF;
	  
  END IF;
  RETURN( QTD );
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN (QTD);
END;
