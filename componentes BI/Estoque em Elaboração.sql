/*==============================================================================
  Nome do Script : Estoque em Elaboração
  Tipo           : Componente BI — Tabela
  Descrição      : Localiza o estoque em elaboração (saldo de PA ainda não
                   apontado) por processo e lote de produção. Permite
                   identificar em qual IDIPROC/NROLOTE está o saldo pendente
                   de um produto acabado específico.
  Parâmetros     : :P_PERIODO.INI e :P_PERIODO.FIN — Período de instalação do
                   processo (TPRIPROC.DHINST)
                   :P_CODPRC — Código(s) do processo produtivo
                   :P_CODPRODPA — Código do produto acabado a localizar
  Tabelas        : TPRIPROC, TPRLPA, TPRIPA, TPRPRC, TGFPRO, TGFCAB, TGFITE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Agosto/2026 — Passou a expor IDIPROC e NROLOTE por lote,
                   com filtro por CODPRODPA, para localizar o estoque em
                   elaboração de um produto específico.
==============================================================================*/

SELECT  PROC.IDIPROC
       ,PROC.NROLOTE
       ,LPA.CODPRODPA
       ,PROPA.DESCRPROD AS DESCRPA
       ,IPA.QTDPRODUZIR
       ,NVL(PROD.QTDPA, 0) AS QTDPA
       ,IPA.QTDPRODUZIR - NVL(PROD.QTDPA, 0) AS SALDOPRODPA
       ,PRC.DESCRABREV AS PROCESSOPROD
       ,PRC.CODPRC AS CODIGOPRC
  FROM TPRIPROC PROC
  INNER JOIN TPRLPA LPA ON (PROC.IDPROC = LPA.IDPROC)
  INNER JOIN TPRIPA IPA ON (IPA.IDIPROC = PROC.IDIPROC AND IPA.CODPRODPA = LPA.CODPRODPA)
  INNER JOIN TGFPRO PROPA ON (PROPA.CODPROD = LPA.CODPRODPA)
  INNER JOIN TPRPRC PRC ON (PRC.IDPROC = PROC.IDPROC)
  LEFT JOIN (SELECT  C.IDIPROC
                    ,NVL(SUM(I.QTDNEG), 0) AS QTDPA
               FROM TGFCAB C
               INNER JOIN TGFITE I ON (C.NUNOTA = I.NUNOTA)
              WHERE C.TIPMOV = 'F'
                AND I.USOPROD = 'V'
                AND I.ATUALESTOQUE = 1
                AND (TRUNC(C.DTNEG) >= :P_PERIODO.INI AND TRUNC(C.DTNEG) <= :P_PERIODO.FIN)
              GROUP BY C.IDIPROC) PROD ON (PROD.IDIPROC = PROC.IDIPROC)
 WHERE (TRUNC(PROC.DHINST) >= :P_PERIODO.INI AND TRUNC(PROC.DHINST) <= :P_PERIODO.FIN)
   AND PRC.CODPRC IN :P_CODPRC
   AND PROC.STATUSPROC IN ('A', 'F')
   AND LPA.CODPRODPA = :P_CODPRODPA
   AND IPA.QTDPRODUZIR - NVL(PROD.QTDPA, 0) > 0
 ORDER BY PROC.IDIPROC
