/*==============================================================================
  Nome do Script : SNK_GETPRODUTOGENERICO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o produto generico vinculado a um produto especifico (TGFGXE), ou
                  o proprio produto se nao houver vinculo.
  Assinatura     : SNK_GETPRODUTOGENERICO (p_CodProd IN INT)
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETPRODUTOGENERICO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETPRODUTOGENERICO (p_CodProd IN INT)
RETURN INT
IS
  intCodProdGer INT;
BEGIN
              
    BEGIN
       SELECT
          CODPROD
       INTO
          intCodProdGer
       FROM 
          TGFGXE
       WHERE
          CODPRODESP = p_CodProd;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        intCodProdGer := p_CodProd;
    END;
         
    RETURN intCodProdGer;
END;
