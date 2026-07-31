/*==============================================================================
  Nome do Script : P1
  Tipo           : Componente BI ? Tabela (matriz data x setor)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR SETOR
  Componente     : P1
  Descrição      : Matriz de produção diária por setor no intervalo informado,
                   replicando a planilha usada pelo solicitante: uma linha por
                   dia útil (segunda a sexta) e uma coluna por setor, com a
                   soma de QTDAPONTADA dos apontamentos concluídos.
                   Dias úteis sem apontamento aparecem com colunas zeradas
                   (calendário gerado por CONNECT BY), como na planilha modelo.

                   Regras de negócio:
                   - Somente apontamentos concluídos (APO.SITUACAO = 'C').
                   - 'EXPEDICAO/CONF' é typo legado de 'EXPEDIÇÃO/CONFERENCIA'
                     (decisão registrada no README) ? aqui não entra no modelo,
                     que não possui coluna de expedição.
                   - Coluna DISPLAY soma 'DISPLAY' + 'APONTAMENTO X MONTAGEM
                     DISPLAY' (premissa: mesmo setor físico ? validar com o
                     solicitante).

  Parâmetros     : :P_PERIODO.INI ? data inicial do intervalo
                   :P_PERIODO.FIN ? data final do intervalo

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : Junho/2026 ? Criação inicial; 
==============================================================================*/

WITH CALENDARIO AS (
    -- Um registro por dia útil (seg-sex) do intervalo, mesmo sem produção.
    SELECT  CAST(:P_PERIODO.INI AS DATE) + (LEVEL - 1) AS DT_PRODUCAO
      FROM  DUAL
   CONNECT  BY CAST(:P_PERIODO.INI AS DATE) + (LEVEL - 1)
                   <= CAST(:P_PERIODO.FIN AS DATE)
)
,PRODUCAO AS (
    -- Produção concluída por dia e setor, já normalizando o nome do setor
    SELECT  TRUNC(APO.DHAPO)                                    AS DT_PRODUCAO
           ,CASE
                WHEN FX.DESCRICAO IN ('DISPLAY'
                                     ,'APONTAMENTO X MONTAGEM DISPLAY')
                     THEN 'DISPLAY'
                ELSE FX.DESCRICAO
            END                                                 AS SETOR
           ,SUM(APA.QTDAPONTADA)                                AS QTD
      FROM  TPRAPA APA
            INNER JOIN TPRAPO  APO ON APA.NUAPO  = APO.NUAPO
            INNER JOIN TPRIATV TV  ON APO.IDIATV = TV.IDIATV
            INNER JOIN TPREFX  FX  ON TV.IDEFX   = FX.IDEFX
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
                            ,'APONTAMENTO KIT X DISSIPADOR'
                            ,'APONTAMENTO X MONTAGEM DISPLAY')
     GROUP  BY
            TRUNC(APO.DHAPO)
           ,CASE
                WHEN FX.DESCRICAO IN ('DISPLAY'
                                     ,'APONTAMENTO X MONTAGEM DISPLAY')
                     THEN 'DISPLAY'
                ELSE FX.DESCRICAO
            END
)
SELECT  CAL.DT_PRODUCAO                                                             AS DATAPROD
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'APONTAMENTO INSERSORA' THEN PRD.QTD END), 0) AS INSERSORA
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'APONTAMENTO REVISORA'  THEN PRD.QTD END), 0) AS REVISORA
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'INSERÇÃO'              THEN PRD.QTD END), 0) AS INSERCAO
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'SOLDA'                 THEN PRD.QTD END), 0) AS SOLDA
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'DISSIPADOR'            THEN PRD.QTD END), 0) AS DISSIPADOR
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'TESTE'                 THEN PRD.QTD END), 0) AS TESTE
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'MONTAGEM FINAL'        THEN PRD.QTD END), 0) AS MONTAGEMFINAL
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'APONTAMENTO KIT X DISSIPADOR' THEN PRD.QTD END), 0) AS FURACAO_DISSIPADOR
       ,NVL(SUM(CASE WHEN PRD.SETOR = 'DISPLAY'               THEN PRD.QTD END), 0) AS DISPLAY
       ,NVL(SUM(PRD.QTD), 0)                                                        AS TOTALDIA
  FROM  CALENDARIO CAL
        LEFT JOIN PRODUCAO PRD ON PRD.DT_PRODUCAO = CAL.DT_PRODUCAO
 WHERE  TO_CHAR(CAL.DT_PRODUCAO, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')
            NOT IN ('SAT', 'SUN')
 GROUP  BY
        CAL.DT_PRODUCAO
 ORDER  BY
        CAL.DT_PRODUCAO