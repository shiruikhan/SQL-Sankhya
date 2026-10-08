/*==============================================================================
  Nome do Script : TRG_TGFFIN_TIM_BAIXA_CJMD_AFT
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER STATEMENT UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 08/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_TGFFIN_TIM_BAIXA_CJMD_AFT', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFFIN_TIM_BAIXA_CJMD_AFT" 
AFTER UPDATE
ON TGFFIN
DECLARE
    P_HIST_JURO INT;
    P_HIST_MULTA INT;
    P_HIST_DESC INT;
    P_VALOR NUMBER(10,2);
    P_TIMCALDESD VARCHAR(50);
    P_VLRJURO NUMBER(10,2);
    P_VLRMULTA NUMBER(10,2);
    P_VLRDESC NUMBER(10,2);
    P_OLD_VLRJURO NUMBER(10,2);
    P_OLD_VLRMULTA NUMBER(10,2);
    P_OLD_VLRDESC NUMBER(10,2);
    P_EXITS_VIMCFI NUMBER(10,2);
    
    TYPE BAIXADOS_TYPE IS TABLE OF TIM_BAIXA_CJMD%ROWTYPE INDEX BY PLS_INTEGER; 
    BAIXADOS_LIST BAIXADOS_TYPE;
    
    BAIXADOS_ROW TIM_BAIXA_CJMD%ROWTYPE;
    TGFFIN_NEW TGFFIN%ROWTYPE;
    
    -- Declaracao de uma funcao para descobrir os historicos de 'Juros, Multa, Desconto' a fim de salvar nas variaveis definidas
    FUNCTION GET_PARAMETRO_INT(P_PARAMETRO VARCHAR)
    RETURN INT
    AS
        P_RESULT INT;
    BEGIN
        
        SELECT INTEIRO INTO P_RESULT
        FROM TSIPAR
        WHERE UPPER(CHAVE) = UPPER(P_PARAMETRO)
        AND CODUSU = 0;
        
        RETURN P_RESULT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN NULL;
    END;
    
    -- Declaracao de uma variavel e uma funcao para descobrir se o parametro 'Calc. Juros, Multa, Desconto (Incluso,Extra)' eh Extra ou Incluso
    FUNCTION GET_PARAMETRO_TXT(P_PARAMETRO VARCHAR)
    RETURN VARCHAR
    AS
        P_RESULT VARCHAR(4000);
    BEGIN
        
        SELECT TEXTO INTO P_RESULT
        FROM TSIPAR
        WHERE UPPER(CHAVE) = UPPER(P_PARAMETRO)
        AND CODUSU = 0;
        
        RETURN P_RESULT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN NULL;
    END;
    
BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
    -- Trigger so eh executada se nao estiver ocorrendo uma atualizacao do SKW
    
    -- Deleta os que nao tem financeiro
    DELETE
    FROM TIM_BAIXA_CJMD C
    WHERE NOT EXISTS (
        SELECT 1
        FROM TGFFIN
        WHERE NUFIN = C.NUFIN
    );
    
    -- Pega os registros nao processados, barra a recursao da trigger
    SELECT * BULK COLLECT INTO BAIXADOS_LIST
    FROM TIM_BAIXA_CJMD
    WHERE PROCESSANDO = 'N';
    
       -- Em cada registro, marca como processado para barrar a recusao da trigger
    FOR I IN 1..BAIXADOS_LIST.COUNT 
    LOOP
        UPDATE TIM_BAIXA_CJMD
        SET PROCESSANDO = 'S'
        WHERE NUFIN = BAIXADOS_LIST(I).NUFIN;
    END LOOP;
    
    -- Para cada registro, cria o detalhamento
    FOR I IN 1..BAIXADOS_LIST.COUNT 
    LOOP
        
        BAIXADOS_ROW := BAIXADOS_LIST(I);
        
        SELECT * INTO TGFFIN_NEW
        FROM TGFFIN
        WHERE NUFIN = BAIXADOS_ROW.NUFIN;
        
        SELECT COUNT(1) INTO P_EXITS_VIMCFI
        FROM VIMCFI
        WHERE LDTPARCELA = BAIXADOS_ROW.NUFIN;
        
        -- Loteamentos primeiro
        IF TGFFIN_NEW.TIMORIGEM IN ('PD','EN','FI','AR','PI','PC','FP','FB','AC') AND TGFFIN_NEW.TIMCONTRATOLTV IS NOT NULL THEN
            -- LOTEAMENTO CONSIDERA OS VALORES CORRETOS (AJUSTA CONFORME BAIXA)
        
            P_HIST_JURO := GET_PARAMETRO_INT('TIMACMJUR');
            P_HIST_MULTA := GET_PARAMETRO_INT('TIMACMMUL');
            P_HIST_DESC := GET_PARAMETRO_INT('TIMACMDESC');
            P_TIMCALDESD := NVL(GET_PARAMETRO_TXT('TIMCALDESD'),'Incluso');
           
            IF (P_HIST_JURO IS NULL OR P_HIST_MULTA IS NULL OR P_HIST_DESC IS NULL) THEN
                RAISE_APPLICATION_ERROR(-20201, 'Os parâmetros de sistema "TIMACMJUR, TIMACMMUL, TIMACMDESC" são obrigatórios e não foram informados.');
            END IF;
            
            IF P_TIMCALDESD = 'Extra' THEN
                P_VLRJURO := TGFFIN_NEW.VLRJURO;
                P_VLRMULTA := TGFFIN_NEW.VLRMULTA;
                P_VLRDESC := TGFFIN_NEW.VLRDESC;
                P_OLD_VLRJURO := BAIXADOS_ROW.OLD_VLRJURO;
                P_OLD_VLRMULTA := BAIXADOS_ROW.OLD_VLRMULTA;
                P_OLD_VLRDESC := BAIXADOS_ROW.OLD_VLRDESC;
            ELSE
                P_VLRJURO := TGFFIN_NEW.VLRJUROEMBUT;
                P_VLRMULTA := TGFFIN_NEW.VLRMULTAEMBUT;
                P_VLRDESC := TGFFIN_NEW.VLRDESCEMBUT;
                P_OLD_VLRJURO := BAIXADOS_ROW.OLD_VLRJUROEMBUT;
                P_OLD_VLRMULTA := BAIXADOS_ROW.OLD_VLRMULTAEMBUT;
                P_OLD_VLRDESC := BAIXADOS_ROW.OLD_VLRDESCEMBUT;
            END IF;
            
            -- Se tiver juros, cria detalhamento de juros
            IF ABS(NVL(P_VLRJURO,0) - NVL(P_OLD_VLRJURO,0)) >= 0.01 THEN
            
                P_VALOR := 0;
                
                IF P_EXITS_VIMCFI > 0 THEN
            
                  SELECT
                      CASE 
                          WHEN P_TIMCALDESD = 'Extra' THEN VLRJURO
                          ELSE VLRJUROEMBUT 
                      END
                      INTO
                      P_VALOR
                  FROM VIMCFI
                  WHERE LDTPARCELA = TGFFIN_NEW.NUFIN;
                     -- VIMCFI eh uma View
                   
                END IF;                   

                IF ABS(NVL(P_VLRJURO,0) - NVL(P_VALOR,0)) >= 0.01 THEN
                    P_OLD_VLRJURO := P_VALOR;
                    P_VALOR := P_VLRJURO - P_OLD_VLRJURO;
        
                    STP_TIM_INSERT_TIMLDT(TGFFIN_NEW.NUFIN, TGFFIN_NEW.DTVENC, TGFFIN_NEW.DTVENC, P_HIST_JURO, P_VALOR, 'DETALHAMENTO DE JURO ORIGEM BAIXA');
                END IF;
            END IF;
            
            -- Se tiver multa, cria detalhamento de multa
            IF ABS(NVL(P_VLRMULTA,0) - NVL(P_OLD_VLRMULTA,0)) >= 0.01 THEN
            
                P_VALOR := 0;
                
                IF P_EXITS_VIMCFI > 0 THEN
            
                  SELECT
                      CASE 
                          WHEN P_TIMCALDESD = 'Extra' THEN VLRMULTA
                          ELSE VLRMULTAEMBUT 
                      END 
                      INTO
                      P_VALOR
                  FROM VIMCFI
                  WHERE LDTPARCELA = TGFFIN_NEW.NUFIN;
                  
                END IF;
                    
                IF ABS(NVL(P_VLRMULTA,0) - NVL(P_VALOR,0)) >= 0.01 THEN
                    P_OLD_VLRMULTA := P_VALOR;
                    P_VALOR := P_VLRMULTA - P_OLD_VLRMULTA;

                    STP_TIM_INSERT_TIMLDT(TGFFIN_NEW.NUFIN, TGFFIN_NEW.DTVENC, TGFFIN_NEW.DTVENC, P_HIST_MULTA, P_VALOR, 'DETALHAMENTO DE MULTA ORIGEM BAIXA');
                END IF;
            END IF;
            
            -- Se tiver desconto, cria detalhamento de desconto
            IF ABS(NVL(P_VLRDESC,0) - NVL(P_OLD_VLRDESC,0)) >= 0.01 THEN
            
                P_VALOR := 0;
                
                IF P_EXITS_VIMCFI > 0 THEN
                
                  SELECT
                      CASE 
                          WHEN P_TIMCALDESD = 'Extra' THEN VLRDESC
                          ELSE VLRDESCEMBUT 
                      END 
                      INTO
                      P_VALOR
                  FROM VIMCFI
                  WHERE LDTPARCELA = TGFFIN_NEW.NUFIN;  
                  
                END IF;
                    
                IF ABS(NVL(P_VLRDESC,0) - NVL(P_VALOR,0)) >= 0.01 THEN
                    P_OLD_VLRDESC := P_VALOR;
                    P_VALOR := P_VLRDESC - P_OLD_VLRDESC;
                        
                    STP_TIM_INSERT_TIMLDT(TGFFIN_NEW.NUFIN, TGFFIN_NEW.DTVENC, TGFFIN_NEW.DTVENC, P_HIST_DESC, P_VALOR, 'DETALHAMENTO DE DESCONTO ORIGEM BAIXA'); 
                END IF;
            END IF;
        -- Agora locacao
        ELSIF TGFFIN_NEW.TIMORIGEM IN ('AL','AV','FC') THEN
            -- LOCAÇÃO SOMA OS VALORES (FEITO PELA TRIGGER DE BEFORE BAIXA)
            
            P_HIST_JURO := NVL(GET_PARAMETRO_INT('TIMHISTJUROSLOC'), 10);
            P_HIST_MULTA := NVL(GET_PARAMETRO_INT('TIMHISTMULTALOC'), 5);
            P_HIST_DESC := GET_PARAMETRO_INT('TIMDTLDESCONTO');
            
            IF P_HIST_DESC IS NULL THEN
                RAISE_APPLICATION_ERROR(-20201, 'O parâmetro de sistema "TIMDTLDESCONTO" é obrigatório e não foi informado.');
            END IF;
            
            P_VLRJURO := TGFFIN_NEW.VLRJUROEMBUT;
            P_VLRMULTA := TGFFIN_NEW.VLRMULTAEMBUT;
            P_VLRDESC := TGFFIN_NEW.VLRDESCEMBUT;
            P_OLD_VLRJURO := BAIXADOS_ROW.OLD_VLRJUROEMBUT;
            P_OLD_VLRMULTA := BAIXADOS_ROW.OLD_VLRMULTAEMBUT;
            P_OLD_VLRDESC := BAIXADOS_ROW.OLD_VLRDESCEMBUT;
            
            -- Se tiver juros, cria detalhamento de juros            
            SELECT VLRJUROEMBUT INTO P_VALOR
            FROM VIMALU
            WHERE DTLPARCELA = TGFFIN_NEW.NUFIN;
            -- VIMALU eh uma View

            IF ABS(NVL(P_VLRJURO,0) - NVL(P_VALOR,0)) >= 0.01 THEN
                P_OLD_VLRJURO := P_VALOR;
                P_VALOR := P_VLRJURO - P_OLD_VLRJURO;
                
                STP_TIM_INSERT_TIMDTL(TGFFIN_NEW.NUFIN, TGFFIN_NEW.DTVENC, TGFFIN_NEW.DTVENC, P_HIST_JURO, P_VALOR, 'DETALHAMENTO DE JURO ORIGEM BAIXA');    
            END IF;
            
            -- Se tiver multa, cria detalhamento de multa
            SELECT VLRMULTAEMBUT INTO P_VALOR
            FROM VIMALU
            WHERE DTLPARCELA = TGFFIN_NEW.NUFIN;

            IF ABS(NVL(P_VLRMULTA,0) - NVL(P_VALOR,0)) >= 0.01 THEN
                P_OLD_VLRMULTA := P_VALOR;
                P_VALOR := P_VLRMULTA - P_OLD_VLRMULTA;
                        
                STP_TIM_INSERT_TIMDTL(TGFFIN_NEW.NUFIN, TGFFIN_NEW.DTVENC, TGFFIN_NEW.DTVENC, P_HIST_MULTA, P_VALOR, 'DETALHAMENTO DE MULTA ORIGEM BAIXA');            
            END IF;
            
           -- Se tiver desconto, cria detalhamento de descontos
            SELECT VLRDESCEMBUT INTO P_VALOR
            FROM VIMALU
            WHERE DTLPARCELA = TGFFIN_NEW.NUFIN;

            IF ABS(NVL(P_VLRDESC,0) - NVL(P_VALOR,0)) >= 0.01 THEN
                P_OLD_VLRDESC := P_VALOR;
                P_VALOR := P_VLRDESC - P_OLD_VLRDESC;

                STP_TIM_INSERT_TIMDTL(TGFFIN_NEW.NUFIN, TGFFIN_NEW.DTVENC, TGFFIN_NEW.DTVENC, P_HIST_DESC, P_VALOR, 'DETALHAMENTO DE DESCONTO ORIGEM BAIXA');
            END IF;
        END IF;
    END LOOP;
    
       -- Deleta da tabela temporaria os registros ja processados
    FOR I IN 1..BAIXADOS_LIST.COUNT 
    LOOP
        DELETE
        FROM TIM_BAIXA_CJMD
        WHERE NUFIN = BAIXADOS_LIST(I).NUFIN;
    END LOOP;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFFIN_TIM_BAIXA_CJMD_AFT" ENABLE;
