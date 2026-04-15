/*==============================================================================
  Nome do Script : Producao diaria por colaborador
  Tipo           : Componente BI — Tabela
  Dashboard      : Produção e Produtividade
  Descrição      : Resumo de produção diária por colaborador e setor, agrupado por
                   apontamentos de atividades em diferentes setores de produção.

  Parâmetros     : :P_PERIODO.INI — data inicial (DATE)
                   :P_PERIODO.FIN — data final (DATE)

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN (principais)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    FUN.NOMEFUNC AS COLABORADOR,
    FX.DESCRICAO AS SETOR,
    SUM(APA.QTDAPONTADA) AS PRODUCAO
FROM TPRAPA APA
    INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO 
    INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV 
    INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX 
    LEFT JOIN TFPFUN FUN ON APA.AD_CODFUNC = FUN.CODFUNC
WHERE TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND FX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
GROUP BY FUN.NOMEFUNC, APA.AD_CODFUNC, FX.DESCRICAO
ORDER BY PRODUCAO DESC