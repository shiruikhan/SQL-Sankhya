create or replace PROCEDURE STP_ATUALIZA_DTPREV_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       FIELD_NUNOTA NUMBER;
       P_COUNT                INT;
       P_SEQUENCIA         INT;
       P_QTDNEG         FLOAT;
       P_DTPREVENT      DATE;

       CURSOR CUR_ITENS IS 
       SELECT SEQUENCIA, QTDNEG 
         FROM TGFITE
       WHERE NUNOTA = FIELD_NUNOTA;

BEGIN


       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.

           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

           SELECT COUNT(*) INTO P_COUNT
             FROM TGFDTP
           WHERE NUNOTA = FIELD_NUNOTA
              AND QTDENTREGUE > 0 ;

              IF P_COUNT > 0 THEN 
              P_MENSAGEM := 'Este Pedido já teve quantidades entregues e só pode ser ajustado individualmente cada item!';
             RETURN;

              END IF;

              SELECT DTPREVENT INTO P_DTPREVENT
                FROM TGFCAB 
              WHERE NUNOTA = FIELD_NUNOTA;


    OPEN CUR_ITENS;
    LOOP
      FETCH CUR_ITENS INTO P_SEQUENCIA, P_QTDNEG;
      EXIT WHEN CUR_ITENS%NOTFOUND;

      SELECT COUNT(*) INTO P_COUNT
        FROM  TGFDTP
      WHERE NUNOTA = FIELD_NUNOTA
          AND SEQUENCIA = P_SEQUENCIA;

          IF P_COUNT > 0 THEN 

          UPDATE TGFDTP SET DTPREV =  P_DTPREVENT
          WHERE NUNOTA = FIELD_NUNOTA
              AND SEQUENCIA = P_SEQUENCIA;

          END IF;

          IF P_COUNT = 0 THEN 

          INSERT INTO TGFDTP (NUNOTA, SEQUENCIA, SEQPREV, DTPREV, QTD, QTDENTREGUE, CODUSU, DTALTER)
          VALUES (FIELD_NUNOTA, P_SEQUENCIA, 1, P_DTPREVENT, P_QTDNEG, 0 , P_CODUSU, SYSDATE);

          END IF;


    END LOOP;
    CLOSE CUR_ITENS;


           P_MENSAGEM := 'Data Prevista de entrega Ajustada!';



-- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --



       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END;