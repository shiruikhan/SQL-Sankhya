create or replace NONEDITIONABLE PROCEDURE "EVP_CLASSIFICACTE_SPARK" (
       P_TIPOEVENTO INT,    -- Identifica o tipo de evento
       P_IDSESSAO VARCHAR2, -- Identificador da execução. Serve para buscar informações dos campos da execução.
       P_CODUSU INT         -- Código do usuário logado
) AS
       BEFORE_INSERT INT;
       AFTER_INSERT  INT;
       BEFORE_DELETE INT;
       AFTER_DELETE  INT;
       BEFORE_UPDATE INT;
       AFTER_UPDATE  INT;
       BEFORE_COMMIT INT;
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;
       
/*******************************************************************************
   É possível obter o valor dos campos através das Functions:
   
  EVP_GET_CAMPO_DTA(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS DE DATA
  EVP_GET_CAMPO_INT(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS NUMÉRICOS INTEIROS
  EVP_GET_CAMPO_DEC(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS NUMÉRICOS DECIMAIS
  EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'NOMECAMPO')   -- PARA CAMPOS TEXTO
  
  O primeiro argumento é uma chave para esta execução. O segundo é o nome do campo.
  
  Para os eventos BEFORE UPDATE, BEFORE INSERT e AFTER DELETE todos os campos estarão disponíveis.
  Para os demais, somente os campos que pertencem à PK
  
  * Os campos CLOB/TEXT serão enviados convertidos para VARCHAR(4000)
  
  Também é possível alterar o valor de um campo através das Stored procedures:
  
  EVP_SET_CAMPO_DTA(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UMA DATA
  EVP_SET_CAMPO_INT(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UM NÚMERO INTEIRO
  EVP_SET_CAMPO_DEC(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UM NÚMERO DECIMAL
  EVP_SET_CAMPO_TEXTO(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UM TEXTO
********************************************************************************/

/*     IF P_TIPOEVENTO = BEFORE_INSERT THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "BEFORE INSERT"
       END IF;*/
     IF P_TIPOEVENTO = AFTER_INSERT THEN
             DECLARE
               V_NUNOTA NUMBER;
               V_NEW_TOP NUMBER := NULL;
               V_DHPROCAG DATE;
             BEGIN
               V_NUNOTA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
               
               -- Validação: Captura DHPROCAG da TGFIXN
               BEGIN
                   SELECT DHPROCAG 
                   INTO V_DHPROCAG 
                   FROM TGFIXN 
                   WHERE NUNOTA = V_NUNOTA;
               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       V_DHPROCAG := NULL;
               END;

               FOR R IN (SELECT CODTIPOPER_NFE FROM VW_CTE_AUTORIZADOS WHERE NUNOTA = V_NUNOTA)
               LOOP
                   IF R.CODTIPOPER_NFE = 214 THEN
                       V_NEW_TOP := 225;
                       EXIT; 
                   END IF;
                   
                   IF V_NEW_TOP IS NULL THEN
                       IF R.CODTIPOPER_NFE IN (214, 1125, 1211) THEN
                           V_NEW_TOP := 225;
                       ELSIF R.CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202) THEN
                           V_NEW_TOP := 226;
                       ELSIF R.CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228, 266, 233, 1119, 1108) THEN
                           V_NEW_TOP := 242;
                       ELSIF R.CODTIPOPER_NFE IN (201, 221, 209) THEN
                           V_NEW_TOP := 234;
                       END IF;
                   END IF;
               END LOOP;
               
               -- Só atualiza se V_NEW_TOP foi definido E se DHPROCAG não for nulo
               IF V_NEW_TOP IS NOT NULL AND V_DHPROCAG IS NOT NULL THEN
                   EVP_SET_CAMPO_INT(P_IDSESSAO, 'CODTIPOPER', V_NEW_TOP);
               END IF;
             END;
       END IF;

/*     IF P_TIPOEVENTO = BEFORE_DELETE THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "BEFORE DELETE"
       END IF;*/
/*     IF P_TIPOEVENTO = AFTER_DELETE THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "AFTER DELETE"
       END IF;*/

/*     IF P_TIPOEVENTO = BEFORE_UPDATE THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "BEFORE UPDATE"
       END IF;*/
/*     IF P_TIPOEVENTO = AFTER_UPDATE THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "AFTER UPDATE"
       END IF;*/

/*     IF P_TIPOEVENTO = BEFORE_COMMIT THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "BEFORE COMMIT"
       END IF;*/

END;
