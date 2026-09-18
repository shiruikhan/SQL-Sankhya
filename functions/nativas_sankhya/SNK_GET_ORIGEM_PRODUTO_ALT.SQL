/*==============================================================================
  Nome do Script : SNK_GET_ORIGEM_PRODUTO_ALT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub para origem alternativa de produto — sempre retorna NULL (ponto de
                  extensao).
  Assinatura     : SNK_GET_ORIGEM_PRODUTO_ALT ( P_CODPROD INT,P_CODEMP INT, P_CODLOCALORIG INT, P_CONTROLE VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ORIGEM_PRODUTO_ALT', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ORIGEM_PRODUTO_ALT ( P_CODPROD INT,P_CODEMP INT, P_CODLOCALORIG INT, P_CONTROLE VARCHAR2)
RETURN VARCHAR2 IS

P_ORIGPROD VARCHAR2(1);

BEGIN
     
    P_ORIGPROD := NULL; -- INSERIR AQUI O CÓDIGO QUE BUSCA A ORIGEM DO PRODUTO
        
    RETURN P_ORIGPROD;

END;
