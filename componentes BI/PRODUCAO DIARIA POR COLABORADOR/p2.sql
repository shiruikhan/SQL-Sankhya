/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela (resumo por colaborador)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : P2
  Descrição      : Visão agregada por colaborador no intervalo informado:
                   total produzido, dias com apontamento, média por dia ativo,
                   quantidade de setores em que atuou e a lista dos setores
                   (ordenada por volume). Complementa o P1 (detalhe diário).

                   Regras de negócio:
                   - Somente apontamentos concluídos (APO.SITUACAO = 'C').
                   - Colaborador via TPRAPA.AD_CODFUNC (LEFT JOIN) — nulos
                     exibidos como 'NAO IDENTIFICADO'.
                   - 'EXPEDICAO/CONF' somado a 'EXPEDIÇÃO/CONFERENCIA'.
                   - Setores-ruído ('INSERÇÃO 2', 'MONTAGEM FINAL 3') excluídos.
                   - Média diária = total produzido / dias com apontamento do
                     colaborador (não dias corridos do intervalo).

  Parâmetros     : :P_PERIODO.INI  — data inicial do intervalo
                   :P_PERIODO.FIN  — data final do intervalo
                   :P_SETOR        — filtro opcional por setor (contém);
                                     restringe a produção considerada ao setor

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : Junho/2026 — Criação inicial

  Observações    : Períodos anteriores a ~2026 retornam maioria
                   'NAO IDENTIFICADO' (93% do histórico sem AD_CODFUNC).
                   Aliases sem aspas/acento (CORE_E05294); rótulos de
                   exibição no construtor.
==============================================================================*/

WITH PRODUCAO AS (
    -- Produção concluída por colaborador, setor normalizado e dia
    SELECT  NVL(FUN.NOMEFUNC, 'NAO IDENTIFICADO')           AS COLABORADOR
           ,CASE
                WHEN FX.DESCRICAO = 'EXPEDICAO/CONF'
                     THEN 'EXPEDIÇÃO/CONFERENCIA'
                ELSE FX.DESCRICAO
            END                                             AS SETOR
           ,TRUNC(APO.DHAPO)                                AS DT_PRODUCAO
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
            NVL(FUN.NOMEFUNC, 'NAO IDENTIFICADO')
           ,CASE
                WHEN FX.DESCRICAO = 'EXPEDICAO/CONF'
                     THEN 'EXPEDIÇÃO/CONFERENCIA'
                ELSE FX.DESCRICAO
            END
           ,TRUNC(APO.DHAPO)
)
,FILTRADA AS (
    -- Aplica o filtro opcional de setor antes das agregações
    SELECT  PRD.COLABORADOR
           ,PRD.SETOR
           ,PRD.DT_PRODUCAO
           ,PRD.QTD
           ,PRD.APONTAMENTOS
      FROM  PRODUCAO PRD
     WHERE  (PRD.SETOR LIKE '%' || UPPER(:P_SETOR) || '%'
                OR :P_SETOR IS NULL)
)
,POR_SETOR AS (
    -- Total por colaborador x setor — base da lista de setores do resumo
    SELECT  FIL.COLABORADOR
           ,FIL.SETOR
           ,SUM(FIL.QTD)    AS QTD_SETOR
      FROM  FILTRADA FIL
     GROUP  BY
            FIL.COLABORADOR
           ,FIL.SETOR
)
,SETORES AS (
    -- Lista de setores do colaborador, do maior para o menor volume
    SELECT  PSE.COLABORADOR
           ,COUNT(*)                                        AS QTD_SETORES
           ,LISTAGG(PSE.SETOR, ', ')
                WITHIN GROUP (ORDER BY PSE.QTD_SETOR DESC)  AS LISTA_SETORES
      FROM  POR_SETOR PSE
     GROUP  BY
            PSE.COLABORADOR
)
SELECT  FIL.COLABORADOR                                     AS COLABORADOR
       ,SUM(FIL.QTD)                                        AS QTDPRODUZIDA
       ,SUM(FIL.APONTAMENTOS)                               AS QTDAPONTAMENTOS
       ,COUNT(DISTINCT FIL.DT_PRODUCAO)                     AS DIASATIVOS
       ,ROUND(SUM(FIL.QTD)
            / COUNT(DISTINCT FIL.DT_PRODUCAO), 1)           AS MEDIADIARIA
       ,MAX(SET_.QTD_SETORES)                               AS QTDSETORES
       ,MAX(SET_.LISTA_SETORES)                             AS SETORES
  FROM  FILTRADA FIL
        INNER JOIN SETORES SET_ ON FIL.COLABORADOR = SET_.COLABORADOR
 GROUP  BY
        FIL.COLABORADOR
 ORDER  BY
        QTDPRODUZIDA DESC
