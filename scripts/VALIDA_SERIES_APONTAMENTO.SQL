/*==============================================================================
  Nome do Script : VALIDA_SERIES_APONTAMENTO
  Tipo           : Script de diagnóstico (somente leitura)
  Descrição      : Verifica, para todos os apontamentos de uma OP, o estado das
                   séries gravadas em AD_TPRSERAPO e TPRSERPA após a alteração
                   de QTDAPONTADA/QTDFAT em TPRAPA (manual ou pela
                   STP_CORRIGEAPONTAMENTO_SPARK). Cada UPDATE em TPRAPA dispara
                   a TRG_INC_UPD_DLT_TPRAPA_SPARK, que recria TPRSERPA e insere
                   novas séries em AD_TPRSERAPO; este script mostra se isso
                   deixou séries a mais ou repetidas.

                   Consulta 1 — por apontamento (NUAPO/SEQAPA) da OP:
                     LINHAS_AD_TPRSERAPO  — linhas gravadas em AD_TPRSERAPO
                     SERIES_DISTINTAS     — séries diferentes entre essas linhas
                     DIAS_INCLUSAO        — nº de dias distintos de gravação
                                            (>1 indica gravações em momentos
                                            diferentes, ex.: reaplicação)
                     PRIMEIRA/ULTIMA_INC  — janela de gravação
                     SITUACAO             — OK | EXCEDE_QTDAPONTADA (mais linhas
                                            que a quantidade apontada) |
                                            SERIE_REPETIDA (linhas > distintas)
                   Consulta 2 — séries da OP em TPRSERPA por produto, liberação
                   e perda.

  Parâmetros     : Editar a CTE PARAMS abaixo:
                     P_IDIPROC — OP a validar
  Tabelas        : TPRIATV, TPREFX, TPRAPO, TPRAPA, AD_TPRSERAPO, TPRSERPA
                   (leitura)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Outubro/2026
  Última Revisão : Outubro/2026 — Criação do script

  Observações    : - Excedente em AD_TPRSERAPO não é necessariamente erro: a
                     trigger acumula séries a cada alteração do apontamento.
                     Use DIAS_INCLUSAO e as datas para distinguir histórico
                     (gravações anteriores) de reaplicação recente.
                   - Para comparar o efeito de uma correção manual com o da
                     procedure, rode para as duas OPs e compare.
==============================================================================*/

-- Consulta 1: séries por apontamento da OP
WITH PARAMS AS (
    SELECT  33743 AS P_IDIPROC   -- OP a validar
    FROM    DUAL
),
SERIES_APO AS (
    SELECT  SAP.NUAPO
           ,SAP.SEQAPA
           ,COUNT(*)                          AS LINHAS
           ,COUNT(DISTINCT SAP.SERIEPA)       AS DISTINTAS
           ,COUNT(DISTINCT TRUNC(SAP.DTINCLUSAO)) AS DIAS
           ,MIN(SAP.DTINCLUSAO)               AS PRIMEIRA_INC
           ,MAX(SAP.DTINCLUSAO)               AS ULTIMA_INC
    FROM    AD_TPRSERAPO SAP
    GROUP BY SAP.NUAPO
            ,SAP.SEQAPA
)
SELECT  ATV.IDIPROC
       ,EFX.DESCRICAO                  AS ETAPA
       ,APO.NUAPO
       ,APA.SEQAPA
       ,APO.DHAPO
       ,APA.QTDAPONTADA
       ,APA.QTDFAT
       ,NVL(SER.LINHAS, 0)             AS LINHAS_AD_TPRSERAPO
       ,NVL(SER.DISTINTAS, 0)          AS SERIES_DISTINTAS
       ,NVL(SER.DIAS, 0)               AS DIAS_INCLUSAO
       ,SER.PRIMEIRA_INC
       ,SER.ULTIMA_INC
       ,CASE
            WHEN NVL(SER.LINHAS, 0) > APA.QTDAPONTADA THEN 'EXCEDE_QTDAPONTADA'
            WHEN NVL(SER.LINHAS, 0) > NVL(SER.DISTINTAS, 0) THEN 'SERIE_REPETIDA'
            ELSE 'OK'
        END AS SITUACAO
FROM    PARAMS PRM
        INNER JOIN TPRIATV      ATV ON ATV.IDIPROC = PRM.P_IDIPROC
        INNER JOIN TPREFX       EFX ON EFX.IDEFX   = ATV.IDEFX
        INNER JOIN TPRAPO       APO ON APO.IDIATV  = ATV.IDIATV
        INNER JOIN TPRAPA       APA ON APA.NUAPO   = APO.NUAPO
        LEFT  JOIN SERIES_APO   SER ON SER.NUAPO   = APA.NUAPO
                                   AND SER.SEQAPA  = APA.SEQAPA
ORDER BY APO.DHAPO
        ,APO.NUAPO;

-- Consulta 2: séries da OP em TPRSERPA
SELECT  SPA.CODPRODPA
       ,SPA.LIBERADO
       ,SPA.PERDA
       ,COUNT(*)                    AS SERIES
       ,COUNT(DISTINCT SPA.SERIEPA) AS SERIES_DISTINTAS
FROM    TPRSERPA SPA
WHERE   SPA.IDIPROC = 33743   -- mesma OP da CTE PARAMS acima
GROUP BY SPA.CODPRODPA
        ,SPA.LIBERADO
        ,SPA.PERDA
ORDER BY SPA.CODPRODPA
        ,SPA.LIBERADO;
