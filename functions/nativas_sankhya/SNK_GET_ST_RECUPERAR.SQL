/*==============================================================================
  Nome do Script : SNK_GET_ST_RECUPERAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o valor de ICMS-ST a recuperar em vendas interestaduais, com base
                  no ICMS unitario da ultima compra com ST nos ultimos 180 dias.
  Assinatura     : SNK_GET_ST_RECUPERAR ( P_NUNOTA IN INT, P_SEQUENCIA IN INT, P_CODPROD IN INT )
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ST_RECUPERAR', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ST_RECUPERAR ( P_NUNOTA IN INT, P_SEQUENCIA IN INT, P_CODPROD IN INT )
   RETURN FLOAT IS
   V_ST_ULTIMA_CPA   FLOAT;
   V_ST_RECUPERAR    FLOAT;
BEGIN
   --BUSCA O VALOR DE ST UNITARIO DA ULTIMA COMPRA COM ST LEVANDO EM CONTA APENAS COMPRAS DOS ULTIMOS 180 DIAS (PERFORMANCE)
   BEGIN
   SELECT NVL(SUM(  ( ISU.VLRSUBST + ISU.VLRICMS ) / ISU.QTDNEG ),0)
     INTO V_ST_ULTIMA_CPA
     FROM TGFITE ISU
    WHERE ISU.CODPROD = P_CODPROD
      AND ISU.VLRSUBST > 0
      AND ISU.NUNOTA = ( SELECT MAX( USI.NUNOTA ) AS NUNOTA
                          FROM TGFCAB USC, TGFITE USI
                         WHERE USC.TIPMOV = 'C' 
             AND USC.NUNOTA = USI.NUNOTA 
             AND USI.VLRSUBST > 0 
             AND USI.CODPROD = P_CODPROD
             AND USC.DTNEG > (SYSDATE - 180) --COMPRAS DOS ULTIMOS 180 DIAS
             );
  EXCEPTION WHEN NO_DATA_FOUND THEN
    V_ST_ULTIMA_CPA := 0;
  END;             

   --CALCULA O ST A RECUPERAR SENDO QUE SE O ITE.VLRICMS FOR MAIOR USA-O (ITE.VLRICMS) SE N?O USA O 
   --ST DA ULTIMA COMPRA QUE TEVE ST MULTIPLICADO PELA QUANTIDADE NEGOCIADA (ITE.QTDNEG)
  BEGIN
    SELECT NVL( CASE
                  WHEN V_ST_ULTIMA_CPA * I.QTDNEG > I.VLRICMS THEN I.VLRICMS
                  ELSE V_ST_ULTIMA_CPA * I.QTDNEG
               END, 0 )
     INTO V_ST_RECUPERAR
     FROM TGFITE I
    WHERE I.NUNOTA = P_NUNOTA AND I.SEQUENCIA = P_SEQUENCIA 
      AND I.VLRICMS > 0 --OPERACOES COM ICMS
      AND I.CODCFO BETWEEN 6000 AND 7000 --OPERACOES DE VENDA PARA FORA DO ESTADO
      AND I.CODTRIB IN (0, 10,30,70); --OPERACOES COM TRIBUTAC?O
  EXCEPTION WHEN NO_DATA_FOUND  THEN
    V_ST_RECUPERAR := 0;
  END;   

   RETURN ROUND( NVL( V_ST_RECUPERAR, 0 ), 2 );
END;

 
 
