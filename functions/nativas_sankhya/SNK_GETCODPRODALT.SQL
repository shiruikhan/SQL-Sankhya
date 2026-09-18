/*==============================================================================
  Nome do Script : SNK_GETCODPRODALT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o menor codigo de produto alternativo (agrupamento TGFPAL) ativo
                  vinculado a um produto.
  Assinatura     : SNK_GETCODPRODALT (p_CodProd IN INT, p_Agrupar IN VARCHAR2)
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETCODPRODALT', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETCODPRODALT (p_CodProd IN INT, p_Agrupar IN VARCHAR2)
RETURN INT
IS
  intCodProdAlt INT;
BEGIN
  IF p_Agrupar = 'N' THEN
    RETURN ( p_CodProd );
  ELSE  
    SELECT MIN(CODPRODALT)
    INTO intCodProdAlt
    FROM
    (SELECT PAL.CODPROD AS CODPRODALT
     FROM TGFPAL PAL, TGFPRO PRO
     WHERE CODPRODALT = p_CODPROD
           AND PAL.CODPROD = PRO.CODPROD
           AND PRO.ATIVO = 'S'
     UNION
     SELECT PAL.CODPRODALT AS CODPRODALT
     FROM TGFPAL PAL, TGFPRO PRO
     WHERE (PAL.CODPROD = p_CODPROD 
            AND PAL.CODPRODALT < PAL.CODPROD
            OR PAL.CODPROD IN (SELECT MIN(CODPROD)
                               FROM TGFPAL
                               WHERE CODPRODALT = p_CODPROD))
     AND PAL.CODPROD = PRO.CODPROD 
     AND PRO.ATIVO = 'S');
    IF intCodProdAlt is null THEN
        RETURN (p_CODPROD);
    ELSE 
        RETURN ( intCodProdAlt );
    END IF;
  END IF;
END;
