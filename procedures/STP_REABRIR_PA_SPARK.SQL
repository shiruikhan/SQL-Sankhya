CREATE OR REPLACE PROCEDURE STP_REABRIR_PA_SPARK (
       P_CODUSU    NUMBER,        -- Código do usuário logado
       P_IDSESSAO  VARCHAR2,      -- Identificador da execução (parâmetros/campos)
       P_QTDLINHAS NUMBER,        -- Quantidade de registros selecionados
       P_MENSAGEM  OUT VARCHAR2   -- Mensagem exibida ao usuário ao final
) AS
/*==============================================================================
  Nome do Script : STP_REABRIR_PA_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Reabre o(s) produto(s) acabado(s) de um lote de produção,
                   marcando TPRIPA.CONCLUIDO = 'N'. Usado para destravar
                   apontamentos quando um item de PA fica concluído
                   indevidamente e impede a continuidade das atividades.

                   O botão é acionado a partir da grade de atividades (TPRIATV).
                   Para cada atividade selecionada, o NROLOTE é obtido
                   automaticamente do processo produtivo (TPRIPROC) ao qual a
                   atividade pertence — não é necessário digitar o lote.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)
  Tabelas        : TPRIATV (leitura), TPRIPROC (leitura), TPRIPA (escrita)
  Uso            : Botão de Ação na instância TPRIATV (grade de atividades de
                   produção / Ordem de Produção)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 22/06/2026
  Última Revisão : 22/06/2026 — Criação

  Observações    : NROLOTE é coluna de TEXTO (TPRIPROC.NROLOTE / TPRIPA.NROLOTE).
                   A variável V_NROLOTE é ancorada com %TYPE, então a comparação
                   no WHERE já trata o tipo corretamente (sem aspas/literais
                   manuais). O UPDATE reabre apenas os PAs atualmente concluídos
                   (CONCLUIDO = 'S'), para que a contagem de retorno reflita o
                   que de fato foi alterado.
==============================================================================*/
       V_IDIATV        TPRIATV.IDIATV%TYPE;
       V_NROLOTE       TPRIPROC.NROLOTE%TYPE;
       V_TITULO        VARCHAR2(4000);
       V_MENSAGEM      VARCHAR2(4000);
       V_CONFIRMA      BOOLEAN;
       V_QTDREABERTA   NUMBER := 0;
       V_TOTALREABERTO NUMBER := 0;
BEGIN

       ---------------------------------------------------------------------------
       -- 1. Percorre as atividades selecionadas na grade
       ---------------------------------------------------------------------------
       FOR I IN 1..P_QTDLINHAS
       LOOP
           V_IDIATV := ACT_INT_FIELD(P_IDSESSAO, I, 'IDIATV');

           -----------------------------------------------------------------------
           -- 2. Obtem o NROLOTE do processo produtivo da atividade
           -----------------------------------------------------------------------
           BEGIN
               SELECT  PRC.NROLOTE
                 INTO  V_NROLOTE
                 FROM  TPRIATV   ATV
                INNER JOIN TPRIPROC PRC ON PRC.IDIPROC = ATV.IDIPROC
                WHERE ATV.IDIATV = V_IDIATV;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   V_NROLOTE := NULL;
           END;

           IF V_NROLOTE IS NULL THEN
               RAISE_APPLICATION_ERROR(
                   -20051,
                   '<br><b>Não foi possível localizar o lote (NROLOTE) da atividade IDIATV '
                   || V_IDIATV || '.</b>');
           END IF;

           -----------------------------------------------------------------------
           -- 3. Confirma a reabertura com o usuário
           -----------------------------------------------------------------------
           V_TITULO   := 'Reabertura de Produto Acabado';
           V_MENSAGEM := 'Reabrir (CONCLUIDO = N) os PAs do lote ' || V_NROLOTE || '?';
           V_CONFIRMA := ACT_ESCOLHER_SIMNAO(V_TITULO, V_MENSAGEM, P_IDSESSAO, I) = 'S';

           -----------------------------------------------------------------------
           -- 4. Reabre os produtos acabados do lote (somente os concluídos)
           -----------------------------------------------------------------------
           IF V_CONFIRMA THEN
               UPDATE TPRIPA
                  SET CONCLUIDO = 'N'
                WHERE NROLOTE = V_NROLOTE
                  AND NVL(CONCLUIDO, 'N') = 'S';

               V_QTDREABERTA   := SQL%ROWCOUNT;
               V_TOTALREABERTO := V_TOTALREABERTO + V_QTDREABERTA;
           END IF;

       END LOOP;

       ---------------------------------------------------------------------------
       -- 5. Mensagem de retorno ao usuário
       ---------------------------------------------------------------------------
       IF V_TOTALREABERTO = 0 THEN
           P_MENSAGEM := 'Nenhum item de PA concluído foi encontrado para reabrir.';
       ELSE
           P_MENSAGEM := V_TOTALREABERTO
                         || ' item(ns) de PA reaberto(s) com sucesso (CONCLUIDO = N).';
       END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(
            -20052,
            'Erro ao reabrir PA do lote ' || V_NROLOTE || ': ' || SQLERRM);
END;
