/*==============================================================================
  Nome do Script : p2
  Tipo           : Componente BI — Tabela
  Dashboard      : CONFERÊNCIA COMPOSIÇÃO PA-PI
  Componente     : P2
  Descrição      : Detalhe de materiais da estrutura — quantidade de mistura e requisição

  Parâmetros     : :A_CODPRC — código do processo
                   :A_IDEFX — código da etapa de fabricação
                   :P_CODPRODPA — código do produto acabado (opcional)
                   :P_CODPRODMP — código do material (opcional)
                   :P_DESCRMP — descrição do material (opcional)
                   :P_PA — filtro PA

  Tabelas        : TPRPRC, TPRATV, TPREFX, TPRLMP, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

WITH ULTIMOPROC AS (
    SELECT CODPRC, MAX(IDPROC) AS IDPROC
    FROM TPRPRC
    GROUP BY CODPRC
)
SELECT DISTINCT PROMP.CODPROD,
    PROMP.DESCRPROD,
    PROMP.CODVOL,
    CASE WHEN :P_PA = 'S' THEN MP.QTDMISTURA END AS QTDMISTURA,
    EFX.IDEFX,
    EFX.DESCRICAO,
    CASE WHEN :P_PA = 'S' THEN MP.CODPRODPA END AS CODPRODPA,
    CASE WHEN :P_PA = 'S' THEN PROPA.DESCRPROD END AS DESCRPA,
    PRC.IDPROC,
    (CASE WHEN MP.GERAREQUISICAO = 'S' THEN 'SIM' ELSE 'NÃO' END) AS GERAREQUISICAO
FROM ULTIMOPROC UP
INNER JOIN TPRPRC PRC ON (PRC.CODPRC = UP.CODPRC AND PRC.IDPROC = UP.IDPROC)
INNER JOIN TPRATV ATV ON (ATV.IDPROC = PRC.IDPROC)
INNER JOIN TPREFX EFX ON (EFX.IDEFX = ATV.IDEFX)
INNER JOIN TPRLMP MP ON (MP.IDEFX = EFX.IDEFX)
INNER JOIN TGFPRO PROMP ON (PROMP.CODPROD = MP.CODPRODMP)
INNER JOIN TGFPRO PROPA ON (PROPA.CODPROD = MP.CODPRODPA)
WHERE PRC.CODPRC IN :A_CODPRC
  AND EFX.IDEFX = :A_IDEFX
  AND (MP.CODPRODPA = :P_CODPRODPA OR :P_CODPRODPA IS NULL)
  AND (MP.CODPRODMP = :P_CODPRODMP OR :P_CODPRODMP IS NULL)
  AND (PROMP.DESCRPROD LIKE '%'||:P_DESCRMP||'%' OR :P_DESCRMP IS NULL)
ORDER BY 1,7
