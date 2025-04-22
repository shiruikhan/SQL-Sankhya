create or replace PROCEDURE          STP_GERALISTAMPS_SPARK_TERC (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
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
          AND PRC.CODPRC IN (3000, 1000,1001,2000)
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


            OPEN CUR_LOCAL;
            LOOP
              FETCH CUR_LOCAL INTO P_CODLOCAL, P_DESCRLOCAL;
              EXIT WHEN CUR_LOCAL%NOTFOUND;

                         SELECT MAX(NUNOTA) + 1 INTO P_MAXNUNOTA
                           FROM TGFCAB;

                           P_CODTIPOPER := 403;

                           P_CODEMP := 1;

                           P_CODPARC := 425;

                         SELECT ULTCOD+1 INTO P_NUMNOTA FROM TGFNUM WHERE ARQUIVO LIKE'%403%';

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
                           (P_MAXNUNOTA, P_CODEMP, 0, P_NUMNOTA, P_DATA, P_CODEMP, P_CODPARC, 'N', 0, P_CODTIPOPER, P_DHTIPOPER, 'J', 99, 
                           (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 99), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            0, 'N', 0, 0, 0, 0, 0, 'S', 0, 0,0, 'N', 0, 0,
                            0, 0, 'N',  0, 0, 'S', 'L', 'N', 0, SYSDATE, 0, 0, 0, 0, 0 ,0,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 'C',
                            'Local: '|| P_DESCRLOCAL|| ' - ' || FIELD_NUMPS, P_CODUSU, P_CODUSU, FIELD_NUMPS, P_CODLOCAL );


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
                              AND PRC.CODPRC IN (3000, 1000,1001,2000) ---GERAR LISTA APENAS DO PROCESSO PRODUTIVO PA, OS DEMAIS PROCESSOS IRÃO GERAR LISTA PELA PRÓPRIA ORDEM. ACRESCENTADO PROCESSO 2000 DO MANUEL PARA GERAR REQUISICAO PARA ENVIO NOTA REMESSA
                              AND I.NUMPS = FIELD_NUMPS
                              GROUP BY LMP.CODPRODMP, NVL(PRO.CODLOCALPADRAO,101), NVL(LMP.CONTROLEMP,' '), PRO.USOPROD, PRO.CODVOL
                              HAVING SUM(LMP.QTDMISTURA*I.QTDPRODUZIRLIQ) > 0);

                              UPDATE TPRMPS SET AD_NUNOTA = P_MAXNUNOTA
                               WHERE NUMPS = FIELD_NUMPS;

                               UPDATE TGFNUM SET ULTCOD=P_NUMNOTA WHERE ARQUIVO LIKE'%403%';


            END LOOP;
            CLOSE CUR_LOCAL;

/*
SELECT I.CODPROD,  I.QTDPRODUZIRLIQ, LMP.CODPRODMP, LMP.QTDMISTURA, LMP.CODVOL
  FROM TPRIMPS I, TPRLPA LPA, TPRLMP LMP
 WHERE I.CODPROD = LPA.CODPRODPA
    AND LPA.CODPRODPA = LMP.CODPRODPA
    AND I.NUMPS = 1
*/




       END LOOP;




-- <ESCREVA SEU CÓDIGO DE FINALIZAÇÃO AQUI> --
 P_MENSAGEM := 'Pedidos de Requisição gerados com sucesso!';


END;