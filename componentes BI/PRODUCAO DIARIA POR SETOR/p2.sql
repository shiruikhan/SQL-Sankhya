/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela (detalhamento)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR SETOR
  Componente     : P2
  Descrição      : Breakdown da produção diária por setor e colaborador no
                   intervalo informado. Complementa o P1 (matriz data x setor)
                   permitindo identificar quem produziu em cada setor/dia.

                   Regras de negócio:
                   - Somente apontamentos concluídos (APO.SITUACAO = 'C').
                   - Mesmos setores do P1 (colunas da planilha modelo); coluna
                     DISPLAY agrega 'DISPLAY' + 'APONTAMENTO X MONTAGEM
                     DISPLAY'.
                   - Colaborador via TPRAPA.AD_CODFUNC (campo custom Spark) em
                     LEFT JOIN: apontamento sem colaborador aparece como
                     'NAO IDENTIFICADO' — nunca filtrar o NULL, pois a maior
                     parte do volume não tem identificação.
                   - A cobertura de AD_CODFUNC varia por setor; setores de
                     baixa cobertura exibirão quase tudo em 'NAO IDENTIFICADO'
                     (comportamento esperado, não é defeito).

  Parâmetros     : :P_PERIODO.INI — data inicial do intervalo
                   :P_PERIODO.FIN — data final do intervalo
                   :P_SETOR      — (opcional) filtro por nome do setor
                   :P_DATA       — (opcional) argumento de ligação do drilldown:
                                   recebe DATAPROD da linha clicada no P1 e
                                   restringe o detalhamento àquele dia

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN, TFPDEP

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : Junho/2026 — Criação inicial; adicionado :P_DATA como
                   argumento de ligação para drilldown a partir do P1

  Observações    : Aliases sem aspas/acento por exigência do metadata do
                   gadget (CORE_E05294); rótulos de exibição configurados no
                   construtor do componente. Binds de período usados apenas em
                   BETWEEN contra DATE — não exigem CAST.
==============================================================================*/

WITH PRODUCAO AS (
    -- Produção concluída por dia, setor (normalizado) e colaborador
    SELECT  TRUNC(APO.DHAPO)                                    AS DT_PRODUCAO
           ,CASE
                WHEN FX.DESCRICAO IN ('DISPLAY'
                                     ,'APONTAMENTO X MONTAGEM DISPLAY')
                     THEN 'DISPLAY'
                WHEN FX.DESCRICAO = 'APONTAMENTO INSERSORA' THEN 'INSERSORA'
                WHEN FX.DESCRICAO = 'APONTAMENTO REVISORA'  THEN 'REVISORA'
                ELSE FX.DESCRICAO
            END                                                 AS SETOR
           ,NVL(FUN.NOMEFUNC, 'NAO IDENTIFICADO')               AS COLABORADOR
           ,NVL(DEP.DESCRDEP, 'NAO IDENTIFICADO')               AS DEPARTAMENTO
           ,SUM(APA.QTDAPONTADA)                                AS QTD
           ,COUNT(DISTINCT APA.NUAPO)                           AS QTDAPONT
      FROM  TPRAPA APA
            INNER JOIN TPRAPO  APO ON APA.NUAPO      = APO.NUAPO
            INNER JOIN TPRIATV TV  ON APO.IDIATV     = TV.IDIATV
            INNER JOIN TPREFX  FX  ON TV.IDEFX       = FX.IDEFX
            LEFT  JOIN TFPFUN  FUN ON APA.AD_CODFUNC = FUN.CODFUNC
            LEFT  JOIN TFPDEP  DEP ON FUN.CODDEP     = DEP.CODDEP
     WHERE  APO.SITUACAO = 'C'
       AND  TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
       AND  FX.DESCRICAO IN ('APONTAMENTO INSERSORA'
                            ,'APONTAMENTO REVISORA'
                            ,'INSERÇÃO'
                            ,'SOLDA'
                            ,'DISSIPADOR'
                            ,'TESTE'
                            ,'MONTAGEM FINAL'
                            ,'DISPLAY'
                            ,'APONTAMENTO X MONTAGEM DISPLAY')
     GROUP  BY
            TRUNC(APO.DHAPO)
           ,CASE
                WHEN FX.DESCRICAO IN ('DISPLAY'
                                     ,'APONTAMENTO X MONTAGEM DISPLAY')
                     THEN 'DISPLAY'
                WHEN FX.DESCRICAO = 'APONTAMENTO INSERSORA' THEN 'INSERSORA'
                WHEN FX.DESCRICAO = 'APONTAMENTO REVISORA'  THEN 'REVISORA'
                ELSE FX.DESCRICAO
            END
           ,NVL(FUN.NOMEFUNC, 'NAO IDENTIFICADO')
           ,NVL(DEP.DESCRDEP, 'NAO IDENTIFICADO')
)
SELECT  PRD.DT_PRODUCAO   AS DATAPROD
       ,PRD.SETOR         AS SETOR
       ,PRD.COLABORADOR   AS COLABORADOR
       ,PRD.DEPARTAMENTO  AS DEPARTAMENTO
       ,PRD.QTD           AS QTDPRODUZIDA
       ,PRD.QTDAPONT      AS QTDAPONTAMENTOS
  FROM  PRODUCAO PRD
 WHERE  (PRD.SETOR LIKE '%' || UPPER(:P_SETOR) || '%' OR :P_SETOR IS NULL)
   AND  (PRD.DT_PRODUCAO = TRUNC(CAST(:A_DATA AS DATE)) OR :A_DATA IS NULL)
 ORDER  BY
        PRD.DT_PRODUCAO
       ,PRD.SETOR
       ,PRD.QTD DESC
