/*==============================================================================
  Nome do Script : SNK_GET_BASEFINESTOQUERENEGGOL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula recursivamente a base de multa/juros/ISS retido de um titulo
                  renegociado (TGFREN) para calculo de estoque em renegociacao.
  Assinatura     : SNK_GET_BASEFINESTOQUERENEGGOL (P_NUFIN NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_BASEFINESTOQUERENEGGOL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_BASEFINESTOQUERENEGGOL (P_NUFIN NUMBER) 
RETURN FLOAT 
AS
   P_BASE               FLOAT;
   P_VLRDESDOB          FLOAT;
   P_NURENEG            NUMBER(10);
   P_NURENEG_ORIG       NUMBER(10);
   P_RECDESP            NUMBER(10);
   P_NUFINRENEG         NUMBER(10);
   P_NUFINRENEG_ORIG    NUMBER(10);
   P_ORIGEM_FIN         CHAR(1);

  CURSOR CUR_FIN_RENEG IS     
   SELECT REN.NUFIN,
          REN.NURENEGORIG     
     FROM TGFREN REN    
    WHERE REN.NURENEG = P_NURENEG;

  CURSOR CUR_FIN_RENEG_ORIG IS     
    SELECT REN.NUFIN
      FROM TGFREN REN    
     WHERE REN.NURENEG = P_NURENEG_ORIG;

BEGIN
  
  SELECT FIN.NURENEG,
         FIN.VLRDESDOB + FIN.VLRIRF + FIN.VLRINSS + CASE WHEN FIN.ISSRETIDO = 'S' THEN FIN.VLRISS ELSE 0 END,
         FIN.RECDESP,
         CASE WHEN (FIN.ORIGEM = 'F' OR (FIN.ORIGEM = 'E' AND FIN.DESDOBDUPL = 'F')) THEN 'S' ELSE 'N' END
  INTO   P_NURENEG, P_VLRDESDOB, P_RECDESP, P_ORIGEM_FIN
  FROM TGFFIN FIN
  WHERE FIN.NUFIN = P_NUFIN;
  
  IF NVL(P_NURENEG, 0) = 0 THEN
    RETURN 0.0;
  END IF;
 
  P_BASE := 0.0;
  
  IF P_RECDESP <> 0 THEN
    P_NURENEG := P_NURENEG * P_RECDESP;
  END IF;
  
  IF P_RECDESP = 0 AND P_ORIGEM_FIN = 'N' THEN
    P_BASE := P_BASE + P_VLRDESDOB;
  END IF;
  
  OPEN CUR_FIN_RENEG;    
  LOOP
    FETCH CUR_FIN_RENEG INTO P_NUFINRENEG, P_NURENEG_ORIG; 
    EXIT WHEN CUR_FIN_RENEG%NOTFOUND;
    IF (P_NURENEG < 0) THEN        
      P_NURENEG_ORIG := P_NURENEG_ORIG * -1;
    END IF;

    IF (P_RECDESP <> 0) THEN
      P_BASE := P_BASE + SNK_GET_BASEFINESTOQUERENEGGOL(P_NUFINRENEG);
    ELSE
      OPEN CUR_FIN_RENEG_ORIG;
      LOOP  
        FETCH CUR_FIN_RENEG_ORIG INTO P_NUFINRENEG_ORIG;
        EXIT WHEN CUR_FIN_RENEG_ORIG%NOTFOUND;

        P_BASE := P_BASE + SNK_GET_BASEFINESTOQUERENEGGOL(P_NUFINRENEG_ORIG);
      END LOOP;
      CLOSE CUR_FIN_RENEG_ORIG;    
    END IF;
  END LOOP;     
  CLOSE CUR_FIN_RENEG;    

  RETURN P_BASE;

END;

 
