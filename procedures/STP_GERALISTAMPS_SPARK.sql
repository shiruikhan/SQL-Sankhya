create or replace PROCEDURE          STP_GERALISTAMPS_SPARK (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_GERALISTAMPS_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Gera pedidos de requisição (TOP 402) automaticamente para
                   materiais com requisição ativa em planos de produção,
                   utilizando quantidade calculada de matérias-primas e
                   localizações de baixa do apontamento de produção.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução (usado por ACT_TXT_PARAM / ACT_INT_FIELD)
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Anterior a Abr/2025 (primeiro versionamento em 22/04/2025)
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Outubro/2026 — Inclusão do processo CODPRC 1003 na geração;
                   mensagem ao usuário informa planos sem pedido gerado e o
                   motivo (diagnóstico etapa a etapa dos filtros)
==============================================================================*/
       FIELD_NUMPS NUMBER;
       P_NUNOTA                INT;
       P_MAXNUNOTA             INT;
       P_CODTIPOPER             INT;
       P_CODEMP                   INT;
       P_DATA                     DATE;
       P_CODPARC                 INT;
       P_DHTIPOPER             DATE;
       P_CODLOCAL                INT;
       P_DESCRLOCAL      VARCHAR2(100);
       P_COUNT           INT;
       P_NUMNOTA         NUMBER;

       -- Controle de geração e retorno ao usuário
       V_QTDPED_PLANO    NUMBER := 0;             -- pedidos gerados no plano corrente
       V_QTDPED_TOTAL    NUMBER := 0;             -- pedidos gerados em toda a execução
       V_DETALHE         VARCHAR2(4000);          -- linhas por plano para a mensagem final
       V_MOTIVO          VARCHAR2(1000);

       -- Contadores do diagnóstico (cada um aplica um filtro a mais que o anterior)
       V_QTD_ITENS       NUMBER;
       V_QTD_PROC        NUMBER;
       V_QTD_LPA         NUMBER;
       V_QTD_LMP         NUMBER;
       V_QTD_EST         NUMBER;
       V_QTD_LOC         NUMBER;
       V_QTD_QTDPOS      NUMBER;
       V_PROC_ENCONTR    VARCHAR2(1000);

       CURSOR CUR_LOCAL IS 
       SELECT DISTINCT NVL(EST.CODLOCALBAIXAMP,0), LOC.DESCRLOCAL --CODLOCALORIG
         FROM TPRIMPS I,TPRPRC PRC, TPRLPA LPA, TPRLMP LMP, TGFPRO PRO, TPRATV ATV , TPROEST EST, TGFLOC LOC
        WHERE PRC.IDPROC = I.IDPROC
        AND I.CODPROD = LPA.CODPRODPA
          AND LPA.CODPRODPA = LMP.CODPRODPA
          AND LMP.CODPRODMP = PRO.CODPROD
          AND I.IDPROC = ATV.IDPROC
          AND EST.IDEFX = ATV.IDEFX
          AND LMP.IDEFX = ATV.IDEFX
          AND NVL(LMP.GERAREQUISICAO,'N')='S'
          AND LPA.IDPROC = I.IDPROC
          AND EST.CODLOCALBAIXAMP = LOC.CODLOCAL
          AND EST.TIPOITENS='PA'
          AND PRC.CODPRC IN (3000, 1000, 1001, 1003, 2000)
          AND (LMP.QTDMISTURA*I.QTDPRODUZIRLIQ) > 0
          AND I.NUMPS = FIELD_NUMPS;


BEGIN


       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.

           FIELD_NUMPS := ACT_INT_FIELD(P_IDSESSAO, I, 'NUMPS');

           SELECT DHGERMRP, AD_NUNOTA INTO P_DATA, P_NUNOTA
              FROM TPRMPS
            WHERE NUMPS = FIELD_NUMPS;

            SELECT COUNT(*) INTO P_COUNT  FROM TGFCAB WHERE AD_NUMPS = FIELD_NUMPS;

           IF  P_COUNT > 0 THEN
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML('Ação não permitida!',
                    'Já foi realizado geração Lista Materiais, não é permitido gerar novamente. Caso necessário exclua os pedidos requisição gerados deste plano, execute o MRP e gere a Lista',
                    ''));    
            END IF;


            IF P_DATA IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML('Ação não permitida!',
                    'Atualize a  lista de Materiais para continuar.',
                    'Gere o botão MRP em seguida tente novamente!'));    
            END IF;


            V_QTDPED_PLANO := 0;

            OPEN CUR_LOCAL;
            LOOP
              FETCH CUR_LOCAL INTO P_CODLOCAL, P_DESCRLOCAL;
              EXIT WHEN CUR_LOCAL%NOTFOUND;

                         SELECT MAX(NUNOTA) + 1 INTO P_MAXNUNOTA
                           FROM TGFCAB;

                           P_CODTIPOPER := 402;

                           P_CODEMP := 1;

                           P_CODPARC := 1;

                         SELECT ULTCOD+1 INTO P_NUMNOTA FROM TGFNUM WHERE ARQUIVO LIKE'%402%';

                           SELECT MAX(DHALTER) INTO P_DHTIPOPER 
                             FROM TGFTOP
                           WHERE CODTIPOPER = P_CODTIPOPER;

                           INSERT INTO TGFCAB (NUNOTA, CODEMP, CODCENCUS, NUMNOTA, DTNEG, CODEMPNEGOC, CODPARC, RATEADO, CODVEICULO, CODTIPOPER, DHTIPOPER, TIPMOV, CODTIPVENDA, 
                           DHTIPVENDA, CODVEND, COMISSAO, CODMOEDA, CODOBSPADRAO, VLRSEG, VLRICMSSEG, VLRDESTAQUE, VLRJURO, VLRVENDOR, VLROUTROS, VLREMB, VLRICMSEMB, VLRDESCSERV, 
                           IPIEMB, TIPIPIEMB, VLRDESCTOT, VLRDESCTOTITEM, VLRFRETE, ICMSFRETE, BASEICMSFRETE, TIPFRETE, VLRNOTA, CODPARCTRANSP, QTDVOL, PENDENTE, BASEICMS, VLRICMS, 
                           BASEIPI, VLRIPI, ISSRETIDO, BASEISS, VLRISS, APROVADO, STATUSNOTA, IRFRETIDO, VLRIRF, DTALTER, CODPARCDEST, VLRSUBST, BASESUBSTIT, CODPROJ, NUMCONTRATO, BASEINSS, 
                           VLRINSS, VLRREPREDTOT, PERCDESC, CODPARCREMETENTE, CODPARCCONSIGNATARIO, CODPARCREDESPACHO, CODNAT, TROCO, CODUSUCOMPRADOR, CIF_FOB,  
                           OBSERVACAO, CODUSU, CODUSUINC, AD_NUMPS, AD_CODLOCALDEST)
                           VALUES
                           (P_MAXNUNOTA, P_CODEMP, 0, P_NUMNOTA, P_DATA, P_CODEMP, P_CODPARC, 'N', 0, P_CODTIPOPER, P_DHTIPOPER, 'J', 0, 
                           (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0,0, 'N', 0, 0,
                            0, 0, 'N',  0, 0, 'S', 'L', 'N', 0, SYSDATE, 0, 0, 0, 0, 0 ,0,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 'C',
                            'Local: '|| P_DESCRLOCAL || ' - ' || FIELD_NUMPS, P_CODUSU, P_CODUSU, FIELD_NUMPS, P_CODLOCAL );


                            INSERT INTO TGFITE (NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG, CONTROLE, USOPROD, CODCFO, QTDNEG, QTDENTREGUE, QTDCONFERIDA, VLRUNIT, VLRTOT, VLRCUS, 
                            BASEIPI, VLRIPI, BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT, VLRSUBST, PENDENTE, CODVOL, ATUALESTOQUE, RESERVA, STATUSNOTA, CODVEND, CODEXEC, FATURAR, VLRREPRED, VLRDESCBONIF, PERCDESC)
                            (SELECT P_MAXNUNOTA, RANK () OVER (ORDER BY LMP.CODPRODMP DESC) , P_CODEMP, LMP.CODPRODMP, NVL(PRO.CODLOCALPADRAO,101), NVL(LMP.CONTROLEMP,' '), PRO.USOPROD, 0, SUM(LMP.QTDMISTURA*I.QTDPRODUZIRLIQ), 0, 0, 0.01, 0.01*SUM(LMP.QTDMISTURA*I.QTDPRODUZIRLIQ), 0,
                            0, 0, 0, 0, 0, 0, 0, 'N', PRO.CODVOL, 1, 'S', 'L', 0, 0, 'S', 0, 0, 0
                             FROM TPRIMPS I, TPRPRC PRC, TPRLPA LPA, TPRLMP LMP, TGFPRO PRO, TPRATV ATV , TPROEST EST
                          WHERE PRC.IDPROC = I.IDPROC
                              AND I.CODPROD = LPA.CODPRODPA
                              AND LPA.CODPRODPA = LMP.CODPRODPA
                              AND LMP.CODPRODMP = PRO.CODPROD
                              AND I.IDPROC = ATV.IDPROC
                              AND EST.IDEFX = ATV.IDEFX
                              AND LMP.IDEFX = ATV.IDEFX
                              AND NVL(LMP.GERAREQUISICAO,'N') ='S'
                              AND LPA.IDPROC = I.IDPROC
                              AND EST.TIPOITENS='PA' --- APENAS ATIVIDADE APONTAMENTO
                              AND EST.CODLOCALBAIXAMP = P_CODLOCAL
                              AND PRC.CODPRC IN (3000, 1000, 1001, 1003, 2000) ---GERAR LISTA APENAS DO PROCESSO PRODUTIVO PA, OS DEMAIS PROCESSOS IRÃO GERAR LISTA PELA PRÓPRIA ORDEM. ACRESCENTADO PROCESSO 2000 DO MANUEL PARA GERAR REQUISICAO PARA ENVIO NOTA REMESSA. ACRESCENTADO PROCESSO 1003 (OUT/2026)
                              AND I.NUMPS = FIELD_NUMPS
                              GROUP BY LMP.CODPRODMP, NVL(PRO.CODLOCALPADRAO,101), NVL(LMP.CONTROLEMP,' '), PRO.USOPROD, PRO.CODVOL
                              HAVING SUM(LMP.QTDMISTURA*I.QTDPRODUZIRLIQ) > 0);

                              UPDATE TPRMPS SET AD_NUNOTA = P_MAXNUNOTA
                               WHERE NUMPS = FIELD_NUMPS;

                               UPDATE TGFNUM SET ULTCOD=P_NUMNOTA WHERE ARQUIVO LIKE'%402%';

                               V_QTDPED_PLANO := V_QTDPED_PLANO + 1;

            END LOOP;
            CLOSE CUR_LOCAL;

            V_QTDPED_TOTAL := V_QTDPED_TOTAL + V_QTDPED_PLANO;

            ---------------------------------------------------------------------------
            -- Diagnóstico: plano sem nenhum pedido gerado
            -- Reaplica os filtros da geração um a um (LEFT JOIN em cascata) e
            -- aponta o primeiro que zerou o resultado.
            ---------------------------------------------------------------------------
            IF V_QTDPED_PLANO = 0 THEN

                SELECT  COUNT(I.CODPROD)
                       ,COUNT(PRC.IDPROC)
                       ,COUNT(LPA.CODPRODPA)
                       ,COUNT(LMP.CODPRODMP)
                       ,COUNT(EST.IDEFX)
                       ,COUNT(LOC.CODLOCAL)
                       ,SUM(CASE WHEN LOC.CODLOCAL IS NOT NULL
                                  AND LMP.QTDMISTURA * I.QTDPRODUZIRLIQ > 0
                                 THEN 1 ELSE 0 END)
                  INTO  V_QTD_ITENS
                       ,V_QTD_PROC
                       ,V_QTD_LPA
                       ,V_QTD_LMP
                       ,V_QTD_EST
                       ,V_QTD_LOC
                       ,V_QTD_QTDPOS
                  FROM  TPRIMPS I
                  LEFT JOIN TPRPRC PRC
                         ON PRC.IDPROC = I.IDPROC
                        AND PRC.CODPRC IN (3000, 1000, 1001, 1003, 2000)
                  LEFT JOIN TPRLPA LPA
                         ON LPA.IDPROC    = PRC.IDPROC
                        AND LPA.CODPRODPA = I.CODPROD
                  LEFT JOIN TPRATV ATV
                         ON ATV.IDPROC = LPA.IDPROC
                  LEFT JOIN TPRLMP LMP
                         ON LMP.CODPRODPA = LPA.CODPRODPA
                        AND LMP.IDEFX     = ATV.IDEFX
                        AND NVL(LMP.GERAREQUISICAO, 'N') = 'S'
                  LEFT JOIN TPROEST EST
                         ON EST.IDEFX     = LMP.IDEFX
                        AND EST.TIPOITENS = 'PA'
                  LEFT JOIN TGFLOC LOC
                         ON LOC.CODLOCAL = EST.CODLOCALBAIXAMP
                 WHERE  I.NUMPS = FIELD_NUMPS;

                IF V_QTD_ITENS = 0 THEN
                    V_MOTIVO := 'o plano não possui produtos a produzir.';

                ELSIF V_QTD_PROC = 0 THEN
                    -- Lista os processos que o plano usa, para o usuário ver o que ficou de fora
                    SELECT  LISTAGG(X.CODPRC, ', ') WITHIN GROUP (ORDER BY X.CODPRC)
                      INTO  V_PROC_ENCONTR
                      FROM  (SELECT DISTINCT PRC.CODPRC
                               FROM TPRIMPS I
                              INNER JOIN TPRPRC PRC
                                      ON PRC.IDPROC = I.IDPROC
                              WHERE I.NUMPS = FIELD_NUMPS) X;

                    V_MOTIVO := 'nenhum produto do plano usa processo habilitado para a lista '
                             || '(CODPRC 1000, 1001, 1003, 2000, 3000). Processos do plano: '
                             || NVL(V_PROC_ENCONTR, 'não identificado') || '.';

                ELSIF V_QTD_LPA = 0 THEN
                    V_MOTIVO := 'os produtos do plano não estão cadastrados como PA no processo produtivo (TPRLPA).';

                ELSIF V_QTD_LMP = 0 THEN
                    V_MOTIVO := 'nenhuma matéria-prima da lista dos produtos está marcada para gerar requisição.';

                ELSIF V_QTD_EST = 0 THEN
                    V_MOTIVO := 'as matérias-primas marcadas não estão em atividade de apontamento (itens tipo PA).';

                ELSIF V_QTD_LOC = 0 THEN
                    V_MOTIVO := 'a atividade de apontamento não possui local de baixa de MP válido.';

                ELSIF NVL(V_QTD_QTDPOS, 0) = 0 THEN
                    V_MOTIVO := 'a quantidade calculada das matérias-primas está zerada (qtd. mistura x qtd. a produzir).';

                ELSE
                    V_MOTIVO := 'nenhum item atendeu aos critérios de geração.';
                END IF;

                V_DETALHE := SUBSTR(V_DETALHE || '<br>Plano ' || FIELD_NUMPS
                                    || ': nenhum pedido gerado — ' || V_MOTIVO, 1, 3500);
            ELSE
                V_DETALHE := SUBSTR(V_DETALHE || '<br>Plano ' || FIELD_NUMPS
                                    || ': ' || V_QTDPED_PLANO || ' pedido(s) de requisição gerado(s).', 1, 3500);
            END IF;

/*
SELECT I.CODPROD,  I.QTDPRODUZIRLIQ, LMP.CODPRODMP, LMP.QTDMISTURA, LMP.CODVOL
  FROM TPRIMPS I, TPRLPA LPA, TPRLMP LMP
 WHERE I.CODPROD = LPA.CODPRODPA
    AND LPA.CODPRODPA = LMP.CODPRODPA
    AND I.NUMPS = 1
*/




       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --
 IF V_QTDPED_TOTAL = 0 THEN
     P_MENSAGEM := 'Nenhum pedido de requisição foi gerado.' || V_DETALHE;
 ELSE
     P_MENSAGEM := 'Pedidos de Requisição gerados com sucesso!' || V_DETALHE;
 END IF;


END;