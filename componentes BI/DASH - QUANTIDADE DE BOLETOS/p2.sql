/*==============================================================================
  Nome do Script : DASH - QUANTIDADE DE BOLETOS - P2 (Detalhe por Conta)
  Tipo           : Componente BI
  Descricao      : Detalha a posicao de cobranca dos boletos de recebimento
                   por conta bancaria (CODCTABCOINT / TSICTA.DESCRICAO),
                   quebrando cada conta nas tres situacoes de titulo e
                   apresentando a quantidade e o valor liquido somado:
                     - A VENCER           : boleto em aberto, vencimento futuro
                     - VENCIDO            : boleto em aberto, vencimento passado
                     - BOLETO EM CARTORIO : titulo protestado (CODTIPTIT = 48)

                   Regras de negocio identicas ao resumo (p1.sql):
                     - Apenas titulos a receber (RECDESP = 1), fora de provisao
                       (PROVISAO = 'N') e ainda em aberto (DHBAIXA IS NULL).
                     - Apenas titulos com nosso numero emitido
                       (NOSSONUM IS NOT NULL).
                     - "A VENCER" exige titulo negociado ate ontem
                       (DTNEG <= TRUNC(SYSDATE) - 1).
  Tabelas        : TGFFIN, TSICTA, VGFFIN
  Dependencias   : VGFFIN (view de financeiro - coluna VLRLIQUIDO)
  Uso            : Painel "DASH - QUANTIDADE DE BOLETOS" no Sankhya BI -
                   grade de detalhamento sob o titulo p1.html.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Senior
  Empresa        : Spark Eletronica
  Data de Criacao: Setembro/2026
  Ultima Revisao : Setembro/2026 - composicao inicial do componente

  Observacoes    : Snapshot com base em SYSDATE; componente sem parametros.
                   CODTIPTIT: 4 = boleto; 48 = boleto em cartorio.
==============================================================================*/
------------------------------------------------------------------------------
-- Boletos a vencer (em aberto, vencimento futuro)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'A VENCER'          AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

UNION ALL
------------------------------------------------------------------------------
-- Boletos vencidos (em aberto, vencimento passado)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'VENCIDO'           AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

UNION ALL
------------------------------------------------------------------------------
-- Boletos em cartorio (titulo protestado)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'BOLETO EM CARTORIO' AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

ORDER BY 1, 3
 IS NOT NULL



GROUP BY FIN.CODCTABCOINT
        ,CTA.DESCRICAO
ORDER BY 1