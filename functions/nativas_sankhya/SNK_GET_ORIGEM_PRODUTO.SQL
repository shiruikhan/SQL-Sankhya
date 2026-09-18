/*==============================================================================
  Nome do Script : SNK_GET_ORIGEM_PRODUTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a origem fiscal do produto, priorizando a configuracao por empresa
                  (TGFPEM) sobre o cadastro geral (TGFPRO).
  Assinatura     : SNK_GET_ORIGEM_PRODUTO ( P_CODPROD INT,P_CODEMP INT)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ORIGEM_PRODUTO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ORIGEM_PRODUTO ( P_CODPROD INT,P_CODEMP INT)
RETURN VARCHAR2
IS
P_ORIGPROD VARCHAR2(1);
BEGIN
    SELECT NVL((SELECT PEM.ORIGPROD FROM TGFPEM PEM  WHERE PEM.CODEMP = P_CODEMP AND PEM.CODPROD = P_CODPROD),
	(SELECT PRO.ORIGPROD FROM TGFPRO PRO  WHERE PRO.CODPROD = P_CODPROD)) INTO P_ORIGPROD
	FROM DUAL;
		
	RETURN P_ORIGPROD;
END;

 
 
