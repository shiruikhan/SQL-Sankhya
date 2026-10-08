/*==============================================================================
  Nome do Script : TRG_UPD_TGFFIN_GRAVAR_AFT
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 01/07/2022 — referência)
  Descrição      : Trigger AFTER STATEMENT UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 01/07/2022, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPD_TGFFIN_GRAVAR_AFT', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFFIN_GRAVAR_AFT" 
AFTER UPDATE ON TGFFIN
DECLARE
    TYPE TABLE_GAV 
    IS TABLE OF TIMGAV%ROWTYPE 
    INDEX BY PLS_INTEGER;
    
    TYPE TABLE_NUFIN
    IS TABLE OF TGFFIN.NUFIN%TYPE
    INDEX BY PLS_INTEGER;
    
    ITENS_GAV TABLE_GAV;
    ITEM_GAV TIMGAV%ROWTYPE;
    
    ITENS_NUFIN TABLE_NUFIN;
    
    P_QTDGARANTIDOPORESTE INT;
    P_QTDFINGARANTIDOS INT;
    P_DIASREP INT;
    P_LOCGARANTIDOPOR INT;
    P_LOCCONTRATOADM INT;
BEGIN

   IF STP_GET_ATUALIZANDO THEN
    RETURN;
   END IF;

   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    SELECT DISTINCT * BULK COLLECT INTO ITENS_GAV
    FROM TIMGAV;

    DELETE FROM TIMGAV;
    
    FOR I IN 1..ITENS_GAV.COUNT
    LOOP
        ITEM_GAV := ITENS_GAV(I);
    
        IF ITEM_GAV.GAVBAIXA = 'S' THEN
            
            SELECT LOCGARANTIDOPOR, LOCDIAS, LOCCONTRATOADM INTO P_LOCGARANTIDOPOR, P_DIASREP, P_LOCCONTRATOADM
            FROM TIMLOC 
            WHERE LOCCODIGO = ITEM_GAV.GAVCONTRATOLOC;
            
            SELECT COUNT(*) INTO P_QTDFINGARANTIDOS 
            FROM TGFFIN
            WHERE RECDESP = 1
            AND DHBAIXA IS NULL
            AND TIMORIGEM = 'AL'
            AND TIMDTREPASSE IS NOT NULL
            AND TIMREPINTELIGENTE IS NULL
            AND TIMDHGERREPPARCIAL IS NULL
            AND NVL(TIMORIGRENEG,'N') = 'N'
            AND TIMNEGOCIACAO > 0
            AND TIMCONTRATOLOC = ITEM_GAV.GAVCONTRATOLOC;
            
            IF P_QTDFINGARANTIDOS < P_LOCGARANTIDOPOR THEN
                
                -- ALUGUÃ¿IS QUE PARA GARANTIR
                SELECT NUFIN BULK COLLECT INTO ITENS_NUFIN
                FROM TGFFIN
                WHERE RECDESP = 1
                AND DHBAIXA IS NULL
                AND TIMORIGEM = 'AL'
                AND TIMDTREPASSE IS NULL
                AND TIMREPINTELIGENTE IS NULL
                AND TIMDHGERREPPARCIAL IS NULL
                AND TIMDHGERREPASSE IS NULL
                AND NVL(TIMORIGRENEG,'N') = 'N'
                AND TIMNEGOCIACAO > 0
                AND TIMCONTRATOLOC = ITEM_GAV.GAVCONTRATOLOC
                ORDER BY TIMNEGOCIACAO,TIMPARCELA;
                
                IF ITENS_NUFIN.COUNT > 0 THEN
                    UPDATE TGFFIN 
                    SET TIMDTREPASSE = TIM_DEFINIR_DATA_REPASSE(DTVENC, CASE WHEN TIMORIGEM = 'FC' THEN NVL(TIM_GET_TSIPAR_INTEIRO('TIMQTDIASREPFC'),P_DIASREP) ELSE P_DIASREP END, CODEMP, P_LOCCONTRATOADM, TIMORIGEM), 
                        TIMFINGARANTORIG = ITEM_GAV.GAVNUFIN 
                    WHERE NUFIN = ITENS_NUFIN(1);
                END IF;
            END IF;
        ELSIF ITEM_GAV.GAVBAIXA = 'N' THEN
            
            SELECT COUNT(*) INTO P_QTDGARANTIDOPORESTE 
            FROM TGFFIN 
            WHERE TIMORIGEM = 'AL'
            AND TIMDTREPASSE IS NOT NULL
            AND TIMFINGARANTORIG = ITEM_GAV.GAVNUFIN
            AND TIMFINGARANTORIG <> NUFIN
            AND (TIMDHGERREPASSE IS NOT NULL
                OR TIMDHGERREPPARCIAL IS NOT NULL
                OR NVL(TIMORIGRENEG,'N') = 'S' -- NÃ¿O PODE FAZER PARTE DE ACORDO
                OR RECDESP = 0
            );
            
            -- SÃ¿ RODA PARA CONTRATOS GARANTIDOS, E EM CONTRATOS GARANTIDOS A TRIGGER TIMDTREPASSE NÃ¿O LIMPA O DTREPASSE NO ESTORNO.
            IF P_QTDGARANTIDOPORESTE = 0 THEN
                -- REMOVER GARANTIA DADA POR ESTÃ? BAIXA A OUTRO TÃ?TULO
                UPDATE TGFFIN
                SET TIMDTREPASSE = NULL, 
                    TIMFINGARANTORIG = NULL
                WHERE TIMORIGEM = 'AL'
                AND TIMDTREPASSE IS NOT NULL
                AND TIMFINGARANTORIG = ITEM_GAV.GAVNUFIN
                AND TIMFINGARANTORIG <> NUFIN;
            ELSE
                RAISE_APPLICATION_ERROR(-20101, 'Existem títulos com repasses gerados que foram garantidos pela baixa desse aluguel. Cancele os repasses desses títulos e tente novamente.');
            END IF;
            
            -- NESTE NUFIN, SE ELE NÃ¿O FOI GARANTIDO POR NINGUÃ¿M NEM POR ELE MESMO, O DT REPASSE DEVE SER LIMPO.
            -- CONTRATO COM GARANTIA PARCIAL EM QUE UM TÃ?TULO NÃ¿O TEM GARANTORIG, DEVE TER DT REPASSE LIMPO NO ESTORNO.
            IF ITEM_GAV.GAVFINGARANTORIG IS NULL THEN
                UPDATE TGFFIN
                SET TIMDTREPASSE = NULL
                WHERE NUFIN = ITEM_GAV.GAVNUFIN;
            END IF;
        END IF;
    END LOOP;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFFIN_GRAVAR_AFT" ENABLE;
