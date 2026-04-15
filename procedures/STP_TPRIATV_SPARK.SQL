create or replace PROCEDURE          STP_TPRIATV_SPARK (
       P_CODUSU NUMBER,        -- CÃ³digo do usuÃ¡rio logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execuÃ§Ã£o. Serve para buscar informaÃ§Ãµes dos parÃ¢metros/campos da execuÃ§Ã£o.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execuÃ§Ã£o.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela serÃ¡ exibida como uma informaÃ§Ã£o ao usuÃ¡rio.
) AS
/*==============================================================================
  Nome do Script : STP_TPRIATV_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Gerencia abertura e fechamento de atividades de produção,
                   validando pré-requisitos e atualizando status com tempo
                   gasto e informações do usuário responsável.

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
       PARAM_NUAPO NUMBER;
       FIELD_IDIATV NUMBER;
       P_REABERTA TPRIATV.AD_REABERTA%TYPE;
       V_TITULO VARCHAR(4000);
       V_MENSAGEM VARCHAR(4000);
       V_INCLUIR BOOLEAN;
       P_COUNTPA    INT;
       P_COUNTMP     INT;
       P_PLANTA      INT;
BEGIN

       -- Os valores informados pelo formulÃ¡rio de parÃ¢metros, podem ser obtidos com as funÃ§Ãµes:
       --     ACT_INT_PARAM
       --     ACT_DEC_PARAM
       --     ACT_TXT_PARAM
       --     ACT_DTA_PARAM
       -- Estas funÃ§Ãµes recebem 2 argumentos:
       --     ID DA SESSÃ¿O - Identificador da execuÃ§Ã£o (Obtido atravÃ©s de P_IDSESSAO))
       --     NOME DO PARAMETRO - Determina qual parametro deve se deseja obter.

       PARAM_NUAPO := ACT_INT_PARAM(P_IDSESSAO, 'NUAPO');

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execuÃ§Ã£o.
      LOOP                    -- A variÃ¡vel "I" representa o registro corrente.
           -- Para obter o valor dos campos utilize uma das seguintes funÃ§Ãµes:
           --     ACT_INT_FIELD (Retorna o valor de um campo tipo NUMÃ¿RICO INTEIRO))
           --     ACT_DEC_FIELD (Retorna o valor de um campo tipo NUMÃ¿RICO DECIMAL))
           --     ACT_TXT_FIELD (Retorna o valor de um campo tipo TEXTO),
           --     ACT_DTA_FIELD (Retorna o valor de um campo tipo DATA)
           -- Estas funÃ§Ãµes recebem 3 argumentos:
           --     ID DA SESSÃ¿O - Identificador da execuÃ§Ã£o (Obtido atravÃ©s do parÃ¢metro P_IDSESSAO))
           --     NÃ¿MERO DA LINHA - Relativo a qual linha selecionada.
           --     NOME DO CAMPO - Determina qual campo deve ser obtido.
           FIELD_IDIATV := ACT_INT_FIELD(P_IDSESSAO, I, 'IDIATV');

           SELECT NVL(AD_REABERTA,'N') INTO P_REABERTA FROM TPRIATV  WHERE IDIATV = FIELD_IDIATV;

        IF P_REABERTA = 'N' THEN 


        V_TITULO := 'Será Reaberta a Atividade' ;
        V_MENSAGEM := 'Deseja continuar?';
        V_INCLUIR := ACT_ESCOLHER_SIMNAO(V_TITULO, V_MENSAGEM, P_IDSESSAO, I) = 'S';

         IF V_INCLUIR THEN

          UPDATE TPRIATV SET DHFINAL=NULL,TEMPOGASTOMIN=0,CODUSUFIN = NULL,AD_REABERTA='S'
          WHERE IDIATV = FIELD_IDIATV;
        END IF;

       END IF;


        SELECT CODPLP
        INTO P_PLANTA
        FROM TPRIPROC
        WHERE IDIPROC = (SELECT IDIPROC FROM TPRIATV WHERE IDIATV = FIELD_IDIATV);

        IF P_REABERTA = 'S' THEN 

          IF P_PLANTA = 1 THEN
            SELECT COUNT(*) INTO P_COUNTPA FROM TGFCAB 
            WHERE IDIPROC = (SELECT IDIPROC FROM TPRIATV WHERE IDIATV = FIELD_IDIATV)
            AND TIPMOV IN ('F');

            SELECT COUNT(*) INTO P_COUNTMP FROM TGFCAB 
            WHERE IDIPROC = (SELECT IDIPROC FROM TPRIATV WHERE IDIATV = FIELD_IDIATV)
            AND TIPMOV NOT IN ('F');

            IF P_COUNTPA = 0 AND P_COUNTMP > 0 THEN
              RAISE_APPLICATION_ERROR(-20101,'<br><br><b>Existe movimentação acessória sem apontamento de PA, favor excluir a mov. de materiais ou refazer o apontamento.</br></b>');
            END IF;
          END IF;

          UPDATE TPRIATV SET DHFINAL=SYSDATE,TEMPOGASTOMIN=round((SYSDATE-DHINICIO) * 1440),CODUSUFIN = P_CODUSU, AD_REABERTA='N'
          WHERE IDIATV = FIELD_IDIATV;

          IF P_COUNTPA = 0 AND P_COUNTMP = 0 THEN  
            UPDATE TPRIPROC SET STATUSPROC = 'C'
            WHERE IDIPROC = (SELECT IDIPROC FROM TPRIATV WHERE IDIATV = FIELD_IDIATV);
          END IF;

        END IF;

--TPRAPO VER SE SERÃ NECESSÃRIO REABRIR O APONTAMENTO PARA EXCLUIR A NOTA DE PRODUÃ¿Ã¿O PELA TELA DE ORDENS DE PRODUÃ¿Ã¿O ABA APONTAMENTOS, CASO SEJA MUDAR O CAMPO SITUACAO DE C PARA P

       END LOOP;

 if V_INCLUIR then
   P_MENSAGEM:= 'Atividade'|| CASE WHEN P_REABERTA='N' THEN ' Reaberta' ELSE ' Fechada' END ||' com Sucesso!';
 end if;

-- <ESCREVA SEU CÃ¿DIGO DE FINALIZAÃ¿Ã¿O AQUI> --



END; 
