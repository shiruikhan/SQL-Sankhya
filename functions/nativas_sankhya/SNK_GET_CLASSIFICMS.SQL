/*==============================================================================
  Nome do Script : SNK_GET_CLASSIFICMS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina a classificacao de ICMS (consumidor final etc.) resolvendo TOP,
                  TGFPAEM e TGFPAR em cascata.
  Assinatura     : SNK_GET_CLASSIFICMS (P_NUNOTA NUMBER, P_CODEMP NUMBER, P_CODPARC NUMBER, P_CLASSIF_PAR VARCHAR2, P_CLASSIF_TOP VARCHAR2, P_CODTIPOPER NUMBER, P_DHTIPOPER DATE)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CLASSIFICMS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CLASSIFICMS (P_NUNOTA         NUMBER,
                                               P_CODEMP         NUMBER,
                                               P_CODPARC        NUMBER,
                                               P_CLASSIF_PAR    VARCHAR2,
                                               P_CLASSIF_TOP    VARCHAR2,
                                               P_CODTIPOPER     NUMBER,
                                               P_DHTIPOPER      DATE)
RETURN VARCHAR2
AS
    P_CODEMP_UTIL               NUMBER(10);
    P_CODPARC_UTIL              NUMBER(10);
    P_CODPARC_REM_UTIL          NUMBER(10);
    P_CODPARC_DEST_UTIL         NUMBER(10);
    P_CLASSIF_TOP_UTIL          VARCHAR2(1);
    P_CLASSIF_PAEM_UTIL         VARCHAR2(1);
    P_CLASSIF_PAR_UTIL          VARCHAR2(1) := ' ';
    P_TIPMOV_UTIL               VARCHAR2(1);
    P_RESULT                    VARCHAR2(1);
    TOP_BUSCA_NO_PARCEIRO       VARCHAR2(1) := 'A';
    PAEM_BUSCA_NO_PARCEIRO      VARCHAR2(1) := 'Z';
    PARCEIRO_BUSCA_NA_TOP       VARCHAR2(1) := 'T';
    CLASSIFICMS_CONSUMIDOR_FINAL VARCHAR2(1) := 'C';
BEGIN
    IF NVL(P_NUNOTA, 0) <> 0 THEN
        SELECT CAB.CODEMP, CAB.CODPARC, NVL(TPO.CLASSIFICMS,TOP_BUSCA_NO_PARCEIRO), CAB.TIPMOV, CAB.CODPARCREMETENTE, CAB.CODPARCDEST
            INTO P_CODEMP_UTIL, P_CODPARC_UTIL, P_CLASSIF_TOP_UTIL, P_TIPMOV_UTIL, P_CODPARC_REM_UTIL, P_CODPARC_DEST_UTIL
        FROM TGFCAB CAB
             INNER JOIN TGFTOP TPO ON TPO.CODTIPOPER = CAB.CODTIPOPER AND TPO.DHALTER = CAB.DHTIPOPER
        WHERE NUNOTA = P_NUNOTA;
        
        IF (NVL(P_CODPARC_DEST_UTIL, 0) <> 0 AND 
            (P_TIPMOV_UTIL = 'T' OR
             (P_TIPMOV_UTIL = 'V' AND NVL(P_CODPARC_REM_UTIL, 0) <> 0) OR
             (P_TIPMOV_UTIL = 'C' AND NVL(P_CODPARC_REM_UTIL, 0) <> 0 AND GET_TSIPAR_LOGICO('USAPARREMDESCPA') = 'S' ) )) THEN
            P_CODPARC_UTIL := P_CODPARC_DEST_UTIL;
        ELSIF NVL(P_CODPARC_UTIL, 0) = 0 THEN
            P_RESULT := 'R';
            RETURN P_RESULT;
        END IF;
    ELSE
        P_CODEMP_UTIL      := P_CODEMP;
        P_CODPARC_UTIL     := P_CODPARC;
        P_CLASSIF_PAR_UTIL := P_CLASSIF_PAR;
        
        IF NVL(P_CLASSIF_TOP, ' ') = ' ' THEN
            BEGIN
                SELECT CLASSIFICMS INTO P_CLASSIF_TOP_UTIL
                FROM TGFTOP
                WHERE CODTIPOPER = P_CODTIPOPER
                  AND DHALTER = P_DHTIPOPER;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                P_CLASSIF_TOP_UTIL := TOP_BUSCA_NO_PARCEIRO;
            END;  
        ELSE 
            P_CLASSIF_TOP_UTIL := P_CLASSIF_TOP;
        END IF;
    END IF;
    
    IF P_CLASSIF_TOP_UTIL = TOP_BUSCA_NO_PARCEIRO THEN
        BEGIN
            SELECT NVL(CLASSIFICMS, PAEM_BUSCA_NO_PARCEIRO)
              INTO P_CLASSIF_PAEM_UTIL
            FROM TGFPAEM
            WHERE CODPARC = P_CODPARC_UTIL
            AND CODEMP = P_CODEMP_UTIL;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_CLASSIF_PAEM_UTIL := PAEM_BUSCA_NO_PARCEIRO;
        END;
        
        IF P_CLASSIF_PAEM_UTIL = PAEM_BUSCA_NO_PARCEIRO THEN
            IF NVL(TRIM(P_CLASSIF_PAR_UTIL), ' ') = ' ' THEN                 
                BEGIN
                    SELECT NVL(CLASSIFICMS, CLASSIFICMS_CONSUMIDOR_FINAL)
                        INTO P_CLASSIF_PAR_UTIL
                    FROM TGFPAR
                    WHERE CODPARC = P_CODPARC_UTIL;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    P_CLASSIF_PAR_UTIL := CLASSIFICMS_CONSUMIDOR_FINAL;
                END;
            END IF;
            
            P_RESULT := P_CLASSIF_PAR_UTIL;
        ELSE
            P_RESULT := P_CLASSIF_PAEM_UTIL;
        END IF;
        /* vai ser validado nos fontes/chamdas desta function
        IF P_RESULT = PARCEIRO_BUSCA_NA_TOP THEN
            RAISE_APPLICATION_ERROR(-20101, 'Classificação de ICMS do parceiro inválida para ser usada com esta TOP.');
        END IF;*/
    ELSE
        P_RESULT := P_CLASSIF_TOP_UTIL;
    END IF;
    
    RETURN P_RESULT;
END;
