create or replace PROCEDURE STP_TPRCOI_SPARK (
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
       P_CODBARRA   TPRCOI.CODBARRA%TYPE;
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
/*     IF P_TIPOEVENTO = AFTER_INSERT THEN
             --DESCOMENTE ESTE BLOCO PARA PROGRAMAR O "AFTER INSERT"
       END IF;*/

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
       
       
       P_CODBARRA := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'CODBARRA') ;
       
    IF P_TIPOEVENTO = BEFORE_INSERT THEN
            
     EVP_SET_CAMPO_TEXTO(P_IDSESSAO,  'CONTROLE', P_CODBARRA) ;
       
       /*

        INSERT INTO TEMP_TPRCOI (NUCONF,CODBARRA,CODPROD,CONTROLE,QTDCONF) 
        VALUES (:NEW.NUCONF,:NEW.CODBARRA,:NEW.CODPROD,:NEW.CONTROLE,:NEW.QTDCONF); */


       
     END IF;

END; 