/*==============================================================================
  Nome do Script : TIM_ACUMULAINDICE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Acumula indices de uma moeda/indexador (TSICOT) entre duas
                  datas (produtorio de 1 + cotacao/100).
  Assinatura     : TIM_ACUMULAINDICE (QIndice in Number, QDtInic in Date,
                  QDtFim in Date) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_ACUMULAINDICE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_ACUMULAINDICE (QIndice in Number, QDtInic in Date, QDtFim in Date) RETURN NUMBER IS
 cursor rsIdv is
  SELECT COTACAO 
  FROM TSICOT 
  WHERE CODMOEDA = QIndice 
    and DTMOV between QDtInic and QDtFim 
  ORDER BY DTMOV;
 ValVolta Number;
BEGIN
   ValVolta := 1;
   For Idv in rsIdv loop
    ValVolta := ValVolta * (1 + idv.COTACAO / 100);
   end loop;
   RETURN ValVolta;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END ;
