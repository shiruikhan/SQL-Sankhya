/*==============================================================================
  Nome do Script : TRG_UPD_TGFFIN_TIMDTREPASSE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPD_TGFFIN_TIMDTREPASSE', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFFIN_TIMDTREPASSE" 
BEFORE UPDATE
ON TGFFIN
FOR EACH ROW
DECLARE
    P_DIASREP          TIMLOC.LOCDIAS%TYPE;
    P_GARANTIDO        TIMLOC.LOCGARANTIDO%TYPE;
    P_DTREPASSE        TGFFIN.TIMDTREPASSE%TYPE;
    P_LOCCONTRATOADM   TIMLOC.LOCCONTRATOADM%TYPE;
BEGIN

   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO THEN
        RETURN;
    END IF;

    IF ((:NEW.DHBAIXA IS NOT NULL AND :OLD.DHBAIXA IS NULL) OR (:NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL)) AND :NEW.TIMCONTRATOLOC IS NOT NULL THEN
                                        
        IF :NEW.TIMCONTRATOLOC > 0 AND :NEW.TIMORIGEM IN('AL','AV','FC') THEN 
                                                
            BEGIN
                SELECT 
                    NVL(LOC.LOCGARANTIDO,'N'), LOC.LOCDIAS, LOC.LOCCONTRATOADM
                    INTO P_GARANTIDO, P_DIASREP, P_LOCCONTRATOADM
                FROM TIMLOC LOC
                WHERE LOCCODIGO = :NEW.TIMCONTRATOLOC;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20101, 'Contrato de locação não encontrado');
            END;
        
            IF :NEW.TIMORIGEM = 'FC' THEN -- PARCELA DE FECHAMENTO PODE TER DIAS DIFERENTE, SE FOR NULO SEGUE O DO CONTRATO
                  P_DIASREP := NVL(TIM_GET_TSIPAR_INTEIRO('TIMQTDIASREPFC'), P_DIASREP);
            END IF;

            IF :NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL -- ESTORNANDO
                AND :NEW.TIMDHBAIXA IS NOT NULL -- JÃ TINHA SIDO DEFINIDO TIMDHBAIXA
                AND TRUNC(:NEW.TIMDHBAIXA) = TRUNC(:OLD.DHBAIXA) THEN -- SE FOR DIFERENTE, NÃO PODE LIMPAR, É BAIXA POR EDI VIA PROC
                :NEW.TIMDHBAIXA := NULL;
            END IF;

            -- SE DATA DO PAGAMENTO NÃ?O FOI DEFINIDA DEFINIR DE DATA DA BAIXA             
            IF (:NEW.TIMDHBAIXA IS NULL) THEN
                :NEW.TIMDHBAIXA := :NEW.DHBAIXA;
            END IF;

            --BAIXANDO
            IF :NEW.DHBAIXA IS NOT NULL AND :OLD.DHBAIXA IS NULL THEN  
                -- CALCULAR DATA DO REPASSE COM BASE NA DATA DO PAGAMENTO 
                P_DTREPASSE :=  TIM_DEFINIR_DATA_REPASSE(:NEW.TIMDHBAIXA, P_DIASREP,:NEW.CODEMP, P_LOCCONTRATOADM, :NEW.TIMORIGEM);
                IF :NEW.TIMDHGERREPPARCIAL IS NULL THEN
                  -- DEFINIR DATA DO REPASSE SE ELA NÃO TIVER SIDO DEFINIDA OU MENOR IGUAL A DEFINIDA PARA CONTRATO NÃO GARANTIDO
                    IF (:NEW.TIMDTREPASSE IS NULL) OR (P_GARANTIDO = 'N' AND P_DTREPASSE > :NEW.TIMDTREPASSE) THEN
                        :NEW.TIMDTREPASSE := GREATEST(P_DTREPASSE,TRUNC(SYSDATE));
                    END IF;
                ELSE
                    -- DEFINIR DATA DO REPASSE SE ELA NÃO TIVER SIDO DEFINIDA OU MENOR IGUAL A DEFINIDA PARA CONTRATO NÃO GARANTIDO
                    :NEW.TIMDTREPPARCIAL := GREATEST(P_DTREPASSE,TRUNC(SYSDATE));
                END IF;
            END IF;

            --ESTORNANDO
            IF :NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL THEN   
                IF (P_GARANTIDO = 'N' OR :NEW.TIMORIGEM != 'AL') THEN
                    :NEW.TIMDTREPASSE := NULL;
                END IF;
                -- EM QUALQUER SITUAÇÃO DE ESTORNO ELE É APAGADO
                :NEW.TIMDTREPPARCIAL := NULL;
            END IF;
   
        END IF;
    END IF;
   
    IF :NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL AND :NEW.TIMDTREPASSE IS NULL AND :OLD.TIMDTREPASSE IS NOT NULL AND :NEW.TIMCONTRATOLOC IS NOT NULL AND :NEW.TIMORIGEM = 'AL' THEN   

        BEGIN
            SELECT LOC.LOCGARANTIDO INTO P_GARANTIDO
            FROM TIMLOC LOC
            WHERE LOCCODIGO = :NEW.TIMCONTRATOLOC;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20101, 'Contrato de locação não encontrado');
        END;      

        IF P_GARANTIDO = 'S' THEN
           RAISE_APPLICATION_ERROR(-20101, 'A data de repasse não pode ser apagada. O aluguel é garantido.');
        END IF;      

        IF :NEW.DHBAIXA IS NOT NULL THEN
           RAISE_APPLICATION_ERROR(-20101, 'A data de repasse não pode ser apagada. O aluguel já está baixado.');
        END IF;      

    END IF; 
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFFIN_TIMDTREPASSE" ENABLE;
