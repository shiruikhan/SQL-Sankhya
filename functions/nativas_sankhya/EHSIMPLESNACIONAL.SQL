/*==============================================================================
  Nome do Script : EHSIMPLESNACIONAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se a empresa e optante do Simples Nacional
                  (TSIEMP.SIMPLES = 'S' e regime tributario 1).
  Assinatura     : EHSIMPLESNACIONAL (P_EMP NUMBER) RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EHSIMPLESNACIONAL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EHSIMPLESNACIONAL (P_EMP NUMBER)
RETURN BOOLEAN
AS
    P_RESULT    BOOLEAN := FALSE;
    P_COUNT     NUMBER(5);
BEGIN
    IF NVL(P_EMP, 0) <> 0 THEN            
        SELECT COUNT(1) INTO P_COUNT
        FROM TSIEMP EMP
        WHERE EMP.CODEMP = P_EMP
          AND NVL(EMP.SIMPLES, 'N') = 'S'
          AND NVL(EMP.CODREGTRIB, 0) = 1 ;
            
        IF P_COUNT > 0 THEN
            P_RESULT := TRUE;
        END IF;
    END IF;
    RETURN P_RESULT;
END;
