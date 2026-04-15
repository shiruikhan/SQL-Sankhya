create or replace PROCEDURE          "STP_TGFCAB_VINCSERIECONF_SPARK" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_TGFCAB_VINCSERIECONF_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Vincula séries de produtos de uma conferência, inserindo
                   itens de série em conferência aberta sem duplicação.

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
       V_NUCONF     TGFCON2.NUCONF%TYPE;
       V_SEQCONFNEW  INT;
BEGIN

       -- Os valores informados pelo formulário de parâmetros, podem ser obtidos com as funções:
       --     ACT_INT_PARAM
       --     ACT_DEC_PARAM
       --     ACT_TXT_PARAM
       --     ACT_DTA_PARAM
       -- Estas funções recebem 2 argumentos:
       --     ID DA SESSÃO - Identificador da execução (Obtido através de P_IDSESSAO))
       --     NOME DO PARAMETRO - Determina qual parametro deve se deseja obter.


       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
           -- Para obter o valor dos campos utilize uma das seguintes funções:
           --     ACT_INT_FIELD (Retorna o valor de um campo tipo NUMÉRICO INTEIRO))
           --     ACT_DEC_FIELD (Retorna o valor de um campo tipo NUMÉRICO DECIMAL))
           --     ACT_TXT_FIELD (Retorna o valor de um campo tipo TEXTO),
           --     ACT_DTA_FIELD (Retorna o valor de um campo tipo DATA)
           -- Estas funções recebem 3 argumentos:
           --     ID DA SESSÃO - Identificador da execução (Obtido através do parâmetro P_IDSESSAO))
           --     NÚMERO DA LINHA - Relativo a qual linha selecionada.
           --     NOME DO CAMPO - Determina qual campo deve ser obtido.
           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
           
           
       BEGIN
       SELECT NUCONF INTO V_NUCONF FROM TGFCON2 WHERE NUCONF = (SELECT NUCONFATUAL FROM TGFCAB WHERE NUNOTA = FIELD_NUNOTA);
       EXCEPTION WHEN NO_DATA_FOUND THEN
       V_NUCONF := 0;
       END;
           
       IF V_NUCONF > 0 THEN
       
       FOR X IN (SELECT SERIE,S.CODPROD,P.CODVOL FROM TGFSER S INNER JOIN TGFPRO P ON (S.CODPROD = P.CODPROD) WHERE NUNOTA = FIELD_NUNOTA
       AND NOT EXISTS (SELECT 1 FROM TGFCOI2 C WHERE C.NUCONF = V_NUCONF AND C.CODPROD = S.CODPROD AND C.CODBARRA = S.SERIE))
       LOOP
       
       SELECT NVL(MAX(SEQCONF),0)+1 INTO V_SEQCONFNEW FROM TGFCOI2 WHERE NUCONF = V_NUCONF;
       
       INSERT INTO TGFCOI2 (NUCONF,SEQCONF,CODBARRA,CODPROD,CODVOL,QTDCONFVOLPAD,QTDCONF, CONTROLE)
        VALUES (V_NUCONF, V_SEQCONFNEW,X.SERIE, X.CODPROD, X.CODVOL,1,1,' ');
       END LOOP;           
       
       UPDATE TGFCON2 SET STATUS ='F'  WHERE NUCONF =  V_NUCONF;
       
       END IF;

     
-- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --



       END LOOP;


     P_MENSAGEM := CASE WHEN V_NUCONF = 0 THEN 'Não existe Conferência aberta, não é possível inserir série' ELSE 'Itens inseridos com sucesso' END;

-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END; 