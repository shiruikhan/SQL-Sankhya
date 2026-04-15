/*==============================================================================
  Nome do Script : p1
  Tipo           : Componente BI — Tabela
  Dashboard      : CONFERÊNCIA COMPOSIÇÃO PA-PI
  Componente     : P1
  Descrição      : Conferência de estrutura de produtos — etapas, materiais e configuração

  Parâmetros     : :P_CODPRC — códigos de processos
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
SELECT DISTINCT PRC.CODPRC,
    PRC.DESCRABREV,
    EFX.IDEFX,
    EFX.DESCRICAO,
    CASE WHEN :P_PA = 'Z' THEN MP.CODPRODPA END AS CODPRODPA,
    CASE WHEN :P_PA = 'Z' THEN PROPA.DESCRPROD END AS DESCRPA,
    (CASE WHEN MP.GERAREQUISICAO = 'S' THEN 'SIM' ELSE 'NÃO' END) AS GERAREQUISICAO
FROM ULTIMOPROC UP
INNER JOIN TPRPRC PRC ON (PRC.CODPRC = UP.CODPRC AND PRC.IDPROC = UP.IDPROC)
INNER JOIN TPRATV ATV ON (ATV.IDPROC = PRC.IDPROC)
INNER JOIN TPREFX EFX ON (EFX.IDEFX = ATV.IDEFX)
INNER JOIN TPRLMP MP ON (MP.IDEFX = EFX.IDEFX)
INNER JOIN TGFPRO PROMP ON (PROMP.CODPROD = MP.CODPRODMP)
INNER JOIN TGFPRO PROPA ON (PROPA.CODPROD = MP.CODPRODPA)
WHERE PRC.CODPRC IN :P_CODPRC
  AND (MP.CODPRODPA = :P_CODPRODPA OR :P_CODPRODPA IS NULL)
  AND (MP.CODPRODMP = :P_CODPRODMP OR :P_CODPRODMP IS NULL)
  AND (PROMP.DESCRPROD LIKE '%'||:P_DESCRMP||'%' OR :P_DESCRMP IS NULL)
ORDER BY EFX.IDEFX
