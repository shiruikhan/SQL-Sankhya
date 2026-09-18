/*==============================================================================
  Nome do Script : SNK_GET_PRODTOK
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Function pipelined que busca produtos por token de busca (TSITOKP/TSITOK),
                  retornando uma tabela de codigos de produto.
  Assinatura     : SNK_GET_PRODTOK (P_TERMO VARCHAR2, P_BUSCA_CODPROD VARCHAR2, P_QUALQUER_TERMO VARCHAR2)
                   RETURN PIPELINED_TOKP
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PRODTOK', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PRODTOK (P_TERMO VARCHAR2, P_BUSCA_CODPROD VARCHAR2, P_QUALQUER_TERMO VARCHAR2)
   RETURN PIPELINED_TOKP PIPELINED AS
   queTermo VARCHAR2(4000);
   queTokProd VARCHAR2(4000);
   currentTermo VARCHAR2(4000);
   usaOperador VARCHAR2(1);
   codProd NUMBER(10);
   TYPE cur_typ IS REF CURSOR;
   curTermo cur_typ;
   curTokProd cur_typ;
BEGIN
 
   queTokProd := '';
   
   -- Neste caso o termo deve ser único e somente números
   IF P_BUSCA_CODPROD = 'S' THEN
      queTokProd := queTokProd || ' SELECT P.CODPROD FROM TGFPRO P WHERE P.CODPROD = ' || P_TERMO || ' UNION ';
   END IF;
   
   queTokProd := queTokProd || ' SELECT PRO.CODPROD FROM TGFPRO PRO WHERE ';
   
   queTermo := 
   'SELECT ' 
   ||'    REGEXP_SUBSTR (TERMO, ''[^,]+'', 1, LEVEL)'
   ||' FROM ('
   ||'    SELECT '''|| P_TERMO ||''' AS TERMO FROM DUAL'
   ||' )'
   ||' CONNECT BY LEVEL <= LENGTH(REGEXP_REPLACE(TERMO,''[^,]*''))+1';
   
   --RAISE_APPLICATION_ERROR(-20101, queTermo);
   
   usaOperador := 'N';

   OPEN curTermo FOR queTermo;

   LOOP   
     FETCH curTermo INTO currentTermo;
     
     EXIT WHEN curTermo%NOTFOUND;
     
     IF usaOperador = 'S' THEN
         IF P_QUALQUER_TERMO = 'S' THEN
           queTokProd := queTokProd || ' OR ';
         ELSE
           queTokProd := queTokProd || ' AND ';
         END IF;
     END IF;
     
     queTokProd := queTokProd
     || ' EXISTS ('
	 ||	'     SELECT 1 '
	 ||	'  FROM'
	 ||	'	TSITOKP   P'
	 ||	'	INNER JOIN TSITOK K ON ( P.CODTOK = K.CODTOK )'
	 ||	'  WHERE'
	 ||	'	P.CODPROD = PRO.CODPROD'
	 ||	'	AND K.CONTEUDO LIKE ''%'||currentTermo||'%'''
	 ||	') ';
     
     usaOperador := 'S';
     
   END LOOP;

   CLOSE curTermo;
   
   --RAISE_APPLICATION_ERROR(-20101, queTokProd);
   
   OPEN curTokProd FOR queTokProd;

   LOOP   
     FETCH curTokProd INTO codProd;
     
     EXIT WHEN curTokProd%NOTFOUND;
     
     PIPE ROW (PIPELINED_PROD(codprod));
     
   END LOOP;

   CLOSE curTokProd;

  RETURN;  
END;
