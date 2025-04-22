create or replace PROCEDURE STP_INCEMB_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_P_CODPROD VARCHAR2(4000);
       PARAM_P_CODEMB VARCHAR2(4000);
       PARAM_P_PESO       FLOAT;
       FIELD_NUNOTA      NUMBER;
       P_MAXSEQ          INT;
       P_MAXIDCAIXA      INT;
BEGIN

       PARAM_P_CODPROD := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODPROD');
       PARAM_P_CODEMB := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODEMB');
       PARAM_P_PESO := ACT_DEC_PARAM(P_IDSESSAO, 'P_PESO');

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.

           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
           
           SELECT NVL(MAX(SEQ),0) + 1, NVL(MAX(IDCAIXA),0) + 1 INTO P_MAXSEQ, P_MAXIDCAIXA
             FROM AD_EMBPED 
            WHERE NUNOTA = FIELD_NUNOTA;
            
            
           
           INSERT INTO AD_EMBPED (NUNOTA, SEQ, CODPROD, CODPRODEMB, PESOBRUTO, M3, IDCAIXA, TIPO)
           VALUES (FIELD_NUNOTA, P_MAXSEQ, PARAM_P_CODPROD, PARAM_P_CODEMB, PARAM_P_PESO, NULL, P_MAXIDCAIXA, 'A');
           
                   UPDATE TGFCAB 
        SET QTDVOL = (
                SELECT COUNT(DISTINCT IDCAIXA)
                FROM AD_EMBPED 
                WHERE NUNOTA = FIELD_NUNOTA),
           PESO = (                
SELECT SUM(PESOEMB) FROM(
SELECT 
COUNT(DISTINCT IDCAIXA)*SUM(DISTINCT PRO.PESOBRUTO) AS PESOEMB
                FROM AD_EMBPED EMB INNER JOIN TGFPRO PRO ON (EMB.CODPRODEMB = PRO.CODPROD)
                WHERE NUNOTA = FIELD_NUNOTA
                GROUP BY CODPRODEMB
                UNION
SELECT SUM(EMB.PESOBRUTO) AS PESOEMB
                FROM AD_EMBPED EMB
                WHERE NUNOTA = FIELD_NUNOTA 
                ))             
        WHERE NUNOTA = FIELD_NUNOTA;
           
           P_MENSAGEM := 'Embalagem incluida com sucesso!';



-- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --



       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END; 