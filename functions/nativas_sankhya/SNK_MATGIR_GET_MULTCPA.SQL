/*==============================================================================
  Nome do Script : SNK_MATGIR_GET_MULTCPA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o multiplo de compra (embalagem) de um produto para um parceiro no
                  giro de estoque, com fallback para o agrupamento do proprio produto.
  Assinatura     : SNK_MATGIR_GET_MULTCPA (P_CODPROD NUMBER, P_CODPARC NUMBER, P_UNIDADE VARCHAR2)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_MATGIR_GET_MULTCPA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_MATGIR_GET_MULTCPA (P_CODPROD   NUMBER,
                                                  P_CODPARC   NUMBER,
                                                  P_UNIDADE   VARCHAR2)
RETURN    NUMBER
AS MULT            NUMBER;
BEGIN
  BEGIN
    
      SELECT MULTIPCPA INTO MULT
      FROM TGFPAP PAP
      WHERE
          PAP.CODPROD = P_CODPROD
          AND PAP.CODPARC = P_CODPARC
          AND (PAP.UNIDADEPARC IS NULL OR PAP.UNIDADE = P_UNIDADE)
          AND ROWNUM = 1
      ORDER BY (CASE WHEN PAP.UNIDADEPARC IS NOT NULL THEN 1 ELSE 2 END), SEQUENCIA;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       MULT := 0;
 END;
 
  IF NVL(MULT, 0) = 0 THEN      
     SELECT QTDAGRUPAMENTOMTZ INTO MULT FROM TGFPRO WHERE CODPROD = P_CODPROD;                    
  END IF;
   
  RETURN MULT;    
END;
