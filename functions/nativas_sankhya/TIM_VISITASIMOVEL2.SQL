/*==============================================================================
  Nome do Script : TIM_VISITASIMOVEL2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Resume em texto o percentual de cada motivo de
                  desistencia/devolucao nas visitas ao imovel.
  Assinatura     : TIM_VISITASIMOVEL2 (CODIMOVEL IN NUMBER, dtLibera in Date)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_VISITASIMOVEL2', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_VISITASIMOVEL2 (CODIMOVEL IN NUMBER, dtLibera in Date) RETURN VARCHAR2 IS
 --AUTOR: BOSCO
 RETORNO VARCHAR2(4000);
 INICIO varchar2(50);
 NOVALINHA VarChar2(5);
 CURSOR RSVIS IS 
        SELECT mtdDesistencia, mtdMotivo, qtdMotivo, qtdTotal, TO_CHAR(qtdMotivo / qtdTotal * 100, '9G990D99') PercMot
        FROM ( 
                SELECT mtdDesistencia, mtd.mtdMotivo, COUNT(ecd.IPRFAC) AS QtdMotivo, NVL((
                        SELECT COUNT(ecd.IPRFAC)   
                        FROM TIMFAC ech 
                        INNER JOIN TIMIPR  ecd on ech.FACCODIGO = ecd.IPRFAC 
                        INNER JOIN TIMMTD  mtd ON ecd.IPRMOTIVO = mtd.mtdCodigo 
                        WHERE ech.FACLANCAMENTO >= dtLibera 
                        and ECD.IPRIMOVEL = codImovel), 1) QtdTotal  
                FROM TIMFAC ech 
                INNER JOIN TIMIPR  ecd on ech.FACCODIGO = ecd.IPRFAC 
                INNER JOIN TIMMTD  mtd ON ecd.IPRMOTIVO = mtd.mtdCodigo 
                WHERE ech.FACLANCAMENTO >= dtLibera and ECD.IPRIMOVEL = codImovel 
                GROUP BY mtdDesistencia, mtd.mtdMotivo) 
        ORDER BY mtdDesistencia, mtdMotivo; 
BEGIN
   NOVALINHA := Chr(13) || chr(10);
   RETORNO := 'Retorno das visitas.' || NOVALINHA;
   INICIO := RETORNO;
   FOR VIS IN RSVIS LOOP
     if vis.mtdDesistencia is not null then
       if vis.mtdDesistencia = 'S' then
         RETORNO := RETORNO || lpad(' ', 4) || 'Gostou:' || NOVALINHA;
       else
         RETORNO := RETORNO || lpad(' ', 4) || 'Não gostou:' || NOVALINHA;
       end if;
       RETORNO := RETORNO || lpad(' ', 9) || rpad(vis.mtdMotivo, 50)  || lpad(to_char(vis.qtdTotal), 10) || lpad(to_char(vis.PercMot), 10) || NOVALINHA;
     end if;
   END LOOP;
   if RETORNO = INICIO then
    RETORNO := '';
   end if;
 RETURN RETORNO;
END;
