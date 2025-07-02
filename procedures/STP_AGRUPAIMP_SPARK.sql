CREATE OR REPLACE PROCEDURE STP_AGRUPAIMP_SPARK (
       P_CODUSU     NUMBER,        -- Código do usuário logado
       P_IDSESSAO   VARCHAR2,      -- Identificador da execução. Usado para obter os parâmetros da execução
       P_QTDLINHAS  NUMBER,        -- Quantidade de registros selecionados
       P_MENSAGEM   OUT VARCHAR2   -- Mensagem retornada ao usuário
) AS
/*==============================================================================
  Nome do Script : STP_AGRUPAIMP_SPARK
  Descrição      : Agrupa registros da tabela TPRIPROC através de um identificador
                   numérico sequencial (AD_AGRUPADORIMP), atribuído a múltiplos registros
                   conforme a seleção feita na interface.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 07/04/2022
  Última Revisão : 02/07/2025
  Melhorias      : Comentários adicionados, validação de duplicidade, tratamento de exceções
==============================================================================*/

       -- Variáveis de trabalho
       FIELD_IDIPROC NUMBER;         -- ID do processo a ser atualizado
       P_AGRUP       NUMBER;         -- Número sequencial de agrupamento
       V_JA_AGRUPADO NUMBER;         -- Indica se o registro já está agrupado

BEGIN
       -- Gera o próximo valor de agrupamento baseado no maior existente na base
       SELECT NVL((SELECT MAX(TO_NUMBER(NVL(AD_AGRUPADORIMP, 0)))
                    FROM TPRIPROC
                   WHERE AD_AGRUPADORIMP IS NOT NULL), 0) + 1
         INTO P_AGRUP
         FROM DUAL;

       -- Percorre os registros selecionados pelo usuário na execução
       FOR I IN 1 .. P_QTDLINHAS LOOP

           -- Obtém o IDIPROC de cada linha selecionada
           FIELD_IDIPROC := ACT_INT_FIELD(P_IDSESSAO, I, 'IDIPROC');

           -- Verifica se o registro já está agrupado
           SELECT COUNT(*) INTO V_JA_AGRUPADO
             FROM TPRIPROC
            WHERE IDIPROC = FIELD_IDIPROC
              AND AD_AGRUPADORIMP IS NOT NULL;

           IF V_JA_AGRUPADO = 0 THEN
               -- Atualiza o agrupador com o número gerado
               UPDATE TPRIPROC
                  SET AD_AGRUPADORIMP = P_AGRUP
                WHERE IDIPROC = FIELD_IDIPROC;
           END IF;

       END LOOP;

       -- Retorna mensagem ao usuário com o número do agrupamento gerado
       P_MENSAGEM := 'Agrupamento: ' || P_AGRUP || ' realizado com sucesso';

EXCEPTION
       WHEN OTHERS THEN
           P_MENSAGEM := 'Erro ao realizar agrupamento: ' || SQLERRM;

END;
