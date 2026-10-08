/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_EST
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 13/01/2023)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 13/01/2023, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_EST', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_EST" 
   AFTER UPDATE
   ON TGFCAB    FOR EACH ROW
 WHEN (
              ( OLD.CODTIPOPER <> NEW.CODTIPOPER ) 
         OR TRUNC( NVL( OLD.DTENTSAI, OLD.DTNEG ) ) <> TRUNC( NVL( NEW.DTENTSAI, NEW.DTNEG ) )
         OR (  NEW.TIPMOV = 'T' AND 
                 ( OLD.CODEMP <> OLD.CODEMPNEGOC OR NEW.CODEMP <> NEW.CODEMPNEGOC ) AND
                 ( OLD.CODEMP <> NEW.CODEMP OR OLD.CODEMPNEGOC <> NEW.CODEMPNEGOC ) )
      ) DECLARE
   OLD_ATUALLIVFIS   TGFTOP.ATUALLIVFIS%TYPE;
   NEW_ATUALLIVFIS   TGFTOP.ATUALLIVFIS%TYPE;
   OLD_CUPOMFISCAL   TGFTOP.CUPOMFISCAL%TYPE;
   NEW_CUPOMFISCAL   TGFTOP.CUPOMFISCAL%TYPE;
   OLD_DT TGFCAB.DTNEG%TYPE;
   NEW_DT TGFCAB.DTNEG%TYPE;
