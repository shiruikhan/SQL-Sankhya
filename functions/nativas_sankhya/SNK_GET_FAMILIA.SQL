/*==============================================================================
  Nome do Script : SNK_GET_FAMILIA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo do produto 'pai' da familia de produtos (TGFFAM), ou o
                  proprio produto se nao tiver familia.
  Assinatura     : SNK_GET_FAMILIA (P_CODPROD IN INT)
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_FAMILIA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_FAMILIA (P_CODPROD IN INT)
   RETURN   INT IS
   RESULT   INT;
BEGIN
   SELECT MIN( CODPRODPAI ) INTO RESULT
   FROM (
           /*BUSCA O PROPRIO*/
           SELECT FAM.CODPRODPAI
             FROM TGFFAM FAM
            WHERE FAM.CODPRODPAI = P_CODPROD
           UNION
           /*BUSCA O PAI*/
           SELECT FAM.CODPRODPAI
             FROM TGFFAM FAM
            WHERE FAM.CODPRODFILHO = P_CODPROD );

   IF RESULT IS NULL THEN
      RESULT := P_CODPROD;
   END IF;

   RETURN(RESULT);
END;

 
 
