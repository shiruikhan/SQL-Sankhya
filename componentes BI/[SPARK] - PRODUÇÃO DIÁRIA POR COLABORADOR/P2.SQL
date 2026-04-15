/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : P2
  Descrição      : Retorna produção diária por colaborador agrupada por setor
                   de trabalho.

  Parâmetros     : :P_PERIODO — período (INI/FIN)
                   :P_STATUSPROC — status do processo
                   :P_IDIPROD — ID do processo produção
                   :P_FINAL — S (finalizados) ou N (em progresso)
                   :P_CODPRC — código do processo (array)

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN, TPRIPROC, TPRPRC

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
    INNER JOIN TPRIPROC PROC ON TV.IDIPROC = PROC.IDIPROC
    INNER JOIN TPRPRC PRC ON PROC.IDPROC = PRC.IDPROC
WHERE TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND FX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
    AND APO.SITUACAO = 'C'
    AND PROC.STATUSPROC IN :P_STATUSPROC
    AND (PROC.IDIPROC = :P_IDIPROD OR :P_IDIPROD IS NULL)
    AND NVL(TV.DHFINAL,TO_DATE('01/01/2099')) = CASE WHEN :P_FINAL='S' THEN NVL(TV.DHFINAL,TO_DATE('01/01/2099')) ELSE TO_DATE('01/01/2099') END
    AND PRC.CODPRC IN :P_CODPRC
GROUP BY FUN.NOMEFUNC, APA.AD_CODFUNC, FX.DESCRICAO
ORDER BY PRODUCAO DESC