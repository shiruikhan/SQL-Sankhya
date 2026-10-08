/*==============================================================================
  Nome do Script : STP_ATUALIZA_TGFEST
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Atualiza o saldo de TGFEST (ESTOQUE ou RESERVADO) de um produto/local/controle, criando a linha se não existir; valida estoque insuficiente (Stp_Valida_Estoque312) conforme VALEST do grupo. Chamada por TRG_INC_TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 03/07/2024, última alteração em 29/05/2026.
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('PROCEDURE', 'STP_ATUALIZA_TGFEST', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_ATUALIZA_TGFEST" (
   P_RESERVADO      CHAR,
   P_ATUALESTOQUE   INT,
   P_CODEMP         INT,
   P_CODPROD        INT,
   P_CONTROLE       VARCHAR2 ,
   P_CODLOCALORIG   INT,
   P_QTDNEG         FLOAT,
   P_STATUSLOTE     VARCHAR2,
   P_ATUALIZOU      OUT CHAR )
AS
  P_CONT   INT := 0;
  P_CONT1  INT := 0;
  P_CONTROLEx   TGFEST.CONTROLE%TYPE; --VARCHAR2(12);
  P_VALEST        TGFGRU.VALEST%TYPE := 'N';
  P_QUANTEST        FLOAT;
  P_DTVAL        TGFEST.DTVAL%TYPE;
  P_DTFABRICACAO TGFEST.DTFABRICACAO%TYPE;
  P_CODBARRA     TGFEST.CODBARRA%TYPE;
BEGIN
  P_ATUALIZOU := 'S';
  P_CONTROLEx := NVL(P_CONTROLE, ' ') ;
  IF  ((P_RESERVADO = 'S') AND (P_QTDNEG <= 0)) OR (P_QTDNEG = 0)  THEN
     RETURN ;
  END IF;

  SELECT COUNT(1) INTO P_CONT FROM TGFPRO WHERE CODPROD = P_CODPROD AND USOPROD = 'S';
  IF (P_CONT <> 0) THEN
    SELECT COUNT(1) INTO P_CONT1 FROM TSIPAR WHERE CHAVE = 'ATUALESTSERV' AND LOGICO = 'N';
    IF (P_CONT1 <> 0) THEN
      RETURN;
    END IF;
  END IF;
  SELECT  COUNT(1) INTO P_CONT
  FROM TGFEST
  WHERE CODEMP = P_CODEMP
    AND CODPROD = P_CODPROD
    AND CONTROLE = P_CONTROLEX
    AND CODLOCAL = P_CODLOCALORIG
    AND CODPARC = 0;

  IF P_CONT = 0 THEN
    SELECT MIN(DTVAL), MIN(DTFABRICACAO), MIN(CODBARRA)
      INTO P_DTVAL, P_DTFABRICACAO, P_CODBARRA
    FROM TGFEST
    WHERE CODPROD = P_CODPROD
      AND CONTROLE = P_CONTROLEX
      AND (DTVAL IS NOT NULL OR DTFABRICACAO IS NOT NULL OR CODBARRA IS NOT NULL);
    
    INSERT INTO TGFEST (CODEMP, CODLOCAL, CODPROD, CONTROLE, ESTOQUE, RESERVADO,CODPARC, STATUSLOTE, DTVAL, DTFABRICACAO, CODBARRA)
    VALUES (P_CODEMP, P_CODLOCALORIG, P_CODPROD, P_CONTROLEX, 0, 0, 0, NVL(P_STATUSLOTE,'N'), P_DTVAL, P_DTFABRICACAO, P_CODBARRA);
  END IF;    
    /* 
     Retirado o round para nao dar problema em relacao a quantidade de casas da tgfite ser maior que 4.
     No sqlserver o round deve continuar para nao causar erros de dizimas
    */
    
   
    
  SELECT GRU.VALEST 
  INTO P_VALEST
  FROM TGFPRO PRO,
       TGFGRU GRU
  WHERE PRO.CODPROD  = P_CODPROD
  AND PRO.CODGRUPOPROD = GRU.CODGRUPOPROD;
          
  IF (VARIAVEIS_PKG.V_VALIDA_EST_GRUPROD) AND ((P_VALEST = 'G') OR (P_VALEST = 'S') OR (P_VALEST = 'E') OR (P_VALEST = 'L')) AND ((P_ATUALESTOQUE = -1 AND P_RESERVADO = 'N') OR (P_ATUALESTOQUE = 1 AND P_RESERVADO = 'S')) THEN 
      Stp_Valida_Estoque312(P_CODEMP, P_CODLOCALORIG, P_CONTROLE, P_CODPROD, NVL(P_STATUSLOTE,'N'), P_QUANTEST, P_VALEST );
      
      IF ((P_QUANTEST - P_QTDNEG) < 0) THEN
          RAISE_APPLICATION_ERROR(-20101, 'Estoque insuficiente!.'|| CHR(13) ||
            'Qtd: ' || TO_CHAR(P_QUANTEST) || CHR(13) ||
            'Prod: ' || TO_CHAR(P_CODPROD) || CHR(13) ||
            'Emp: ' ||  TO_CHAR(P_CODEMP) || CHR(13) ||
            'Local: '  ||  TO_CHAR(P_CODLOCALORIG) || CHR(13) ||
            'Controle: ' || P_CONTROLE || CHR(13) ||'St.Lote : ' || P_STATUSLOTE);
      END IF;
  END IF;

    
    
  IF (P_RESERVADO = 'S')  THEN
    /* VAI CHAMAR O UPDATE DO ESTOQUE  */
    UPDATE TGFEST SET
      RESERVADO = RESERVADO + (P_QTDNEG * P_ATUALESTOQUE)
    WHERE CODEMP   = P_CODEMP
      AND CODPROD  = P_CODPROD
      AND CONTROLE = P_CONTROLEX
      AND CODLOCAL = P_CODLOCALORIG
      AND CODPARC = 0;
    /*  CHAMOU O UPDATE DO ESTOQUE   */
  ELSE
    UPDATE TGFEST SET
      ESTOQUE = ESTOQUE + (P_QTDNEG * P_ATUALESTOQUE)
    WHERE CODEMP   = P_CODEMP
      AND CODPROD  = P_CODPROD
      AND CONTROLE = P_CONTROLEX
      AND CODLOCAL = P_CODLOCALORIG
      AND CODPARC = 0;
  END IF;
  IF SQL%ROWCOUNT = 0  THEN
    P_ATUALIZOU := 'N';
  END IF;
END;
