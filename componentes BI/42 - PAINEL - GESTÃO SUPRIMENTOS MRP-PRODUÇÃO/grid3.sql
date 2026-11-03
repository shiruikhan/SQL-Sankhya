/* Formatted on 28/02/2022 19:34:56 (QP5 v5.115.810.9015) */
 
SELECT DADOS.*, OBTEM_TOTAIS_MRP(NUMPS,CODPROD,0,'S') AS SALDOPA_PROD_ANT,
(
SELECT MP.QTDMISTURA FROM TPRPRC PRC INNER JOIN TPRLPA LPA ON (PRC.IDPROC = LPA.IDPROC)
INNER JOIN TPREFX EF ON (EF.IDPROC = LPA.IDPROC)
INNER JOIN TPRLMP MP ON (MP.IDEFX = EF.IDEFX AND MP.CODPRODPA = LPA.CODPRODPA) 
WHERE PRC.CODPRC = DADOS.CODPRC
AND PRC.VERSAO = DADOS.VERSAO
AND MP.CODPRODPA = DADOS.CODPROD
AND MP.CODPRODMP = :A_CODPRODMP) AS QTDFORMULA
FROM (
 SELECT   TPRIMPS.CODPROD,
          TPRIMPS.NUMPS,
           TPRIMPS.QTDPRODUZIRLIQ AS QTDPRODUZIRLIQ,
           (SELECT   NVL (QTDPREV, 0)
              FROM   (SELECT   NVL (QTDPREV, 0) AS QTDPREV
                        FROM   TGFMET MET, TPRMPS MPS
                       WHERE       MET.CODMETA = 3
                               AND MET.CODPROD = TPRIMPS.CODPROD
                               AND MPS.NUMPS = TPRIMPS.NUMPS
                               AND MET.DTREF = TRUNC (MPS.DTFINMPS, 'MM')) D)
              AS AD_QTDPREV,
           (SELECT   NVL (QTDPRODUZIR, 0)
              FROM   (SELECT   SUM (PA.QTDPRODUZIR) AS QTDPRODUZIR
                        FROM         TPRIPROC PROC
                                  INNER JOIN
                                     TPRIPA PA
                                  ON (PROC.IDIPROC = PA.IDIPROC)
                               INNER JOIN
                                  TPRMPS MPS
                               ON (PROC.NUMPS = MPS.NUMPS)
                       WHERE   STATUSPROC IN ('A', 'F', 'R', 'P2')
                               AND PA.CODPRODPA = TPRIMPS.CODPROD
                               AND PROC.NUMPS IN
                                        (SELECT   MP.NUMPS
                                           FROM   TPRMPS MP
                                          WHERE   MP.CODCMPS = MPS.CODCMPS
                                                  AND TRUNC (MP.DTINICMPS, 'MM') =
                                                        TRUNC (MPS.DTINICMPS,
                                                               'MM'))) D)
              AS AD_QTDREAL,
           (SELECT   SUM (QTDPREV - QTDPRODUZIR)
              FROM   (SELECT   0 AS QTDPREV, SUM (QTDPRODUZIR) AS QTDPRODUZIR
                        FROM         TPRIPROC PROC
                                  INNER JOIN
                                     TPRIPA PA
                                  ON (PROC.IDIPROC = PA.IDIPROC)
                               INNER JOIN
                                  TPRMPS MPS
                               ON (PROC.NUMPS = MPS.NUMPS)
                       WHERE   STATUSPROC IN ('A', 'F', 'R', 'P2')
                               AND PA.CODPRODPA = TPRIMPS.CODPROD
                               AND TRUNC (PROC.DHINST, 'MM') =
                                     TRUNC (MPS.DTFINMPS, 'MM')
                      UNION ALL
                      SELECT   NVL (QTDPREV, 0) AS QTDPREV, 0 AS QTDPRODUZIR
                        FROM   TGFMET MET, TPRMPS MPS
                       WHERE       MET.CODMETA = 3
                               AND MET.CODPROD = TPRIMPS.CODPROD
                               AND MPS.NUMPS = TPRIMPS.NUMPS
                               AND MET.DTREF = TRUNC (MPS.DTINICMPS, 'MM')) D)
              AS AD_QTDSALDO,
           (SELECT   P.CODPRC
              FROM   TPRPRC P
             WHERE   P.IDPROC = TPRIMPS.IDPROC)
              AS CODPRC,
           (SELECT   NVL (SUM (IPA.QTDPRODUZIR), 0) AS TOTAL
              FROM         TPRIPA IPA
                        INNER JOIN
                           TPRIPROC IPROC
                        ON (IPA.IDIPROC = IPROC.IDIPROC)
                     INNER JOIN
                        TGFPRO PRO
                     ON (IPA.CODPRODPA = PRO.CODPROD)
             WHERE   IPROC.NUMPS = TPRIMPS.NUMPS
                     AND IPA.CODPRODPA = TPRIMPS.CODPROD
                     AND (PRO.TIPCONTEST IN ('L', 'N')
                          OR (IPA.CONTROLEPA = TPRIMPS.CONTROLE))
                     AND IPROC.STATUSPROC NOT IN ('C', 'F')
                     AND TPRIMPS.SEQIMPSPAI IS NULL
                     AND (TPRIMPS.DTPREVENT IS NULL OR IPROC.DTPREVENT IS NULL
                          OR TRUNC (IPROC.DTPREVENT) =
                               TRUNC (TPRIMPS.DTPREVENT)))
              AS QTDEMOP,
           (SELECT   NVL (SUM (IPA.QTDPRODUZIR), 0) AS QTDPRODUZIR
              FROM         TPRIPA IPA
                        INNER JOIN
                           TPRIPROC IPROC
                        ON (IPA.IDIPROC = IPROC.IDIPROC)
                     INNER JOIN
                        TGFPRO PRO
                     ON (IPA.CODPRODPA = PRO.CODPROD)
             WHERE       IPROC.STATUSPROC IN ('AP', 'P')
                     AND IPROC.NUMPS = TPRIMPS.NUMPS
                     AND IPA.CODPRODPA = TPRIMPS.CODPROD
                     AND (PRO.TIPCONTEST IN ('L', 'N')
                          OR (IPA.CONTROLEPA = TPRIMPS.CONTROLE))
                     AND EXISTS (SELECT   1
                                   FROM   TPRPIPROC PIPROC
                                  WHERE   PIPROC.IDIPROC = IPROC.IDIPROC)
                     AND (TPRIMPS.DTPREVENT IS NULL OR IPROC.DTPREVENT IS NULL
                          OR TRUNC (IPROC.DTPREVENT) =
                               TRUNC (TPRIMPS.DTPREVENT)))
              AS QTDEMPROGRAMACAO,
           (NVL (
               (QTDPRODUZIRLIQ
                - (SELECT   NVL (SUM (IPA.QTDPRODUZIR), 0) AS TOTAL
                     FROM         TPRIPA IPA
                               INNER JOIN
                                  TPRIPROC IPROC
                               ON (IPA.IDIPROC = IPROC.IDIPROC)
                            INNER JOIN
                               TGFPRO PRO
                            ON (IPA.CODPRODPA = PRO.CODPROD)
                    WHERE   IPROC.NUMPS = TPRIMPS.NUMPS
                            AND IPA.CODPRODPA = TPRIMPS.CODPROD
                            AND (PRO.TIPCONTEST IN ('L', 'N')
                                 OR (IPA.CONTROLEPA = TPRIMPS.CONTROLE))
                            AND IPROC.STATUSPROC NOT IN ('C', 'F')
                            AND TPRIMPS.SEQIMPSPAI IS NULL
                            AND (TPRIMPS.DTPREVENT IS NULL
                                 OR IPROC.DTPREVENT IS NULL
                                 OR TRUNC (IPROC.DTPREVENT) =
                                      TRUNC (TPRIMPS.DTPREVENT)))),
               0
            ))
              AS QTDSALDOPRODUZIR,
           (SELECT   P.VERSAO
              FROM   TPRPRC P
             WHERE   P.IDPROC = TPRIMPS.IDPROC)
              AS VERSAO,
           ProcessoProdutivo.DESCRABREV AS l0_DESCRABREV,
           Produto.DECQTD AS l1_DECQTD,
           Produto.DESCRPROD AS l1_DESCRPROD
    FROM         TPRIMPS
              LEFT JOIN
                 (  SELECT   IDPROC, DESCRABREV FROM TPRPRC) ProcessoProdutivo
              ON (TPRIMPS.IDPROC = ProcessoProdutivo.IDPROC)
           LEFT JOIN
              (  SELECT   DESCRPROD, DECQTD, CODPROD FROM TGFPRO) Produto
           ON (TPRIMPS.CODPROD = Produto.CODPROD)
   WHERE   ( (TPRIMPS.NUMPS = :A_NUMPS
              AND EXISTS
                    (SELECT   1
                       FROM   TPRBOM BOM
                      WHERE       CODPRODMP = :A_CODPRODMP
                              AND BOM.NUMPS = TPRIMPS.NUMPS
                              AND BOM.SEQIMPS = TPRIMPS.SEQIMPS)))
           AND (TPRIMPS.CODPROD = :P_CODPRODPA OR :P_CODPRODPA IS NULL)
ORDER BY   DESCRABREV, l1_DESCRPROD) DADOS
