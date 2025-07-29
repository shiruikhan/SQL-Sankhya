CREATE OR REPLACE TRIGGER SPARKPRD.TRG_INC_UPD_TPRROPE_PROD_SPARK
BEFORE INSERT OR UPDATE ON TPRROPE
FOR EACH ROW
DECLARE
  -- Variáveis auxiliares
  P_COUNT          INT;
  P_CODLOCALORIG   TGFITE.CODLOCALORIG%TYPE := 0;
  P_LOCAL          TGFLOC.DESCRLOCAL%TYPE;
  V_TIPOITENS      TPROEST.TIPOITENS%TYPE;
BEGIN
  ----------------------------------------------------------------------
  -- 1. Tenta obter o CODLOCALORIG padrão baseado no IDEFXBASE da operação
  ----------------------------------------------------------------------
  BEGIN
    SELECT E.CODLOCALORIG, E.TIPOITENS
      INTO P_CODLOCALORIG, V_TIPOITENS
      FROM TPROEST EST
      INNER JOIN TPROEST E ON E.IDEFX = EST.IDEFXBASE
     WHERE EST.IDEFX = :NEW.IDEFX
       AND EST.SEQOPER = :NEW.SEQOPER
       AND E.TIPOITENS = 'PA';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Caso não encontre, inicializa com 0 e tenta segunda estratégia
      P_CODLOCALORIG := 0;
      V_TIPOITENS := NULL;
    WHEN OTHERS THEN
      -- Evita falha total da trigger por erro inesperado
      P_CODLOCALORIG := 0;
      V_TIPOITENS := NULL;
  END;

  ----------------------------------------------------------------------
  -- 2. Se não encontrou CODLOCALORIG e TIPOITENS for 'MT', tenta obter pelo centro de custo
  ----------------------------------------------------------------------
  IF (P_CODLOCALORIG IS NULL OR P_CODLOCALORIG = 0) THEN
    BEGIN
      -- Busca o tipo de item do apontamento atual
      SELECT EST.TIPOITENS
        INTO V_TIPOITENS
        FROM TPROEST EST
       WHERE EST.IDEFX = :NEW.IDEFX
       FETCH FIRST 1 ROWS ONLY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_TIPOITENS := NULL;
      WHEN OTHERS THEN
        V_TIPOITENS := NULL;
    END;

    IF V_TIPOITENS = 'MT' THEN
      BEGIN
        -- Busca o código do local a partir do centro de custo
        SELECT C.AD_CODLOCAL
          INTO P_CODLOCALORIG
          FROM TPROEST EST
          LEFT JOIN TSICUS C ON EST.CODCENCUS = C.CODCENCUS
         WHERE EST.IDEFX = :NEW.IDEFX
           AND EST.TIPOITENS = 'MT'
         FETCH FIRST 1 ROWS ONLY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          P_CODLOCALORIG := 0;
        WHEN OTHERS THEN
          P_CODLOCALORIG := 0;
      END;
    END IF;
  END IF;

  ----------------------------------------------------------------------
  -- 3. Atualiza o local destino no pedido, se for nota de movimentação 'J' e local válido
  ----------------------------------------------------------------------
  BEGIN
    SELECT COUNT(*)
      INTO P_COUNT
      FROM TGFCAB
     WHERE NUNOTA = :NEW.NUNOTA
       AND TIPMOV = 'J';
  EXCEPTION
    WHEN OTHERS THEN
      P_COUNT := 0;
  END;

  IF P_COUNT = 1 AND P_CODLOCALORIG > 0 THEN
    BEGIN
      SELECT DESCRLOCAL
        INTO P_LOCAL
        FROM TGFLOC
       WHERE CODLOCAL = P_CODLOCALORIG;

      UPDATE TGFCAB
         SET AD_CODLOCALDEST = P_CODLOCALORIG,
             OBSERVACAO = 'Local Destino: ' || P_LOCAL
       WHERE NUNOTA = :NEW.NUNOTA;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; -- local não encontrado, não atualiza
      WHEN OTHERS THEN
        NULL; -- evita falha total da trigger
    END;
  END IF;

END;
