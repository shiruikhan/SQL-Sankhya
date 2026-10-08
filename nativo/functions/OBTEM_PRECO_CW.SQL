/*==============================================================================
  Nome do Script : OBTEM_PRECO_CW
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o preco de um produto na tabela de precos vigente
                  (TGFTAB) - integracao ChannelWeb.
  Assinatura     : OBTEM_PRECO_CW (P_PRODUTO IN NUMBER, P_TABELA IN NUMBER)
                  RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OBTEM_PRECO_CW', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION OBTEM_PRECO_CW (P_PRODUTO IN NUMBER, P_TABELA IN NUMBER) RETURN NUMBER
IS V_PRECO NUMBER;
BEGIN
    DECLARE
        P_NUTAB INTEGER;
    BEGIN
        BEGIN
            SELECT T.NUTAB
            INTO P_NUTAB
            FROM TGFTAB T
            WHERE T.CODTAB = P_TABELA
            AND T.DTVIGOR = (SELECT MAX(DTVIGOR)
                             FROM TGFTAB M
                             WHERE M.CODTAB = P_TABELA
                             AND M.DTVIGOR <= SYSDATE);
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_NUTAB := 0;
        END;

        STP_OBTEM_PRECO2(P_NUTAB, P_PRODUTO, SYSDATE, V_PRECO);

        RETURN(V_PRECO);
    END;
END;
