/*==============================================================================
  Nome do Script : P1
  Tipo           : Componente BI — Tabela (detalhe diário)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : P1
  Descrição      : Produção diária de cada colaborador em seu respectivo setor
                   dentro do intervalo informado. Uma linha por
                   colaborador x setor x dia (granularidade definida no
                   mapeamento — Bloco 6: há rodízio de setor no mesmo dia).

                   Regras de negócio:
                   - Somente apontamentos concluídos (APO.SITUACAO = 'C').
                   - Setor vem do apontamento (TPREFX via TPRIATV), não do
                     departamento cadastral do colaborador (Bloco 4).
                   - Colaborador via TPRAPA.AD_CODFUNC (LEFT JOIN) — nulos
                     exibidos como 'NAO IDENTIFICADO' (concentrados em
                     EXPEDIÇÃO/CONFERENCIA no período recente — Bloco 8).
                   - 'EXPEDICAO/CONF' é typo legado, somado a
                     'EXPEDIÇÃO/CONFERENCIA' (decisão do mapeamento por setor).
                   - Setores-ruído ('INSERÇÃO 2', 'MONTAGEM FINAL 3') excluídos.

  Parâmetros     : :P_PERIODO.INI  — data inicial do intervalo
                   :P_PERIODO.FIN  — data final do intervalo
                   :P_SETOR        — filtro opcional por setor (contém)
                   :P_COLABORADOR  — filtro opcional por colaborador (contém)

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : Junho/2026 — Criação inicial

  Observações    : Períodos anteriores a ~2026 retornam maioria
                   'NAO IDENTIFICADO' (93% do histórico sem AD_CODFUNC —
                   adoção do campo é recente). Aliases sem aspas/acento
                   (CORE_E05294); rótulos de exibição no construtor.
==============================================================================*/

WITH PRODUCAO AS (
    -- Produção concluída por dia, setor normalizado e colaborador
    SELECT  TRUNC(APO.DHAPO)                                AS DT_PRODUCAO
           ,CASE
                WHEN FX.DESCRICAO = 'EXPEDICAO/CONF'
                     THEN 'EXPEDIÇÃO/CONFERENCIA'
                ELSE FX.DESCRICAO
            END                                             AS SETOR
           ,NVL(FUN.NOMEFUNC, 'NAO IDENTIFICADO')           AS COLABORADOR
           ,SUM(APA.QTDAPONTADA)                            AS QTD
           ,COUNT(DISTINCT APA.NUAPO)                       AS APONTAMENTOS
      FROM  TPRAPA APA
            INNER JOIN TPRAPO  APO ON APA.NUAPO      = APO.NUAPO
            INNER JOIN TPRIATV TV  ON APO.IDIATV     = TV.IDIATV
            INNER JOIN TPREFX  FX  ON TV.IDEFX       = FX.IDEFX
            LEFT  JOIN TFPFUN  FUN ON APA.AD_CODFUNC = FUN.CODFUNC
     WHERE  APO.SITUACAO = 'C'
       AND  TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
       AND  FX.DESCRICAO NOT IN ('INSERÇÃO 2', 'MONTAGEM FINAL 3')
     GROUP  BY
            TRUNC(APO.DHAPO)
           ,CASE
                WHEN FX.DESCRICAO = 'EXPEDICAO/CONF'
                     THEN 'EXPEDIÇÃO/CONFERENCIA'
                ELSE FX.DESCRICAO
            END
           ,NVL(FUN.NOMEFUNC, 'NAO IDENTIFICADO')
)
SELECT  PRD.DT_PRODUCAO     AS DATAPROD
       ,PRD.SETOR           AS SETOR
       ,PRD.COLABORADOR     AS COLABORADOR
       ,PRD.QTD             AS QTDPRODUZIDA
       ,PRD.APONTAMENTOS    AS QTDAPONTAMENTOS
  FROM  PRODUCAO PRD
 WHERE  (PRD.SETOR LIKE '%' || UPPER(:P_SETOR) || '%'
            OR :P_SETOR IS NULL)
   AND  (PRD.COLABORADOR LIKE '%' || UPPER(:P_COLABORADOR) || '%'
            OR :P_COLABORADOR IS NULL)
 ORDER  BY
        PRD.DT_PRODUCAO DESC
       ,PRD.SETOR
       ,PRD.QTD DESC
