/*==============================================================================
  Nome do Script : SNK_GET_ORIGEM_PRODUTO_ITE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a origem do produto de um item, tentando primeiro a origem
                  alternativa e caindo para a padrao.
  Assinatura     : SNK_GET_ORIGEM_PRODUTO_ITE ( P_CODPROD INT,P_CODEMP INT, P_CODLOCALORIG INT, P_CONTROLE VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ORIGEM_PRODUTO_ITE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ORIGEM_PRODUTO_ITE ( P_CODPROD INT,P_CODEMP INT, P_CODLOCALORIG INT, P_CONTROLE VARCHAR2)
RETURN VARCHAR2 IS

P_ORIGPROD VARCHAR2(1);

BEGIN

    P_ORIGPROD := SNK_GET_ORIGEM_PRODUTO_ALT (P_CODPROD, P_CODEMP, P_CODLOCALORIG, P_CONTROLE);
    
    IF P_ORIGPROD IS NULL THEN
      P_ORIGPROD := SNK_GET_ORIGEM_PRODUTO (P_CODPROD, P_CODEMP);
    END IF;

    RETURN P_ORIGPROD;

END;
