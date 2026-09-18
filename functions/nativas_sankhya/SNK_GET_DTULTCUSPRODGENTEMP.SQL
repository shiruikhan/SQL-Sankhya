/*==============================================================================
  Nome do Script : SNK_GET_DTULTCUSPRODGENTEMP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a ultima data de custo generico temporario de um produto (tabela
                  de trabalho TEMP_CUSPRODGENERICO).
  Assinatura     : SNK_GET_DTULTCUSPRODGENTEMP ( P_CODEMP INT, P_CODPROD INT, P_CODLOCAL INT, P_CONTROLE STRING, P_DTATUAL DATE )
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DTULTCUSPRODGENTEMP', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DTULTCUSPRODGENTEMP ( P_CODEMP INT, P_CODPROD INT, P_CODLOCAL INT, P_CONTROLE STRING, P_DTATUAL DATE )
   RETURN DATE AS
   P_RESULT   DATE;   
BEGIN   
  SELECT
     MAX(T.DTATUAL)
     INTO P_RESULT
  FROM TEMP_CUSPRODGENERICO T
  WHERE
      T.CODPROD = P_CODPROD
      AND T.CODEMP = CASE WHEN VARIAVEIS_PKG.V_CUSTOPOREMPRESA = 'N' THEN T.CODEMP ELSE P_CODEMP END
      AND T.CODLOCAL = CASE WHEN VARIAVEIS_PKG.V_CUSTOPORLOCAL = 'N' THEN T.CODLOCAL ELSE P_CODLOCAL END
      AND T.DTATUAL <= P_DTATUAL;
  
  RETURN P_RESULT;
END;
