/*==============================================================================
  Nome do Script : SNK_GET_DTULTIMOCUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a data do ultimo custo registrado do produto (TGFCUS) ate a data
                  informada, respeitando parametros de custo por empresa/local/controle.
  Assinatura     : SNK_GET_DTULTIMOCUSTO ( P_CODEMP INT, P_CODPROD INT, P_CODLOCAL INT, P_CONTROLE STRING, P_DTATUAL DATE )
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DTULTIMOCUSTO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DTULTIMOCUSTO ( P_CODEMP INT, P_CODPROD INT, P_CODLOCAL INT, P_CONTROLE STRING, P_DTATUAL DATE )
   RETURN DATE AS
   P_RESULT   DATE;   
BEGIN
  SELECT MAX(C.DTATUAL)
    INTO P_RESULT
  FROM TGFCUS C
  WHERE C.CODPROD = P_CODPROD
    AND C.DTATUAL <= P_DTATUAL
    AND C.CODEMP = CASE WHEN VARIAVEIS_PKG.V_CUSTOPOREMPRESA = 'N' THEN C.CODEMP ELSE P_CODEMP END
    AND C.CODLOCAL = CASE WHEN VARIAVEIS_PKG.V_CUSTOPORLOCAL = 'N' THEN C.CODLOCAL ELSE P_CODLOCAL END
    AND C.CONTROLE = CASE WHEN VARIAVEIS_PKG.V_CUSTOPORCONTROLE = 'N' THEN C.CONTROLE ELSE P_CONTROLE END;
  RETURN P_RESULT;
END;
