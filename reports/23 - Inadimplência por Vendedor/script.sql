/*==============================================================================
  Nome do Script : script
  Tipo           : Query SQL auxiliar de relatório
  Grupo          : 23 - Inadimplência por Vendedor
  Descrição      : Query de suporte ao relatório de inadimplência por vendedor.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT FIN.DTNEG,
    FIN.DTVENC,
    FIN.NUMNOTA,
    FIN.CODPARC,
    PAR.RAZAOSOCIAL,
    FIN.VLRDESDOB,
    FIN.CODTIPTIT,
    TIT.DESCRTIPTIT,
    FIN.CODNAT,
    NAT.DESCRNAT,
    FIN.DHBAIXA,
    FIN.VLRBAIXA,
    (CASE WHEN FIN.PROVISAO='S' THEN 'Provisões' ELSE 'Reais' END) AS PROVREAL,
    FIN.CODTIPOPER,
    TOP.DESCROPER,
    TRUNC(SYSDATE) - FIN.DTVENC AS ATRASO,
    FIN.CODVEND,
    VEN.APELIDO,
    FIN.CODEMP,
    FIN.DESDOBRAMENTO,
    V.VLRLIQUIDO
FROM TGFFIN FIN
    JOIN TGFPAR PAR ON PAR.CODPARC = FIN.CODPARC
    JOIN TGFTIT TIT ON TIT.CODTIPTIT = FIN.CODTIPTIT
    JOIN TGFNAT NAT ON NAT.CODNAT = FIN.CODNAT
    JOIN TGFTOP TOP ON TOP.CODTIPOPER = FIN.CODTIPOPER AND TOP.DHALTER = FIN.DHTIPOPER
    JOIN TGFVEN VEN ON VEN.CODVEND = FIN.CODVEND
    JOIN VGFFIN V ON V.NUFIN = FIN.NUFIN
WHERE FIN.DHBAIXA IS NULL
    AND FIN.RECDESP = 1
    AND FIN.PROVISAO = 'N'
    AND FIN.DTVENC < TRUNC(SYSDATE)
    AND FIN.CODTIPTIT = NVL($P{P_CODTIPTIT}, FIN.CODTIPTIT)
    AND FIN.CODVEND = NVL($P{P_CODVEND}, FIN.CODVEND)
    AND FIN.CODEMP = NVL($P{P_CODEMP}, FIN.CODEMP)
    AND FIN.DTVENC >= NVL($P{P_DTINI}, FIN.DTVENC)
    AND FIN.DTVENC <= NVL($P{P_DTFIN}, FIN.DTVENC)
ORDER BY FIN.CODVEND, PAR.RAZAOSOCIAL, FIN.DTVENC