BEGIN
  
    IF STP_GET_ATUALIZANDO THEN 
      RETURN;
    END IF;
  
    BEGIN
        SELECT ATUALLIVFIS
             ,CUPOMFISCAL
         INTO OLD_ATUALLIVFIS
             ,OLD_CUPOMFISCAL
         FROM TGFTOP T
        WHERE T.CODTIPOPER = :OLD.CODTIPOPER
          AND DHALTER = :OLD.DHTIPOPER;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20101, 'Não foi encontrada a TOP ' || TO_CHAR(:OLD.CODTIPOPER) || ' com data de alteração igual a ' || TO_CHAR(:OLD.DHTIPOPER) || '. Nota de Nro único: '|| TO_CHAR(:NEW.NUNOTA) ||'.');
    END;      

    BEGIN
        SELECT ATUALLIVFIS
             ,CUPOMFISCAL
         INTO NEW_ATUALLIVFIS
             ,NEW_CUPOMFISCAL
         FROM TGFTOP T
        WHERE T.CODTIPOPER = :NEW.CODTIPOPER
          AND DHALTER = :NEW.DHTIPOPER;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20101, 'Não foi encontrada a TOP ' || TO_CHAR(:NEW.CODTIPOPER) || ' com data de alteração igual a ' || TO_CHAR(:NEW.DHTIPOPER) || '. Nota de Nro único: '|| TO_CHAR(:NEW.NUNOTA) ||'.');
    END;       

   OLD_DT := TRUNC( CASE
                                   WHEN OLD_ATUALLIVFIS IN ('S','A') OR OLD_CUPOMFISCAL = 'S' OR :OLD.DTENTSAI IS NULL THEN :OLD.DTNEG
                                   ELSE :OLD.DTENTSAI
                                END );
   NEW_DT := TRUNC( CASE
                                   WHEN NEW_ATUALLIVFIS IN ('S','A') OR NEW_CUPOMFISCAL = 'S' OR :NEW.DTENTSAI IS NULL THEN :NEW.DTNEG
                                   ELSE :NEW.DTENTSAI
                                END );

   VARIAVEIS_PKG.V_ALTERADO_PELA_CAB    := TRUE;
   BEGIN
      --TRATANDO A LINHA ANTIGA
      MERGE INTO TGFESE E
         USING (  SELECT  OLD_DT AS DTREFERENCIA
                                , :OLD.TIPMOV AS TIPMOV
                                , :OLD.CODTIPOPER AS CODTIPOPER
                                , CONTROLE
                                , CODPROD
                                , CODLOCALORIG 
                                , CODEMP 
                                , CASE WHEN :OLD.TIPMOV = 'T' AND :OLD.CODEMP <> :OLD.CODEMPNEGOC THEN 0 ELSE CODEMP END  AS CODEMPCONTPART
                                , ATUALESTOQUE 
                                , NVL( ATUALESTTERC, 'N' ) AS ATUALESTTERC
                                , SUM(QTDNEG) AS QTDNEG
                            FROM TGFITE
                           WHERE RESERVA = 'N'
                             AND (ATUALESTOQUE <> 0 OR NVL( ATUALESTTERC, 'N' ) <> 'N')
                             AND NUNOTA = :OLD.NUNOTA
                  GROUP BY CONTROLE
                                , CODPROD
                                , CODLOCALORIG 
                                , CODEMP 
                                , CASE WHEN :OLD.TIPMOV = 'T' AND :OLD.CODEMP <> :OLD.CODEMPNEGOC THEN 0 ELSE CODEMP END    
                                , ATUALESTOQUE 
                                , NVL( ATUALESTTERC, 'N' )  
                         ) I
         ON (    E.DTREFERENCIA = I.DTREFERENCIA     ---------------------------------------------------
             AND E.TIPMOV = I.TIPMOV                         -- ESTE ON TEM QUE SER A PK INTEIRA DA TABELA
             AND E.CODTIPOPER = I.CODTIPOPER          ----------------------------------------------------
             AND E.CONTROLE = I.CONTROLE
             AND E.CODPROD = I.CODPROD
             AND E.CODLOCALORIG = I.CODLOCALORIG
             AND E.CODEMP = I.CODEMP
             AND E.CODEMPCONTPART = I.CODEMPCONTPART
             AND E.ATUALESTOQUE = I.ATUALESTOQUE
             AND E.ATUALESTTERC = I.ATUALESTTERC)
                       
         WHEN MATCHED THEN
            UPDATE
               SET E.QTDNEG = E.QTDNEG - I.QTDNEG
         WHEN NOT MATCHED THEN
            INSERT( DTREFERENCIA, CODTIPOPER, TIPMOV, QTDENTRADAS, QTDSAIDAS
                   , CONTROLE, CODLOCALORIG, CODPROD
                   , CODEMP, CODEMPCONTPART,ATUALESTOQUE, ATUALESTTERC
                   , QTDNEG )
            VALUES( I.DTREFERENCIA, :OLD.CODTIPOPER, :OLD.TIPMOV, 0, 0
                   , I.CONTROLE, I.CODLOCALORIG, I.CODPROD
                   ,I.CODEMP, I.CODEMPCONTPART, I.ATUALESTOQUE, I.ATUALESTTERC
                   ,I.QTDNEG * - 1);

        DELETE FROM TGFESE E
        WHERE E.DTREFERENCIA = OLD_DT
        AND E.CODTIPOPER = :OLD.CODTIPOPER
        AND E.TIPMOV = :OLD.TIPMOV
        AND E.QTDNEG = 0;

      --TRATANDO A NOVA LINHA
      MERGE INTO TGFESE E
         USING ( SELECT  NEW_DT AS DTREFERENCIA
                                , :NEW.TIPMOV AS TIPMOV 
                                , :NEW.CODTIPOPER AS CODTIPOPER 
                                , CONTROLE, CODPROD, CODLOCALORIG 
                                , CODEMP 
                                , CASE WHEN :NEW.TIPMOV = 'T' AND :NEW.CODEMP <> :NEW.CODEMPNEGOC THEN 0 ELSE CODEMP END AS CODEMPCONTPART
                                , ATUALESTOQUE 
                                , NVL( ATUALESTTERC, 'N' ) AS ATUALESTTERC
                                , SUM(QTDNEG) AS QTDNEG
                            FROM TGFITE 
                           WHERE RESERVA = 'N'
                             AND (ATUALESTOQUE <> 0 OR NVL( ATUALESTTERC, 'N' ) <> 'N')
                             AND NUNOTA = :NEW.NUNOTA
                  GROUP BY CONTROLE, CODPROD, CODLOCALORIG 
                                , CODEMP 
                                , CASE WHEN :NEW.TIPMOV = 'T' AND :NEW.CODEMP <> :NEW.CODEMPNEGOC THEN 0 ELSE CODEMP END 
                                , ATUALESTOQUE 
                                , NVL( ATUALESTTERC, 'N' ) 
                         ) I
         ON (    E.DTREFERENCIA = I.DTREFERENCIA             ----------------------------------------------------
             AND E.TIPMOV = I.TIPMOV                         -- ESTE ON TEM QUE SER A PK INTEIRA DA TABELA
             AND E.CODTIPOPER = I.CODTIPOPER                 ----------------------------------------------------
             AND E.CONTROLE = I.CONTROLE
             AND E.CODLOCALORIG = I.CODLOCALORIG
             AND E.CODPROD = I.CODPROD
             AND E.CODEMP = I.CODEMP
             AND E.CODEMPCONTPART = I.CODEMPCONTPART
             AND E.ATUALESTOQUE = I.ATUALESTOQUE
             AND E.ATUALESTTERC = I.ATUALESTTERC)
             
         WHEN MATCHED THEN
            UPDATE
               SET E.QTDNEG = E.QTDNEG + I.QTDNEG
         WHEN NOT MATCHED THEN
            INSERT( DTREFERENCIA, CODTIPOPER, TIPMOV, QTDENTRADAS, QTDSAIDAS
                   , CONTROLE, CODLOCALORIG, CODPROD
                   , CODEMP, CODEMPCONTPART,ATUALESTOQUE, ATUALESTTERC
                   , QTDNEG )
            VALUES( I.DTREFERENCIA, :NEW.CODTIPOPER, :NEW.TIPMOV, 0, 0
                   , I.CONTROLE, I.CODLOCALORIG, I.CODPROD
                   ,I.CODEMP, I.CODEMPCONTPART, I.ATUALESTOQUE, I.ATUALESTTERC
                   ,I.QTDNEG );

      DELETE FROM TGFESE E
            WHERE E.DTREFERENCIA = NEW_DT
              AND E.QTDNEG = 0;
   EXCEPTION
      WHEN OTHERS THEN
         VARIAVEIS_PKG.V_ALTERADO_PELA_CAB    := FALSE;
         RAISE;
   END;

   VARIAVEIS_PKG.V_ALTERADO_PELA_CAB    := FALSE;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_EST" ENABLE;
