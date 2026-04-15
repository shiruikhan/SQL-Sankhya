create or replace PROCEDURE STP_VALIDARCONF_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_VALIDARCONF_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Valida conferências de recebimento verificando integridade
                   de séries/códigos de barras com base na quantidade de
                   itens apontados na nota de origem.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
       FIELD_NUNOTA NUMBER;
       P_NUCONF           INT;
       P_SUCESSO          VARCHAR2(10);
       P_COUNTSER         INT;
       P_COUNTCONF        INT;
       P_COUNT            INT;
       P_SERIE            VARCHAR2(100);
       P_CODPROD          INT;
       
       CURSOR CUR_SER IS
       SELECT CODPROD, SERIE 
         FROM TGFSER
        WHERE NUNOTA = FIELD_NUNOTA;
       
BEGIN


       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
           
           SELECT MAX(NUCONF) INTO P_NUCONF
             FROM TGFCON2
            WHERE NUNOTAORIG = FIELD_NUNOTA;
            
            P_SUCESSO := 'S';
            
            SELECT COUNT(*) INTO P_COUNTSER
              FROM TGFSER 
             WHERE NUNOTA = FIELD_NUNOTA;
             
            SELECT COUNT(*) INTO  P_COUNTCONF
              FROM TGFCOI2
             WHERE NUCONF = P_NUCONF;
             
             IF P_COUNTSER <> P_COUNTCONF THEN 
             
             P_SUCESSO := 'N';
             P_MENSAGEM := 'Quantidade conferida divergente da quantidade da nota!';
             
             END IF;
             
             
             
             OPEN CUR_SER;
             LOOP
             FETCH CUR_SER INTO P_CODPROD, P_SERIE;
             EXIT WHEN CUR_SER%NOTFOUND;
                          
             SELECT COUNT(*) INTO P_COUNT
               FROM TGFCOI2
              WHERE NUCONF = P_NUCONF
                AND CODBARRA = P_SERIE
                AND CODPROD = P_CODPROD;
                
                IF P_COUNT <> 1 THEN 
                
                P_SUCESSO := 'N';
                P_MENSAGEM := 'Conferencia divergente para série: ' || P_SERIE;
                
                END IF;
                          
             END LOOP;
             CLOSE CUR_SER;
             
             
             IF P_SUCESSO = 'S' THEN 
             
             
             UPDATE TGFCON2 SET STATUS = 'F'
             WHERE NUCONF = P_NUCONF; 
             
             
             P_MENSAGEM := 'Conferencia Ajustada!';
             
             END IF;



       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END; 