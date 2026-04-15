/*==============================================================================
  Nome do Script : p2
  Tipo           : Componente BI — Tabela
  Dashboard      : ESTOQUE PRODUÇÃO EM PROCESSO
  Componente     : p2
  Descrição      : Resumo de produção em processo com saldo pendente por lote
                   e processo de manufatura.

  Parâmetros     : :PER.INI e :PER.FIN — Período de análise
                   :P_CODPRC — Código(s) do processo produtivo
                   :A_CODPRODPA — Código do produto acabado para filtro

  Tabelas        : TPRIPROC, TPRLPA, TPRPRC, TPREFX, TPRIPA, TGFPRO, TGFCAB, TGFITE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

WITH PROD AS (
  SELECT C.IDIPROC, NVL(SUM(I.QTDNEG),0) AS QTDPA
  FROM TGFCAB C
  INNER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA
  WHERE C.TIPMOV='F'
    AND I.USOPROD='V'
    AND I.ATUALESTOQUE=1
    AND C.DTNEG BETWEEN :PER.INI AND :PER.FIN
  GROUP BY C.IDIPROC
)
SELECT DISTINCT PROC.IDIPROC,
       PROC.NROLOTE,
       LPA.CODPRODPA,
       PROPA.DESCRPROD AS DESCRPA,
       IPA.QTDPRODUZIR,
       NVL(PROD.QTDPA,0) AS QTDPA,
       IPA.QTDPRODUZIR - NVL(PROD.QTDPA,0) AS SALDOPRODPA,
       PRC.DESCRABREV AS PROCESSOPROD,
       PRC.CODPRC AS CODIGOPRC
FROM TPRIPROC PROC
INNER JOIN TPRLPA LPA ON PROC.IDPROC = LPA.IDPROC
INNER JOIN TPRPRC PRC ON PRC.IDPROC = PROC.IDPROC
INNER JOIN TPREFX FX ON FX.IDPROC = PROC.IDPROC
INNER JOIN TPRIPA IPA ON IPA.IDIPROC = PROC.IDIPROC AND IPA.CODPRODPA = LPA.CODPRODPA
INNER JOIN TGFPRO PROPA ON PROPA.CODPROD = LPA.CODPRODPA
LEFT JOIN PROD ON PROD.IDIPROC = PROC.IDIPROC
WHERE TRUNC(PROC.DHINST) BETWEEN :PER.INI AND :PER.FIN
  AND PRC.CODPRC IN :P_CODPRC
  AND IPA.QTDPRODUZIR - NVL(PROD.QTDPA,0) > 0
  AND IPA.CODPRODPA = :A_CODPRODPA
ORDER BY PROC.IDIPROC
