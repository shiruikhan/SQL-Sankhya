/*==============================================================================
  Nome do Script : p1
  Tipo           : Componente BI — Tabela
  Dashboard      : ESTOQUE PRODUÇÃO EM PROCESSO
  Componente     : p1
  Descrição      : Detalhamento de estoque em produção com custos e quantidades
                   pendentes de conclusão por matéria-prima.

  Parâmetros     : :PER.INI e :PER.FIN — Período de análise
                   :P_CODPRC — Código(s) do processo produtivo
                   :P_CODPRODPA — Código do produto acabado (opcional)

  Tabelas        : TPRIPROC, TPRLPA, TPRPRC, TPREFX, TPRLMP, TGFPRO, TGFCAB, TGFITE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

WITH BASE_KEYS AS (
  SELECT DISTINCT MP.CODPRODMP AS CODPRODMP, TRUNC(PROC.DHINST) AS DTINST
  FROM TPRIPROC PROC
  INNER JOIN TPRLPA LPA ON PROC.IDPROC = LPA.IDPROC
  INNER JOIN TPRPRC PRC ON PRC.IDPROC = PROC.IDPROC
  INNER JOIN TPREFX FX ON FX.IDPROC = PROC.IDPROC
  INNER JOIN TPRLMP MP ON MP.IDEFX = FX.IDEFX AND MP.CODPRODPA = LPA.CODPRODPA
  WHERE TRUNC(PROC.DHINST) BETWEEN :PER.INI AND :PER.FIN
    AND PRC.CODPRC IN :P_CODPRC
),
CUSTOS AS (
  SELECT CODPRODMP, DTINST,
         OBTEMCUSTO_SPARK(CODPRODMP,'S',1,'N',0,'N',' ',DTINST,6) AS CUSTO_6,
         OBTEMCUSTO_SPARK(CODPRODMP,'S',1,'N',0,'N',' ',DTINST,1) AS CUSTO_1
  FROM BASE_KEYS
)
  SELECT   CODPRODPA,
           DESCRPA,
          ROUND(SUM(QTDPRODUZIR), 4) AS QTDPRODUZIR,
           CODPRODMP,
           DESCRMP,
          ROUND(AVG(QTDMISTURA), 4) AS QTDMISTURA,
          ROUND(SUM(SALDOPRODPA), 4) AS SALDOPRODPA,
          ROUND(SUM(SALDOMP), 4) AS SALDOMP,
          ROUND(AVG(CUSTOUNITMP), 4) AS CUSTOUNIMP,
          ROUND(AVG(CUSTOSALDOMP), 4) AS CUSTOSALDOMP,
          ROUND(AVG(CUSTOUNITMPGERENCIAL), 4) AS CUSTOUNIMPGERENCIAL,
          ROUND(AVG(CUSTOSALDOMPGERENCIAL), 4) AS CUSTOSALDOMPGERENCIAL,
          ROUND(SUM(NVL(QTDPA, 0)), 4) AS QTDPA
    FROM   (  SELECT   PROC.IDIPROC,
                       LPA.CODPRODPA,
                       PROPA.DESCRPROD AS DESCRPA,
                       IPA.QTDPRODUZIR,
                       MP.CODPRODMP,
                       PROMP.DESCRPROD AS DESCRMP,
                       SUM (MP.QTDMISTURA) AS QTDMISTURA,
                       NVL (PROD.QTDPA, 0) AS QTDPA,
                       IPA.QTDPRODUZIR - NVL (PROD.QTDPA, 0) AS SALDOPRODPA,
                      CAST((IPA.QTDPRODUZIR - NVL(PROD.QTDPA, 0))
                           * SUM(MP.QTDMISTURA) AS NUMBER(20,4)) AS SALDOMP,
                      CAST(ROUND(MAX(CS.CUSTO_6), 4) AS NUMBER(18,4)) AS CUSTOUNITMP,
                      CAST(ROUND(MAX(CS.CUSTO_6)
                           * (IPA.QTDPRODUZIR - NVL(PROD.QTDPA, 0))
                           * SUM(MP.QTDMISTURA), 4) AS NUMBER(20,4)) AS CUSTOSALDOMP,
                      CAST(ROUND(MAX(CS.CUSTO_1), 4) AS NUMBER(18,4)) AS CUSTOUNITMPGERENCIAL,
                      CAST(ROUND(MAX(CS.CUSTO_1)
                           * (IPA.QTDPRODUZIR - NVL(PROD.QTDPA, 0))
                           * SUM(MP.QTDMISTURA), 4) AS NUMBER(20,4)) AS CUSTOSALDOMPGERENCIAL,
                       PRC.DESCRABREV AS PROCESSOPROD,
                       PRC.CODPRC AS CODIGOPRC
                FROM                           TPRIPROC PROC
                                            INNER JOIN
                                               TPRLPA LPA
                                            ON (PROC.IDPROC = LPA.IDPROC)
                                         INNER JOIN
                                            TPRPRC PRC
                                         ON (PRC.IDPROC = PROC.IDPROC)
                                      INNER JOIN
                                         TPREFX FX
                                      ON (FX.IDPROC = PROC.IDPROC)
                                   INNER JOIN
                                   TPRIPA IPA
                                   ON (IPA.IDIPROC = PROC.IDIPROC
                                       AND IPA.CODPRODPA = LPA.CODPRODPA)
                                INNER JOIN
                                   TPRLMP MP
                                ON (MP.IDEFX = FX.IDEFX
                                    AND MP.CODPRODPA = LPA.CODPRODPA)
                             INNER JOIN
                                TGFPRO PROPA
                             ON (PROPA.CODPROD = LPA.CODPRODPA)
                          INNER JOIN
                             TGFPRO PROMP
                          ON (PROMP.CODPROD = MP.CODPRODMP)
                       LEFT JOIN
                          (  SELECT   NVL (SUM (I.QTDNEG), 0) AS QTDPA, C.IDIPROC
                               FROM      TGFCAB C
                                      INNER JOIN
                                         TGFITE I
                                      ON (C.NUNOTA = I.NUNOTA)
                              WHERE       C.TIPMOV = 'F'
                                      AND I.USOPROD = 'V'
                                      AND I.ATUALESTOQUE = 1
                                      AND C.DTNEG BETWEEN :PER.INI AND :PER.FIN
                           GROUP BY   C.IDIPROC) PROD
                       ON (PROD.IDIPROC = PROC.IDIPROC)
                       LEFT JOIN CUSTOS CS ON CS.CODPRODMP = MP.CODPRODMP AND CS.DTINST = TRUNC(PROC.DHINST)
               WHERE   TRUNC (PROC.DHINST) BETWEEN :PER.INI AND :PER.FIN
            AND PRC.CODPRC IN :P_CODPRC
            GROUP BY   PROC.IDIPROC,
                       LPA.CODPRODPA,
                       PROPA.DESCRPROD,
                       IPA.QTDPRODUZIR,
                       MP.CODPRODMP,
                       PROMP.DESCRPROD,
                       NVL (PROD.QTDPA, 0),
                       TRUNC (PROC.DHINST),
                       PRC.DESCRABREV,
                       PRC.CODPRC) DADOS
   WHERE   SALDOMP > 0
AND (CODPRODPA = :P_CODPRODPA OR :P_CODPRODPA IS NULL)
GROUP BY   CODPRODPA,
           DESCRPA,
           CODPRODMP,
           DESCRMP
ORDER BY   SALDOPRODPA DESC, CODPRODPA, CODPRODMP
