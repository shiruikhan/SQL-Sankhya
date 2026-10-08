/*==============================================================================
  Nome do Script : TIM_CLASSIFICADOS2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Resume em texto os anuncios (classificados) publicados de um
                  imovel desde a data de liberacao.
  Assinatura     : TIM_CLASSIFICADOS2 (CODIMOVEL NUMBER, DTLIBERA DATE) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_CLASSIFICADOS2', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_CLASSIFICADOS2 (CODIMOVEL NUMBER, DTLIBERA DATE) RETURN VARCHAR2 IS
 RSP VARCHAR2(4000);
 CURSOR RSCLA IS 
      Select sum(CLF.CLFDATAFIM - CLF.CLFDATAINI + 1) QtdDias, min(CLF.CLFDATAINI) PRIMEIRO, max(CLF.CLFDATAINI) ULTIMO, max(CLF.CLFDATAFIM) Final 
                    from TIMCFI CFI inner join TIMCLF CLF on CFI.CFICLASSIFICADO = CLF.CLFCODIGO
                   Where CFI.CFIIMOVEL = codImovel and trunc(CLF.CLFDATAINI) >= trunc(DTLIBERA) and abs(CLF.CLFDATAFIM - CLF.CLFDATAINI) < 20;
 BEGIN
   RSP := 'até hoje não foi publicado nenhum anúncio';
   FOR cla IN RSCLA LOOP
     if cla.QtdDias is not null then
       if cla.QtdDias = 1 then
         RSP := 'até hoje foi publicado um único anúncio no dia ' || to_char(cla.Ultimo, 'DD/MM/YYYY');
       else
         RSP := 'até hoje já foram publicados ' || to_char(cla.QtdDias) || ' anúncios,';
         if  cla.Primeiro = cla.Ultimo then
           RSP := RSP || ' entre os dias ' || to_char(cla.Ultimo, 'DD/MM/YYYY') || ' e '  || to_char(cla.Final, 'DD/MM/YYYY'); 
         else
           RSP := RSP || ' sendo os últimos entre os dias ' || to_char(cla.Ultimo, 'DD/MM/YYYY') || ' e '  || to_char(cla.Final, 'DD/MM/YYYY');
         end if;
       end if;
     end if;  
   END LOOP;
 RETURN RSP;
END;
