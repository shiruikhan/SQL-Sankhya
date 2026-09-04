/*==============================================================================
  Nome do Script : DASH - QUANTIDADE DE BOLETOS - P1 (Resumo / Titulo)
  Tipo           : Componente BI
  Descricao      : Consolida a posicao de cobranca dos boletos de recebimento
                   em uma unica linha, para alimentar o titulo HTML do painel
                   (p1.html). Classifica os titulos em tres situacoes e, para
                   cada uma, retorna a quantidade de titulos e o valor liquido
                   somado:
                     - A VENCER           : boleto em aberto, vencimento futuro
                     - VENCIDO            : boleto em aberto, vencimento passado
                     - BOLETO EM CARTORIO : titulo protestado (CODTIPTIT = 48)

                   Data de referencia (DTREF):
                     A francesinha do banco emitida hoje reflete as
                     movimentacoes do ultimo dia util anterior. Como o
                     componente nao tem parametro de data, a posicao e
                     calculada SEMPRE na ultima data util antes de hoje
                     (ontem, ou sexta-feira quando hoje e segunda), para
                     poder ser confrontada com a francesinha.

                   Regras de negocio (todas relativas a DTREF):
                     - Apenas titulos a receber (RECDESP = 1), fora de provisao
                       (PROVISAO = 'N').
                     - "Em aberto" e apurado na data de referencia: entram os
                       titulos ainda nao baixados OU baixados depois de DTREF
                       (DHBAIXA IS NULL OR DHBAIXA >= DTREF + 1), para bater
                       com uma francesinha ja emitida.
                     - Apenas titulos com nosso numero emitido
                       (NOSSONUM IS NOT NULL) e negociados ate DTREF
                       (DTNEG <= DTREF) - exclui boletos gerados hoje, que
                       ainda nao constam na francesinha.
                     - A VENCER : DTVENC >= DTREF ; VENCIDO : DTVENC < DTREF.
  Tabelas        : TGFFIN, TSICTA, VGFFIN
  Dependencias   : VGFFIN (view de financeiro - coluna VLRLIQUIDO)
  Uso            : Painel "DASH - QUANTIDADE DE BOLETOS" no Sankhya BI.
                   Alimenta as variaveis do titulo p1.html:
                   $VENCER_QTD, $VENCER_TOT, $VENCIDO_QTD, $VENCIDO_TOT,
                   $CARTORIO_QTD, $CARTORIO_TOT.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Senior
  Empresa        : Spark Eletronica
  Data de Criacao: Setembro/2026
  Ultima Revisao : Setembro/2026 - data de referencia fixada na ultima data
                   util anterior e "em aberto" apurado ponto-no-tempo, para
                   confronto com a francesinha do banco.

  Observacoes    : Componente sem parametros; DTREF calculada em CTE.
                   CODTIPTIT: 4 = boleto; 48 = boleto em cartorio.
                   O INNER JOIN com TSICTA restringe aos titulos vinculados a
                   conta bancaria cadastrada (mesma regra do detalhe p2.sql).
                   DTREF pula apenas sabado e domingo - feriados nao sao
                   tratados (nao ha tabela de feriados disponivel). Havendo
                   cadastro de feriados, incluir na CTE DT_REF.
                   A situacao "em cartorio" usa o CODTIPTIT atual do titulo;
                   protestos ocorridos entre DTREF e hoje nao sao retroagidos.
==============================================================================*/
WITH DT_REF AS (
    /*-- Ultima data util (seg-sex) anterior a hoje ------------------------*/
    SELECT  MAX(D.DIA) AS DTREF
      FROM  (SELECT  TRUNC(SYSDATE) - LEVEL AS DIA
               FROM  DUAL
            CONNECT BY LEVEL <= 10) D
     WHERE  TO_CHAR(D.DIA, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') NOT IN ('SAT', 'SUN')
),
BOLETOS AS (
    /*-- Boletos a vencer (em aberto na DTREF, vencimento >= DTREF) --------*/
    SELECT  'A VENCER'          AS STATUS
           ,COUNT(0)            AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)   AS TOTAL
      FROM  TGFFIN FIN
            CROSS JOIN DT_REF R
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 4
       AND  FIN.NOSSONUM  IS NOT NULL
       AND (FIN.DHBAIXA   IS NULL OR FIN.DHBAIXA >= R.DTREF + 1)
       AND  FIN.DTNEG     <= R.DTREF
       AND  FIN.DTVENC    >= R.DTREF

    UNION ALL
    /*-- Boletos vencidos (em aberto na DTREF, vencimento < DTREF) --------*/
    SELECT  'VENCIDO'           AS STATUS
           ,COUNT(0)            AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)   AS TOTAL
      FROM  TGFFIN FIN
            CROSS JOIN DT_REF R
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 4
       AND  FIN.NOSSONUM  IS NOT NULL
       AND (FIN.DHBAIXA   IS NULL OR FIN.DHBAIXA >= R.DTREF + 1)
       AND  FIN.DTNEG     <= R.DTREF
       AND  FIN.DTVENC     < R.DTREF

    UNION ALL
    /*-- Boletos em cartorio (titulo protestado, vencimento < DTREF) ------*/
    SELECT  'BOLETO EM CARTORIO' AS STATUS
           ,COUNT(0)             AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)    AS TOTAL
      FROM  TGFFIN FIN
            CROSS JOIN DT_REF R
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 48
       AND  FIN.NOSSONUM  IS NOT NULL
       AND (FIN.DHBAIXA   IS NULL OR FIN.DHBAIXA >= R.DTREF + 1)
       AND  FIN.DTNEG     <= R.DTREF
       AND  FIN.DTVENC     < R.DTREF
)
SELECT  NVL(SUM(CASE WHEN STATUS = 'A VENCER'           THEN CONTAGEM END), 0) AS VENCER_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'A VENCER'           THEN TOTAL    END), 0) AS VENCER_TOT
       ,NVL(SUM(CASE WHEN STATUS = 'VENCIDO'            THEN CONTAGEM END), 0) AS VENCIDO_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'VENCIDO'            THEN TOTAL    END), 0) AS VENCIDO_TOT
       ,NVL(SUM(CASE WHEN STATUS = 'BOLETO EM CARTORIO' THEN CONTAGEM END), 0) AS CARTORIO_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'BOLETO EM CARTORIO' THEN TOTAL    END), 0) AS CARTORIO_TOT
  FROM  BOLETOS
