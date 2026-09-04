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

                   Regras de negocio:
                     - Apenas titulos a receber (RECDESP = 1), fora de provisao
                       (PROVISAO = 'N') e ainda em aberto (DHBAIXA IS NULL).
                     - Apenas titulos com nosso numero emitido
                       (NOSSONUM IS NOT NULL).
                     - "A VENCER" exige titulo negociado ate ontem
                       (DTNEG <= TRUNC(SYSDATE) - 1), para nao contabilizar
                       boletos gerados no proprio dia.
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
  Ultima Revisao : Setembro/2026 - composicao inicial do componente

  Observacoes    : Snapshot com base em SYSDATE; componente sem parametros.
                   CODTIPTIT: 4 = boleto; 48 = boleto em cartorio.
                   O INNER JOIN com TSICTA restringe aos titulos vinculados a
                   conta bancaria cadastrada (mesma regra do detalhe p2.sql).
==============================================================================*/
WITH BOLETOS AS (
    /*-- Boletos a vencer (em aberto, vencimento futuro) --------------------*/
    SELECT  'A VENCER'          AS STATUS
           ,COUNT(0)            AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)   AS TOTAL
      FROM  TGFFIN FIN
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.DHBAIXA   IS NULL
       AND  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 4
       AND  FIN.NOSSONUM  IS NOT NULL
       AND  FIN.DTVENC    >= TRUNC(SYSDATE)
       AND  FIN.DTNEG     <= TRUNC(SYSDATE) - 1

    UNION ALL
    /*-- Boletos vencidos (em aberto, vencimento passado) ------------------*/
    SELECT  'VENCIDO'           AS STATUS
           ,COUNT(0)            AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)   AS TOTAL
      FROM  TGFFIN FIN
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.DHBAIXA   IS NULL
       AND  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 4
       AND  FIN.NOSSONUM  IS NOT NULL
       AND  FIN.DTVENC     < TRUNC(SYSDATE)

    UNION ALL
    /*-- Boletos em cartorio (titulo protestado) --------------------------*/
    SELECT  'BOLETO EM CARTORIO' AS STATUS
           ,COUNT(0)             AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)    AS TOTAL
      FROM  TGFFIN FIN
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.DHBAIXA   IS NULL
       AND  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 48
       AND  FIN.NOSSONUM  IS NOT NULL
       AND  FIN.DTVENC     < TRUNC(SYSDATE)
)
SELECT  NVL(SUM(CASE WHEN STATUS = 'A VENCER'           THEN CONTAGEM END), 0) AS VENCER_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'A VENCER'           THEN TOTAL    END), 0) AS VENCER_TOT
       ,NVL(SUM(CASE WHEN STATUS = 'VENCIDO'            THEN CONTAGEM END), 0) AS VENCIDO_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'VENCIDO'            THEN TOTAL    END), 0) AS VENCIDO_TOT
       ,NVL(SUM(CASE WHEN STATUS = 'BOLETO EM CARTORIO' THEN CONTAGEM END), 0) AS CARTORIO_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'BOLETO EM CARTORIO' THEN TOTAL    END), 0) AS CARTORIO_TOT
  FROM  BOLETOS
S NOT NULL



GROUP BY FIN.CODCTABCOINT
        ,CTA.DESCRICAO

ORDER BY 1
) TAB