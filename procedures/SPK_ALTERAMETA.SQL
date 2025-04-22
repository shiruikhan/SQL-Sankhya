create or replace PROCEDURE "SPK_ALTERAMETA" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_NOVADATA DATE;
       FIELD_CODMETA NUMBER;
       FIELD_DTREF DATE;
       FIELD_CODEMP NUMBER;
       FIELD_CODPROD NUMBER;
       P_COUNT  INT DEFAULT 0;
BEGIN

       -- Os valores informados pelo formulário de parâmetros, podem ser obtidos com as funções:
       --     ACT_INT_PARAM
       --     ACT_DEC_PARAM
       --     ACT_TXT_PARAM
       --     ACT_DTA_PARAM
       -- Estas funções recebem 2 argumentos:
       --     ID DA SESSÃO - Identificador da execução (Obtido através de P_IDSESSAO))
       --     NOME DO PARAMETRO - Determina qual parametro deve se deseja obter.

       PARAM_NOVADATA := ACT_DTA_PARAM(P_IDSESSAO, 'NOVADATA');

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
           FIELD_CODMETA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODMETA');
           FIELD_DTREF := ACT_DTA_FIELD(P_IDSESSAO, I, 'DTREF');
           FIELD_CODEMP := ACT_INT_FIELD(P_IDSESSAO, I, 'CODEMP');
           FIELD_CODPROD := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPROD');



            UPDATE AD_TGFMET SET DTREF = PARAM_NOVADATA WHERE DTREF = FIELD_DTREF;
            P_COUNT :=P_COUNT +1;


       END LOOP;




            P_MENSAGEM := 'Total Registros Alterados:' ||P_COUNT ;


END;