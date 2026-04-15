create or replace PROCEDURE STP_ATUALIZARVLRMOEDA_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_ATUALIZARVLRMOEDA_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Atualiza valores de itens de nota com cotação de moeda estrangeira,
                   recalculando preço unitário, total e desconto. Aplicável apenas
                   a notas de compra com TOP 2200/2201 (operações em moeda estrangeira).

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução (usado por ACT_TXT_PARAM / ACT_INT_FIELD)
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
       FIELD_NUNOTA   NUMBER;
       PARAM_P_COTACAO FLOAT;
       P_CODTIPOPER      INT;
       P_VLRMOEDA      FLOAT;
BEGIN


   PARAM_P_COTACAO := ACT_DEC_PARAM(P_IDSESSAO, 'P_COTACAO');
   
       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.

           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
           
           SELECT CODTIPOPER, VLRMOEDA INTO P_CODTIPOPER, P_VLRMOEDA
             FROM TGFCAB
            WHERE NUNOTA = FIELD_NUNOTA;
            
           IF P_CODTIPOPER  NOT IN (2200, 2201) THEN 
           
           P_MENSAGEM := 'Não pode ser utilizado com essa TOP!'; 
           
           END IF;
            
           IF P_CODTIPOPER  IN (2200, 2201) THEN 
            
            UPDATE TGFITE SET VLRUNIT = ROUND(VLRUNITMOE * PARAM_P_COTACAO,2),
                               VLRTOT = ROUND(VLRUNITMOE * PARAM_P_COTACAO,2) * QTDNEG,
                              VLRDESC = ROUND((ROUND(VLRUNITMOE * PARAM_P_COTACAO,2) * QTDNEG) * PERCDESC / 100,2)
           WHERE NUNOTA = FIELD_NUNOTA;
           
           UPDATE TGFCAB SET VLRMOEDA = PARAM_P_COTACAO, VLRNOTA = (SELECT SUM(VLRTOT) FROM TGFITE WHERE NUNOTA = FIELD_NUNOTA) 
           WHERE NUNOTA = FIELD_NUNOTA;
           
           UPDATE TGFFIN SET VLRDESDOB = (SELECT SUM(VLRTOT) FROM TGFITE WHERE NUNOTA = FIELD_NUNOTA) 
           WHERE NUNOTA = FIELD_NUNOTA;
                  
           P_MENSAGEM := 'Dados Atualizados!';
                       
           END IF;
           
           
                               



-- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --



       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END;