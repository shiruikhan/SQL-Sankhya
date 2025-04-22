create or replace PROCEDURE "STP_EXCLUIRFINCOM_SPARK" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       FIELD_NUFECH NUMBER;
       FIELD_SEQUENCIA NUMBER;
       P_NUFIN         INT;
BEGIN



       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.

           FIELD_NUFECH := ACT_INT_FIELD(P_IDSESSAO, I, 'NUFECH');
           FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');

           SELECT NUFIN INTO P_NUFIN
             FROM AD_DBFECHCOMFIN
            WHERE NUFECH = FIELD_NUFECH
              AND SEQUENCIA = FIELD_SEQUENCIA;

              IF P_NUFIN > 0 THEN 

              DELETE FROM TGFFIN 
              WHERE NUFIN = P_NUFIN;

              UPDATE AD_DBFECHCOMFIN SET NUFIN = NULL
               WHERE NUFECH = FIELD_NUFECH
                 AND SEQUENCIA = FIELD_SEQUENCIA;

              P_MENSAGEM := 'Financeiro Excluido!';

              END IF;



-- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --



       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END;