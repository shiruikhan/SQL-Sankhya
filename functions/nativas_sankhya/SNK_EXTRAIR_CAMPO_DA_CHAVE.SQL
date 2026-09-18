/*==============================================================================
  Nome do Script : SNK_EXTRAIR_CAMPO_DA_CHAVE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Extrai um campo especifico (UF, emissao, CNPJ, modelo, serie, numero,
                  codigo aleatorio, DV) da chave de acesso de NF-e por posicao.
  Assinatura     : SNK_EXTRAIR_CAMPO_DA_CHAVE (P_CHAVE VARCHAR2, P_CAMPO VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_EXTRAIR_CAMPO_DA_CHAVE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_EXTRAIR_CAMPO_DA_CHAVE (P_CHAVE VARCHAR2, P_CAMPO VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    IF P_CAMPO LIKE 'UF' THEN
      RETURN SUBSTR(P_CHAVE,0,2);
      ELSIF P_CAMPO LIKE 'EMISSAO' THEN
      RETURN SUBSTR(P_CHAVE,3,4);
    ELSIF P_CAMPO LIKE 'CNPJ' THEN
      RETURN SUBSTR(P_CHAVE,7,14);
    ELSIF P_CAMPO LIKE 'CODMODDOC' THEN
      RETURN SUBSTR(P_CHAVE,21,2);
    ELSIF P_CAMPO LIKE 'SERIENOTA' THEN
      RETURN SUBSTR(P_CHAVE,23,3);
    ELSIF P_CAMPO LIKE 'NUMNOTA' THEN
      RETURN SUBSTR(P_CHAVE,26,8);
    ELSIF P_CAMPO LIKE 'TIPOEMISSAO' THEN
      RETURN SUBSTR(P_CHAVE,35,1);
    ELSIF P_CAMPO LIKE 'CODALEATORIO' THEN
      RETURN SUBSTR(P_CHAVE,36,8);
    ELSIF P_CAMPO LIKE 'DV' THEN
      RETURN SUBSTR(P_CHAVE,44,1);
    END IF;
    RETURN '';
END;
