/*==============================================================================
  Nome do Script : SNK_GET_TIPO_ITEM
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Classifica o tipo de uso de um item de produto (materia-prima, revenda,
                  imobilizado, consumo etc.) em codigo numerico.
  Assinatura     : SNK_GET_TIPO_ITEM (P_CODEMP NUMBER ,P_CODPROD NUMBER ,P_USOPROD VARCHAR2)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_TIPO_ITEM', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_TIPO_ITEM (P_CODEMP         NUMBER
                                            ,P_CODPROD        NUMBER
                                            ,P_USOPROD        VARCHAR2)
RETURN NUMBER
AS
    P_RESULT        NUMBER(5);
    P_USOPROD_AUX    VARCHAR2(10);
BEGIN
    P_RESULT := 99;

    BEGIN
        SELECT USOPROD INTO P_USOPROD_AUX
        FROM TGFPEM    PEM
        WHERE PEM.CODEMP = P_CODEMP
          AND PEM.CODPROD = P_CODPROD;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        P_USOPROD_AUX := P_USOPROD;
    END;

    IF NVL(P_USOPROD_AUX, '*') <> '*' THEN
        P_USOPROD_AUX := SUBSTR(P_USOPROD_AUX, 1, 1);

        IF P_USOPROD_AUX = 'R' THEN
            P_RESULT := 0;

        ELSIF P_USOPROD_AUX = 'M' THEN
            P_RESULT := 1;

        ELSIF P_USOPROD_AUX = 'E' THEN
            P_RESULT := 2;

        ELSIF P_USOPROD_AUX = 'P' THEN
            P_RESULT := 3;

        ELSIF P_USOPROD_AUX = 'V' THEN
            P_RESULT := 4;

        ELSIF P_USOPROD_AUX = '1' THEN
            P_RESULT := 5;

        ELSIF P_USOPROD_AUX = '2' THEN
            P_RESULT := 6;

        ELSIF P_USOPROD_AUX = 'C' THEN
            P_RESULT := 7;

        ELSIF P_USOPROD_AUX = 'I' THEN
            P_RESULT := 8;

        ELSIF P_USOPROD_AUX = 'S' THEN
            P_RESULT := 9;

        ELSIF P_USOPROD_AUX = 'O' THEN
            P_RESULT := 10;
        END IF;
    END IF;

  RETURN P_RESULT;
END;
