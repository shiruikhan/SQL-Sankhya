/*==============================================================================
  Nome do Script : TRG_INC_UPD_DLT_TGFITE_ESE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW INSERT OR UPDATE OR DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_INC_UPD_DLT_TGFITE_ESE', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFITE_ESE" 
  AFTER INSERT OR UPDATE OR DELETE
  ON TGFITE   FOR EACH ROW
 WHEN (
((OLD.RESERVA = 'N' AND (OLD.ATUALESTOQUE <> 0 OR NVL(OLD.ATUALESTTERC, 'N') <> 'N')) OR 
 (NEW.RESERVA = 'N' AND (NEW.ATUALESTOQUE <> 0 OR NVL(NEW.ATUALESTTERC, 'N') <> 'N'))) 
        AND (   NVL (NEW.ATUALESTOQUE, 0) <> NVL (OLD.ATUALESTOQUE, 0)
             OR NVL (NEW.ATUALESTTERC, 'N') <> NVL (OLD.ATUALESTTERC, 'N')
             OR NVL (NEW.RESERVA, 'N') <> NVL (OLD.RESERVA, 'N')
             OR NVL (NEW.QTDNEG, 0) <> NVL (OLD.QTDNEG, 0)
             OR NVL (NEW.CODEMP, 0) <> NVL (OLD.CODEMP, 0)
             OR NVL (NEW.CODPROD, 0) <> NVL (OLD.CODPROD, 0)
             OR NVL (NEW.CODLOCALORIG, 0) <> NVL (OLD.CODLOCALORIG, 0)
             OR NVL (NEW.CONTROLE, ' ') <> NVL (OLD.CONTROLE, ' ')
            )
      ) DECLARE
  P_TIPMOV         TGFCAB.TIPMOV%TYPE;
  P_CODTIPOPER     TGFCAB.CODTIPOPER%TYPE;
  P_DHTIPOPER      TGFCAB.DHTIPOPER%TYPE;
  P_DTREFERENCIA   TGFCAB.DTENTSAI%TYPE;
  P_CODEMP         TGFCAB.CODEMP%TYPE;
  P_CODEMPNEGOC    TGFCAB.CODEMPNEGOC%TYPE;
  P_CODEMPCONTPART TGFCAB.CODEMP%TYPE;
  P_NUNOTA         TGFCAB.NUNOTA%TYPE;
  P_TIPO           CHAR (12);
BEGIN

----------------------------------------------------------------------------------
--BUSCANDO DADOS DO CABECALHO
----------------------------------------------------------------------------------
  P_NUNOTA := CASE
               WHEN DELETING THEN :OLD.NUNOTA
               ELSE :NEW.NUNOTA
             END;

  BEGIN
    SELECT C.TIPMOV, C.CODTIPOPER, C.DHTIPOPER, C.CODEMP, C.CODEMPNEGOC
         , TRUNC (CASE
                    WHEN T.ATUALLIVFIS IN ('S','A') OR T.CUPOMFISCAL = 'S' OR C.DTENTSAI IS NULL THEN C.DTNEG
                    ELSE C.DTENTSAI
                  END) AS DTREFERENCIA
      INTO P_TIPMOV, P_CODTIPOPER, P_DHTIPOPER, P_CODEMP, P_CODEMPNEGOC
         , P_DTREFERENCIA
      FROM TGFCAB C, TGFTOP T
     WHERE C.NUNOTA = P_NUNOTA
       AND C.CODTIPOPER = T.CODTIPOPER
       AND C.DHTIPOPER = T.DHALTER;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT C.TIPMOV, C.CODTIPOPER, C.DHTIPOPER, C.CODEMP, C.CODEMPNEGOC
             , TRUNC (CASE
WHEN T.ATUALLIVFIS IN ('S','A') OR T.CUPOMFISCAL = 'S' OR C.DTENTSAI IS NULL THEN C.DTNEG
ELSE C.DTENTSAI
                      END) AS DTREFERENCIA
          INTO P_TIPMOV, P_CODTIPOPER, P_DHTIPOPER, P_CODEMP, P_CODEMPNEGOC
             , P_DTREFERENCIA
          FROM TGFCAB_DLT C, TGFTOP T
         WHERE C.NUNOTA = P_NUNOTA
           AND C.CODTIPOPER = T.CODTIPOPER
           AND C.DHTIPOPER = T.DHALTER;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE;
      END;
  END;

----------------------------------------------------------------------------------
--AJUSTANDO O OLD
----------------------------------------------------------------------------------
  IF (DELETING OR UPDATING) AND :OLD.RESERVA = 'N' AND (:OLD.ATUALESTOQUE <> 0 OR NVL(:OLD.ATUALESTTERC, 'N') <> 'N') THEN
    P_CODEMPCONTPART := CASE WHEN P_TIPMOV = 'T' AND P_CODEMP <> P_CODEMPNEGOC THEN 0 ELSE :OLD.CODEMP END;
    MERGE INTO TGFESE E
USING (SELECT NVL(:OLD.ATUALESTTERC, 'N') AS ATUALESTTERC
  FROM DUAL) T
      ON (    E.DTREFERENCIA = P_DTREFERENCIA                         ---------------------------------------------------------------
          AND E.TIPMOV = P_TIPMOV                                      -- ESTE ON TEM QUE SER A PK INTEIRA DA TABELA
          AND E.CODTIPOPER = P_CODTIPOPER                             ---------------------------------------------------------------
          AND E.CODEMP = :OLD.CODEMP
          AND E.CODPROD = :OLD.CODPROD
          AND E.CODLOCALORIG = :OLD.CODLOCALORIG
          AND E.CONTROLE = :OLD.CONTROLE
          AND E.ATUALESTOQUE = :OLD.ATUALESTOQUE
          AND E.ATUALESTTERC = T.ATUALESTTERC
          AND E.CODEMPCONTPART = P_CODEMPCONTPART)
      WHEN MATCHED THEN
        UPDATE
           SET QTDNEG = NVL(QTDNEG, 0) - :OLD.QTDNEG
      WHEN NOT MATCHED THEN
        INSERT (DTREFERENCIA, CODTIPOPER, TIPMOV, CONTROLE, CODLOCALORIG
              , CODPROD, CODEMP, ATUALESTOQUE, ATUALESTTERC, QTDENTRADAS
              , QTDSAIDAS, QTDNEG, CODEMPCONTPART)
        VALUES (P_DTREFERENCIA, P_CODTIPOPER, P_TIPMOV, :OLD.CONTROLE
              , :OLD.CODLOCALORIG, :OLD.CODPROD, :OLD.CODEMP, :OLD.ATUALESTOQUE
              , T.ATUALESTTERC, 0, 0, :OLD.QTDNEG * -1
              , P_CODEMPCONTPART);

    DELETE FROM TGFESE E
          WHERE E.DTREFERENCIA = P_DTREFERENCIA
            AND E.CODTIPOPER = P_CODTIPOPER
            AND E.TIPMOV = P_TIPMOV
            AND E.CODEMP = :OLD.CODEMP
            AND E.CODPROD = :OLD.CODPROD
            AND E.CODLOCALORIG = :OLD.CODLOCALORIG
            AND E.CONTROLE = :OLD.CONTROLE
            AND E.ATUALESTOQUE = :OLD.ATUALESTOQUE
            AND E.ATUALESTTERC = NVL(:OLD.ATUALESTTERC, 'N')
            AND E.CODEMPCONTPART = P_CODEMPCONTPART
            AND E.QTDNEG = 0;
  END IF;

----------------------------------------------------------------------------------
--AJUSTANDO O NEW
----------------------------------------------------------------------------------
  IF (INSERTING OR UPDATING) AND :NEW.RESERVA = 'N' AND (:NEW.ATUALESTOQUE <> 0 OR NVL(:NEW.ATUALESTTERC, 'N') <> 'N') THEN
    P_CODEMPCONTPART := CASE WHEN P_TIPMOV = 'T' AND P_CODEMP <> P_CODEMPNEGOC THEN 0 ELSE :NEW.CODEMP END;
    MERGE INTO TGFESE E
USING (SELECT NVL(:NEW.ATUALESTTERC, 'N') AS ATUALESTTERC
  FROM DUAL) T
      ON (    E.DTREFERENCIA = P_DTREFERENCIA                         ---------------------------------------------------------------
          AND E.TIPMOV = P_TIPMOV                                      -- ESTE ON TEM QUE SER A PK INTEIRA DA TABELA
          AND E.CODTIPOPER = P_CODTIPOPER                             ---------------------------------------------------------------
          AND E.CODEMP = :NEW.CODEMP
          AND E.CODPROD = :NEW.CODPROD
          AND E.CODLOCALORIG = :NEW.CODLOCALORIG
          AND E.CONTROLE = :NEW.CONTROLE
          AND E.ATUALESTOQUE = :NEW.ATUALESTOQUE
          AND E.ATUALESTTERC = T.ATUALESTTERC
          AND E.CODEMPCONTPART = P_CODEMPCONTPART)
      WHEN MATCHED THEN
        UPDATE
           SET QTDNEG = NVL(QTDNEG, 0) + :NEW.QTDNEG
      WHEN NOT MATCHED THEN
        INSERT (DTREFERENCIA, CODTIPOPER, TIPMOV, CONTROLE, CODLOCALORIG
              , CODPROD, CODEMP, ATUALESTOQUE, ATUALESTTERC, QTDENTRADAS
              , QTDSAIDAS, QTDNEG, CODEMPCONTPART)
        VALUES (P_DTREFERENCIA, P_CODTIPOPER, P_TIPMOV, :NEW.CONTROLE
              , :NEW.CODLOCALORIG, :NEW.CODPROD, :NEW.CODEMP, :NEW.ATUALESTOQUE
              , T.ATUALESTTERC, 0, 0, :NEW.QTDNEG
              , P_CODEMPCONTPART);

    DELETE FROM TGFESE E
          WHERE E.DTREFERENCIA = P_DTREFERENCIA
            AND E.CODTIPOPER = P_CODTIPOPER
            AND E.TIPMOV = P_TIPMOV
            AND E.CODEMP = :NEW.CODEMP
            AND E.CODPROD = :NEW.CODPROD
            AND E.CODLOCALORIG = :NEW.CODLOCALORIG
            AND E.CONTROLE = :NEW.CONTROLE
            AND E.ATUALESTOQUE = :NEW.ATUALESTOQUE
            AND E.ATUALESTTERC = NVL(:NEW.ATUALESTTERC, 'N')
            AND E.CODEMPCONTPART = P_CODEMPCONTPART
            AND E.QTDNEG = 0;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFITE_ESE" ENABLE;
