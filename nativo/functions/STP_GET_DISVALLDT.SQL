/*==============================================================================
  Nome do Script : STP_GET_DISVALLDT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o titulo (NUFIN) esta marcado em TGFFIN_DISVALLDT
                  para desabilitar a validacao de data.
  Assinatura     : STP_GET_DISVALLDT (P_NUFIN INT) RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'STP_GET_DISVALLDT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION STP_GET_DISVALLDT (P_NUFIN INT)
RETURN BOOLEAN
IS
    P_RESULT BOOLEAN := FALSE;
    P_COUNT INT := 0;
BEGIN
    
    SELECT COUNT(*) INTO P_COUNT
    FROM TGFFIN_DISVALLDT
    WHERE NUFIN = P_NUFIN;
    
    IF P_COUNT = 1 THEN
        P_RESULT := TRUE;
    END IF;

    RETURN P_RESULT;
END;
