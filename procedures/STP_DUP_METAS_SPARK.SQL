/*==============================================================================
  Nome do Script : STP_DUP_METAS_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 02/03/2026, última alteração em 02/03/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_DUP_METAS_SPARK" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_ANO NUMBER;
       PARAM_MES VARCHAR2(4000);
       FIELD_CODSGRU NUMBER;
       FIELD_ANO NUMBER;
       FIELD_MES VARCHAR2(4000);
       
       -- Contadores para exibir na mensagem final
       V_QTD_SUCESSO NUMBER := 0;
       V_QTD_IGNORADO NUMBER := 0;
BEGIN

       -- Os valores informados pelo formulário de parâmetros, podem ser obtidos com as funções:
       PARAM_ANO := ACT_INT_PARAM(P_IDSESSAO, 'Ano');
       PARAM_MES := ACT_TXT_PARAM(P_IDSESSAO, 'MES');

       -- Validação de segurança: Impede rodar se o usuário não preencher os parâmetros no pop-up
       IF PARAM_ANO IS NULL OR PARAM_MES IS NULL THEN
           RAISE_APPLICATION_ERROR(-20001, 'Por favor, informe o Ano e o Mês de destino na tela de parâmetros.');
       END IF;

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
           
           FIELD_CODSGRU := ACT_INT_FIELD(P_IDSESSAO, I, 'CODSGRU');
           FIELD_ANO := ACT_INT_FIELD(P_IDSESSAO, I, 'ANO');
           FIELD_MES := ACT_TXT_FIELD(P_IDSESSAO, I, 'MES');

           -- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --
           BEGIN
               -- Insere a nova meta copiando os valores da meta selecionada na grade
               INSERT INTO AD_TGSSGM (CODSGRU, ANO, MES, VLRMET, APELIDO)
               SELECT CODSGRU, PARAM_ANO, PARAM_MES, VLRMET, APELIDO
               FROM AD_TGSSGM
               WHERE CODSGRU = FIELD_CODSGRU
                 AND ANO = FIELD_ANO
                 AND MES = FIELD_MES;

               -- Se passou daqui sem erros, a inserção deu certo (e a Trigger de Composição já agiu!)
               V_QTD_SUCESSO := V_QTD_SUCESSO + 1;

           EXCEPTION
               -- DUP_VAL_ON_INDEX trata o erro de quando a meta do novo mês/ano já existe (Violação de PK)
               WHEN DUP_VAL_ON_INDEX THEN
                   V_QTD_IGNORADO := V_QTD_IGNORADO + 1;
           END;

       END LOOP;

       -- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --
       -- Retorna a mensagem de feedback que aparecerá no balãozinho do Sankhya
       IF V_QTD_IGNORADO > 0 THEN
           P_MENSAGEM := 'Processo concluído! ' || V_QTD_SUCESSO || ' metas criadas. ' || 
                         V_QTD_IGNORADO || ' metas ignoradas pois já existiam para ' || PARAM_MES || '/' || PARAM_ANO || '.';
       ELSE
           P_MENSAGEM := 'Sucesso! ' || V_QTD_SUCESSO || ' metas foram duplicadas para ' || PARAM_MES || '/' || PARAM_ANO || '.';
       END IF;

END;
