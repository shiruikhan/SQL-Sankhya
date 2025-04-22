create or replace PROCEDURE STP_ALTDADOSPRO_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_P_CODFORN VARCHAR2(4000);
       PARAM_P_LEADTIME NUMBER;
       PARAM_P_ESTMIN FLOAT;
       PARAM_P_ESTMAX FLOAT;
       PARAM_P_AGRUPMIN FLOAT;
       FIELD_CODPROD NUMBER;
BEGIN


       PARAM_P_CODFORN := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODFORN');
       PARAM_P_LEADTIME := ACT_INT_PARAM(P_IDSESSAO, 'P_LEADTIME');
       PARAM_P_ESTMIN := ACT_DEC_PARAM(P_IDSESSAO, 'P_ESTMIN');
       PARAM_P_ESTMAX := ACT_DEC_PARAM(P_IDSESSAO, 'P_ESTMAX');
       PARAM_P_AGRUPMIN := ACT_DEC_PARAM(P_IDSESSAO, 'P_AGRUPMIN');

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.

           FIELD_CODPROD := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPROD');

           IF PARAM_P_CODFORN IS NOT NULL THEN 

           UPDATE TGFPRO SET CODPARCFORN = PARAM_P_CODFORN
           WHERE CODPROD = FIELD_CODPROD;

           END IF;

           IF PARAM_P_LEADTIME IS NOT NULL THEN

           UPDATE TGFPRO SET LEADTIME = PARAM_P_LEADTIME
           WHERE CODPROD = FIELD_CODPROD;

           END IF;

           IF PARAM_P_ESTMIN IS NOT NULL THEN 

           UPDATE TGFPRO SET ESTMIN = PARAM_P_ESTMIN
           WHERE CODPROD = FIELD_CODPROD;           

           END IF;

           IF PARAM_P_ESTMAX IS NOT NULL THEN 

           UPDATE TGFPRO SET ESTMAX = PARAM_P_ESTMAX
           WHERE CODPROD = FIELD_CODPROD;           

           END IF;

           IF PARAM_P_AGRUPMIN IS NOT NULL THEN 

           UPDATE TGFPRO SET AGRUPMIN = PARAM_P_AGRUPMIN
           WHERE CODPROD = FIELD_CODPROD;           

           END IF;

            P_MENSAGEM := 'Dados Atualizados!';


       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END;