/*==============================================================================
  Nome do Script : SNK_GET_MODELO_DOCUMENTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata o codigo do modelo de documento fiscal (ex.: 901 -> '1B'),
                  preenchendo zero a esquerda quando necessario.
  Assinatura     : SNK_GET_MODELO_DOCUMENTO (P_CODMODDOC NUMBER)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_MODELO_DOCUMENTO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_MODELO_DOCUMENTO (P_CODMODDOC    NUMBER)
RETURN VARCHAR2
AS
    P_RESULT  VARCHAR2(2);
BEGIN
    IF P_CODMODDOC IS NULL THEN
        P_RESULT := ' ';

    ELSIF P_CODMODDOC = 0 THEN
        P_RESULT := '';

    ELSIF P_CODMODDOC = 901 THEN
        P_RESULT := '1B';

    ELSIF P_CODMODDOC = 902 THEN
        P_RESULT := '8B';

    ELSIF LENGTH(P_CODMODDOC) = 1 THEN
        P_RESULT := '0' || P_CODMODDOC;

    ELSE
        P_RESULT := P_CODMODDOC;

    END IF;

  RETURN P_RESULT;
END;
