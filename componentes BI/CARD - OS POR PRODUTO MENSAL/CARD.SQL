/*==============================================================================
  Nome do Script : CARD - OS POR PRODUTO MENSAL
  Tipo           : Componente BI
  Descrição      : Exibe a quantidade de Ordens de Serviço (OS) de assistência
                   técnica recebidas no mês corrente, agrupadas pelos grupos de
                   produto definidos em AD_TGSSGM / AD_TGSISGM.
                   O vínculo com o grupo é feito via T_CODPROD da OS → TGFPRO
                   → TGFGRU → AD_TGSISGM. O período é determinado pelo campo
                   DTRECEB (data de recebimento da OS). Os totais são separados
                   em EM_ABERTO (DTCONCLUSAO nula) e FINALIZADA (DTCONCLUSAO
                   preenchida), além do TOTAL_OS geral.
  Tabelas        : AD_TGFASS, AD_TGSSGM, AD_TGSISGM, TGFPRO, TGFGRU
  Dependencias   : AD_TGSSGM, AD_TGSISGM

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
==============================================================================*/
SELECT
     M.APELIDO                   AS GRUPO
    ,NVL(OS.EM_ABERTO,  0)       AS EM_ABERTO
    ,NVL(OS.FINALIZADA, 0)       AS FINALIZADA
    ,NVL(OS.TOTAL_OS,   0)       AS TOTAL_OS
FROM AD_TGSSGM M
LEFT JOIN (
    SELECT
         COMP.CODSGRU
        ,COUNT(CASE WHEN ASS.DTCONCLUSAO IS NULL     THEN 1 END) AS EM_ABERTO
        ,COUNT(CASE WHEN ASS.DTCONCLUSAO IS NOT NULL THEN 1 END) AS FINALIZADA
        ,COUNT(ASS.NUMOS)                                         AS TOTAL_OS
    FROM AD_TGFASS ASS
    INNER JOIN TGFPRO     P    ON ASS.T_CODPROD     = P.CODPROD
    INNER JOIN TGFGRU     G    ON P.CODGRUPOPROD     = G.CODGRUPOPROD
    INNER JOIN AD_TGSISGM COMP ON (
        (COMP.TIPO = 'G' AND G.CODGRUPOPROD = COMP.CODGRUPOPROD)
        OR
        (COMP.TIPO = 'P' AND G.CODGRUPAI   = COMP.CODGRUPOPROD)
    )
    WHERE TRUNC(ASS.DTRECEB, 'MM')   = TRUNC(SYSDATE, 'MM')
      AND TRUNC(ASS.DTRECEB, 'YYYY') = TRUNC(SYSDATE, 'YYYY')
      AND COMP.ANO = TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))
      AND COMP.MES = TO_CHAR(SYSDATE, 'MM')
    GROUP BY
        COMP.CODSGRU
) OS ON M.CODSGRU = OS.CODSGRU
WHERE M.ANO = TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))
  AND M.MES = TO_CHAR(SYSDATE, 'MM')
ORDER BY M.APELIDO
