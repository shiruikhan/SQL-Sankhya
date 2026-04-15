/*==============================================================================
  Nome do Script : CARD - PRODUÇÃO DIÁRIA
  Tipo           : Componente BI — Card
  Dashboard      : Produção Diária
  Descrição      : Produção total diária por setor. Exibe soma de todas as
                   unidades apontadas no dia.

  Parâmetros     : Sem parâmetros

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TPRIPROC, TPRPRC

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    FX.DESCRICAO AS SETOR,
    SUM(APA.QTDAPONTADA) AS PRODUCAO
FROM TPRAPA APA
    INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO
    INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV
    INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX
    INNER JOIN TPRIPROC PROC ON TV.IDIPROC = PROC.IDIPROC
    INNER JOIN TPRPRC PRC ON PROC.IDPROC = PRC.IDPROC
WHERE TRUNC(APO.DHAPO) = TRUNC(SYSDATE)
    AND FX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM', 'APONTAMENTO X MONTAGEM DISPLAY')
    AND APO.SITUACAO = 'C'
GROUP BY FX.DESCRICAO
ORDER BY PRODUCAO DESC