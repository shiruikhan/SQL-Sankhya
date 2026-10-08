/*==============================================================================
  Nome do Script : OBTEM_EST_KIT_LV
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Estoque disponivel de um kit (variacao 30000 em TGFICP) pelo
                  menor estoque de seus componentes - versao loja virtual.
  Assinatura     : OBTEM_EST_KIT_LV (P_CODPROD IN NUMBER, P_CODEMP IN NUMBER,
                  P_CODLOCAL IN NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OBTEM_EST_KIT_LV', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION OBTEM_EST_KIT_LV (P_CODPROD IN NUMBER, P_CODEMP IN NUMBER, P_CODLOCAL IN NUMBER) RETURN NUMBER
IS V_ESTOQUE NUMBER;
BEGIN
    BEGIN
        SELECT MIN(TRUNC((NVL(EST1.ESTOQUE, 0) - NVL(EST1.RESERVADO, 0))/ ICP1.QTDMISTURA)) INTO V_ESTOQUE
        FROM TGFICP ICP1
        LEFT JOIN TGFPRO PRO1 ON PRO1.CODPROD = ICP1.CODPROD
        LEFT JOIN TGFPRO MAT1 ON MAT1.CODPROD = ICP1.CODMATPRIMA
        LEFT JOIN TGFEST EST1 ON ICP1.CODMATPRIMA  = EST1.CODPROD
                                AND (EST1.CODEMP   = P_CODEMP OR NVL(P_CODEMP, 1) = 1)
                                AND (EST1.CODLOCAL = P_CODLOCAL OR NVL(P_CODLOCAL, 0) = 0)
        WHERE ICP1.CODPROD = P_CODPROD
        AND ICP1.VARIACAO = 30000;

        RETURN(V_ESTOQUE);

    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END;

END;
