
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SPARKPRD"."VGFSALDOMRP" ("DTREF", "CODPROD", "QTDPREV", "QTDPRODUZIR", "SALDO") AS 
  SELECT   DTREF,
              CODPROD,
              SUM (QTDPREV) AS QTDPREV,
              SUM (QTDPRODUZIR) AS QTDPRODUZIR,
              SUM (QTDPREV - QTDPRODUZIR) AS SALDO
       FROM   (SELECT   PA.CODPRODPA AS CODPROD,
                        0 AS QTDPREV,
                        (QTDPRODUZIR) AS QTDPRODUZIR,
                        TRUNC (NVL (MPS.DTINICMPS, PROC.DHINST), 'MM') AS DTREF
                 FROM         TPRIPROC PROC
                           INNER JOIN (
                               SELECT NVL(PAL.CODPROD,PA.CODPRODPA) AS CODPRODPA, IDIPROC, CONTROLEPA, QTDPRODUZIR, NROLOTE, CONCLUIDO, DTVAL, DTFAB 
                               FROM TPRIPA PA LEFT JOIN TGFPAL PAL ON (PAL.CODPRODALT = PA.CODPRODPA) ) PA
                           ON (PROC.IDIPROC = PA.IDIPROC)
                        LEFT JOIN
                           TPRMPS MPS
                        ON (PROC.NUMPS = MPS.NUMPS)
                WHERE   STATUSPROC IN ('A', 'F', /*'R',*/ 'P2') --'R' = STATUS PRODUCAO CRIADO, RENAN PEDIU PARA DESCONSIDERAR 18/03/22
                        AND PROC.NUMPS IN
                                 (SELECT   MP.NUMPS
                                    FROM      TPRMPS MPS2
                                           INNER JOIN
                                              TPRIMPS MP
                                           ON (MPS2.NUMPS = MP.NUMPS)
                                   WHERE   MPS2.CODCMPS = MPS.CODCMPS
                                           AND PA.CODPRODPA = MP.CODPROD
                                           AND TRUNC (MPS2.DTINICMPS, 'MM') =
                                                 TRUNC (MPS.DTINICMPS, 'MM'))
               UNION ALL
               SELECT   DISTINCT
                        MET.CODPROD,
                        NVL (QTDPREV, 0) - NVL (QTDREDMET, 0) AS QTDPREV, ---ACRESCENTADO COLUNA PARA REDUZIR A META PARA SITUAÇÕES ONDE SERÁ TRANSPORTADO PARA O PRÓXIMO PERÍODO PARA CRIAR ODENS AGRUPADAS NO MRP, DIONE/RENAN/DAIANE 18/03/22
                        0 AS QTDPRODUZIR,
                        MET.DTREF AS DTREF
                 FROM   AD_TGFMET MET
                WHERE   MET.CODMETA = 3) D
   GROUP BY   DTREF, CODPROD
   ORDER BY   2 ;

