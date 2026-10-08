/*==============================================================================
  Nome do Script : GETCIDCONTATO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo da cidade de um contato de parceiro
                  (TGFCTT).
  Assinatura     : GETCIDCONTATO (P_CODPARCCONT NUMBER, P_CODCONTATO NUMBER)
                  RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GETCIDCONTATO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GETCIDCONTATO (P_CODPARCCONT NUMBER, P_CODCONTATO NUMBER)
RETURN NUMBER
AS
    P_RESULT NUMBER := 0;
BEGIN
    IF NVL(P_CODPARCCONT, 0) <> 0 AND NVL(P_CODCONTATO, 0) <> 0 THEN
        BEGIN
            SELECT CODCID INTO P_RESULT
            FROM TGFCTT
            WHERE CODPARC = P_CODPARCCONT
              AND CODCONTATO = P_CODCONTATO;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_RESULT := 0;
        END;
    END IF;
    RETURN P_RESULT;          
END;
