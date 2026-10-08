/*==============================================================================
  Nome do Script : GETUF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo da UF de uma cidade (TSICID).
  Assinatura     : GETUF (P_CID NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GETUF', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GETUF (P_CID NUMBER)
RETURN NUMBER
AS
    P_RESULT    NUMBER(10) := 0;
BEGIN
    IF NVL(P_CID, 0) = 0 THEN
        P_RESULT := 0;
    ELSE 
        BEGIN
            SELECT UF INTO P_RESULT
            FROM TSICID
            WHERE CODCID = P_CID;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_RESULT := 0;
        END;
    END IF;
    RETURN P_RESULT;
END;
