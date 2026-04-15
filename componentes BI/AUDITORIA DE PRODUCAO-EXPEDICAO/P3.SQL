/*==============================================================================
  Nome do Script : P3
  Tipo           : Componente BI — Tabela
  Dashboard      : AUDITORIA DE PRODUCAO-EXPEDICAO
  Componente     : P3
  Descrição      : Comparação entre produção apontada e expedição — identifica divergências

  Parâmetros     : :P_DTBASE — data base para comparação

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    COALESCE(P1.CODPROD, P2.CODPROD) AS CODPROD,
    COALESCE(P1.DESCRPROD, P2.DESCRPROD) AS DESCRPROD,
    P1.PRODUCAO AS PRODUCAO_APONTADA,
    P2.PRODUCAO AS EXPEDICAO_RECEBIDA,
    (COALESCE(P1.PRODUCAO, 0) - COALESCE(P2.PRODUCAO, 0)) AS DIFERENCA
FROM
    (SELECT PRO.CODPROD,
            PRO.DESCRPROD,
            SUM(APA.QTDAPONTADA) AS PRODUCAO
     FROM TPRAPA APA
         INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO
         INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV
         INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX
         INNER JOIN TGFPRO PRO ON APA.CODPRODPA = PRO.CODPROD
     WHERE TRUNC(APO.DHAPO) = TO_CHAR(:P_DTBASE, 'DD/MM/YYYY')
         AND FX.DESCRICAO IN ('MONTAGEM FINAL')
     GROUP BY PRO.CODPROD, PRO.DESCRPROD) P1
FULL OUTER JOIN
    (SELECT PRO.CODPROD,
            PRO.DESCRPROD,
            SUM(APA.QTDAPONTADA) AS PRODUCAO
     FROM TPRAPA APA
         INNER JOIN TPRAPO APO ON APA.NUAPO = APO.NUAPO
         INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV
         INNER JOIN TPREFX FX ON TV.IDEFX = FX.IDEFX
         INNER JOIN TGFPRO PRO ON APA.CODPRODPA = PRO.CODPROD
     WHERE TRUNC(APO.DHAPO) = TO_CHAR(:P_DTBASE, 'DD/MM/YYYY')
         AND FX.DESCRICAO IN ('EXPEDIÇÃO/CONFERENCIA')
     GROUP BY PRO.CODPROD, PRO.DESCRPROD) P2
ON P1.CODPROD = P2.CODPROD
WHERE COALESCE(P1.PRODUCAO, 0) != COALESCE(P2.PRODUCAO, 0)
   OR P1.CODPROD IS NULL
   OR P2.CODPROD IS NULL
ORDER BY COALESCE(P1.CODPROD, P2.CODPROD)