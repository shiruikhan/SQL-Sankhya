/*==============================================================================
  Nome do Script : SNK_GET_SATUSCONFERENCIA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina o status de conferencia de expedicao de uma nota (aguardando
                  conferencia, conferido, recontagem etc.).
  Assinatura     : SNK_GET_SATUSCONFERENCIA (P_NUNOTA NUMBER)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_SATUSCONFERENCIA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_SATUSCONFERENCIA (P_NUNOTA NUMBER)
RETURN VARCHAR2
AS
  P_COUNT INT;
  P_STATUS VARCHAR2(2);
  P_NUCONFATUAL TGFCAB.NUCONFATUAL%TYPE;
  P_NUCCO TGFCCO.NUCCO%TYPE;
  P_NUCONFORIG TGFCON2.NUCONFORIG%TYPE;
  P_MOMCONF TGFCCO.MOMENTOCONFERENCIA%TYPE;
  P_MULTENTREGAS TGFCCO.MULTENTREGAS%TYPE;
  P_STATUSNOTA TGFCAB.STATUSNOTA%TYPE;
  P_LIBCONF TGFCAB.LIBCONF%TYPE;
BEGIN

  SELECT MAX(NUCONFATUAL), MAX(NUCCO), MAX(STATUSNOTA), MAX(LIBCONF)
  INTO P_NUCONFATUAL, P_NUCCO, P_STATUSNOTA, P_LIBCONF
  FROM TGFCAB CAB
  , TGFTOP TPO
  WHERE NUNOTA = P_NUNOTA
  AND TPO.CODTIPOPER = CAB.CODTIPOPER
  AND TPO.DHALTER = CAB.DHTIPOPER;

  SELECT MAX(MOMENTOCONFERENCIA), MAX(MULTENTREGAS)
  INTO P_MOMCONF, P_MULTENTREGAS
  FROM TGFCCO
  WHERE NUCCO = P_NUCCO;

  IF P_NUCONFATUAL IS NULL THEN
  
    SELECT COUNT(1)
    INTO P_COUNT
    FROM TGFITE ITE
    WHERE ITE.NUNOTA = P_NUNOTA
    AND (ITE.PENDENTE = 'S' OR EXISTS (SELECT 1 FROM TGFCAB CB1 WHERE CB1.NUNOTA = ITE.NUNOTA AND CB1.TIPMOV IN ('V', 'C', 'D', 'E', 'T')))
    AND EXISTS (SELECT 1 FROM TGFPRO PROD WHERE (PROD.EXCLUIRCONF IS NULL OR PROD.EXCLUIRCONF = 'N') AND PROD.CODPROD = ITE.CODPROD);
    
    IF (P_NUCCO IS NOT NULL AND P_COUNT > 0) THEN --se temos configura??o de conferencia na Top ? por que essa nota pode fazer parte de conferencia
      IF ((P_STATUSNOTA = 'L' AND 
           P_MOMCONF = 'F') OR 
          (P_LIBCONF = 'S' AND 
           P_MOMCONF = 'C'))
      THEN
        P_STATUS := 'AC';
      ELSE
        P_STATUS := 'AL';
      END IF;
    END IF;
  ELSE
    SELECT MAX(STATUS), MAX(NVL(NUCONFORIG,0))
    INTO P_STATUS, P_NUCONFORIG
    FROM TGFCON2
    WHERE NUCONF = P_NUCONFATUAL;
    
    --Se n?o est? marcado como recontagem e n?o est? aguardando libera??o, verificamos se ? uma recontagem
    IF ('-C-R-Z-' NOT LIKE '-'||P_STATUS||'-' AND P_NUCONFORIG <> 0) THEN
      P_STATUS := 'R' || P_STATUS; --indica que ? recontagem
    END IF;

    IF (P_STATUSNOTA = 'L' AND 
        (P_STATUS = 'F' OR 
         P_STATUS = 'RF'))
    THEN
      if (P_NUCCO IS NOT NULL AND
          P_STATUS = 'F' AND 
          P_MULTENTREGAS = 'S' AND 
          P_LIBCONF = 'S')
      THEN
        P_STATUS := 'AC';
      END IF;
    END IF;
  END IF;
  RETURN P_STATUS;
END;
