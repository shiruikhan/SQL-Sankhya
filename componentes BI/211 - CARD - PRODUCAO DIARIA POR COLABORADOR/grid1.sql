/*==============================================================================
  Nome do Script : CARD - PRODUCAO DIARIA POR COLABORADOR
  Tipo           : Componente BI — Card
  Dashboard      : Produção Diária
  Descrição      : Produção diária por colaborador, agrupada por setor.
                   Exibe total de unidades apontadas no dia.

  Parâmetros     : Sem parâmetros

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN, TPRIPROC, TPRPRC

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    FUN.NOMEFUNC AS COLABORADOR,
    CASE FX.DESCRICAO
        WHEN 'APONTAMENTO INSERSORA'        THEN 'INSERSORA'
        WHEN 'APONTAMENTO REVISORA'         THEN 'REVISORA'
        WHEN 'APONTAMENTO KIT X DISSIPADOR' THEN 'FURAÇÃO DISSIPADOR'
        WHEN 'INSERÇÃO 2'                   THEN 'INSERÇÃO 2'
        WHEN 'MONTAGEM FINAL 3'             THEN 'MONTAGEM FINAL 3'
        WHEN 'EXPEDIÇÃO/CONFERENCIA'        THEN 'EXPEDIÇÃO/CONFERÊNCIA'
        WHEN 'PRODUÇÃO KIT BM'              THEN 'KIT BM'
        ELSE FX.DESCRICAO
    END AS DESCRICAO,
    SUM(APA.QTDAPONTADA) AS PRODUCAO
FROM TPRAPA APA
    INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO
    INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV
    INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX
    LEFT JOIN TFPFUN FUN ON APA.AD_CODFUNC = FUN.CODFUNC
    INNER JOIN TPRIPROC PROC ON TV.IDIPROC = PROC.IDIPROC
    INNER JOIN TPRPRC PRC ON PROC.IDPROC = PRC.IDPROC
WHERE TRUNC(APO.DHAPO) = TRUNC(SYSDATE)
    AND FX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT BM', 'MONTAGEM FINAL 3', 'INSERÇÃO 2', 'APONTAMENTO KIT X DISSIPADOR')
    AND APO.SITUACAO = 'C'
GROUP BY FUN.NOMEFUNC,
    APA.AD_CODFUNC,
    CASE FX.DESCRICAO
        WHEN 'APONTAMENTO INSERSORA'        THEN 'INSERSORA'
        WHEN 'APONTAMENTO REVISORA'         THEN 'REVISORA'
        WHEN 'APONTAMENTO KIT X DISSIPADOR' THEN 'FURAÇÃO DISSIPADOR'
        WHEN 'INSERÇÃO 2'                   THEN 'INSERÇÃO 2'
        WHEN 'MONTAGEM FINAL 3'             THEN 'MONTAGEM FINAL 3'
        WHEN 'EXPEDIÇÃO/CONFERENCIA'        THEN 'EXPEDIÇÃO/CONFERÊNCIA'
        WHEN 'PRODUÇÃO KIT BM'              THEN 'KIT BM'
        ELSE FX.DESCRICAO
    END
ORDER BY PRODUCAO DESC
