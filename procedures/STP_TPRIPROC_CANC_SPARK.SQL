create or replace PROCEDURE          STP_TPRIPROC_CANC_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_TPRIPROC_CANC_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Permite reabrir e limpar as atividades e apontamentos de
                   uma ordem de produção que estava cancelada, restaurando
                   seu estado operacional.

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
       FIELD_IDIPROC NUMBER;
       V_TITULO VARCHAR(4000);
       V_MENSAGEM VARCHAR(4000);
       V_INCLUIR BOOLEAN;
       P_COUNT  INT;
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
           FIELD_IDIPROC := ACT_INT_FIELD(P_IDSESSAO, I, 'IDIPROC');
           
        SELECT COUNT(*) INTO P_COUNT FROM TPRIPROC WHERE IDIPROC = FIELD_IDIPROC AND STATUSPROC='C'; --CANCELADO
        
           IF P_COUNT = 0 THEN
           
             RAISE_APPLICATION_ERROR(-20101,'<br><br><b>Esta ação só pode ser executada com a OP em situação Cancelada</br></b>');
           END IF;

           
        V_TITULO := 'OP será reaberta e todos apontamentos serão excluídos!' ;
        V_MENSAGEM := 'Deseja continuar?';
        V_INCLUIR := ACT_ESCOLHER_SIMNAO(V_TITULO, V_MENSAGEM, P_IDSESSAO, I) = 'S';
           
       IF V_INCLUIR THEN
       
        DELETE  TPRAMP WHERE NUAPO IN (SELECT NUAPO FROM TPRAPO WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC));

        DELETE TPRAPF WHERE NUAPO IN ( SELECT NUAPO FROM TPRAPO WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC));

        DELETE AD_TPRSERAPO WHERE NUAPO IN (SELECT NUAPO FROM TPRAPO WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC));

        DELETE TPRAPA  WHERE NUAPO IN (SELECT NUAPO FROM TPRAPO WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC));

        DELETE AD_TPRCOI WHERE NUCONF IN (SELECT NUCONF  FROM TPRCONF WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC)) ;

        DELETE TPRCOI WHERE NUCONF IN (SELECT NUCONF  FROM TPRCONF WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC));

        DELETE TPRCONF WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC);

        DELETE TPRAPO WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC) ;

        DELETE TPRMER WHERE IDIPROC =  FIELD_IDIPROC ;

        DELETE TPREIATV WHERE IDIATV IN (SELECT IDIATV FROM TPRIATV WHERE IDIPROC =  FIELD_IDIPROC);

        DELETE TPRIATV WHERE IDIPROC = FIELD_IDIPROC ;

        UPDATE TPRIPROC SET STATUSPROC='R' WHERE IDIPROC = FIELD_IDIPROC;
        
        COMMIT;
        
        END IF;


-- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --



     END LOOP;


  P_MENSAGEM := 'OP '||FIELD_IDIPROC ||' reaberta com sucesso!' ;
  

-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --



END; 