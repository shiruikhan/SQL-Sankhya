/*==============================================================================
  Nome do Script : CARD
  Tipo           : Componente BI — Card
  Dashboard      : CARD - PRODUÇÃO DIÁRIA
  Componente     : CARD
  Descrição      : Card com produção diária por setor — soma de apontamentos do dia atual

  Parâmetros     : Sem parâmetros

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT FX.DESCRICAO AS SETOR, SUM(APA.QTDAPONTADA) AS PRODUCAO
FROM TPRAPA APA INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX
WHERE TRUNC(APO.DHAPO) = TO_CHAR(SYSDATE, 'DD/MM/YYYY') AND FX.DESCRICAO IN ('INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA')
GROUP BY FX.DESCRICAO