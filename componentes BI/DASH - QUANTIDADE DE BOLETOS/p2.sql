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

                   Data de referencia (DTREF):
                     A francesinha do banco emitida hoje reflete as
                     movimentacoes do ultimo dia util anterior. Como o
                     componente nao tem parametro de data, a posicao e
                     calculada SEMPRE na ultima data util antes de hoje
                     (ontem, ou sexta-feira quando hoje e segunda), para
                     poder ser confrontada com a francesinha.

                   Regras de negocio identicas ao resumo (p1.sql), todas
                   relativas a DTREF:
                     - Apenas titulos a receber (RECDESP = 1), fora de provisao
                       (PROVISAO = 'N').
                     - "Em aberto" apurado na data de referencia:
                       DHBAIXA IS NULL OR DHBAIXA >= DTREF + 1.
                     - Apenas titulos com nosso numero emitido
                       (NOSSONUM IS NOT NULL) e negociados ate DTREF
                       (DTNEG <= DTREF).
                     - A VENCER : DTVENC >= DTREF ; VENCIDO : DTVENC < DTREF.
  Tabelas        : TGFFIN, TSICTA, VGFFIN
  Dependencias   : VGFFIN (view de financeiro - coluna VLRLIQUIDO)
  Uso            : Painel "DASH - QUANTIDADE DE BOLETOS" no Sankhya BI -
                   grade de detalhamento sob o titulo p1.html.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Senior
  Empresa        : Spark Eletronica
  Data de Criacao: Setembro/2026
  Ultima Revisao : Setembro/2026 - data de referencia fixada na ultima data
                   util anterior e "em aberto" apurado ponto-no-tempo, para
                   confronto com a francesinha do banco.

  Observacoes    : Componente sem parametros; DTREF calculada em CTE.
                   CODTIPTIT: 4 = boleto; 48 = boleto em cartorio.
                   DTREF pula apenas sabado e domingo - feriados nao sao
                   tratados (nao ha tabela de feriados disponivel). Havendo
                   cadastro de feriados, incluir na CTE DT_REF.
                   A situacao "em cartorio" usa o CODTIPTIT atual do titulo;
                   protestos ocorridos entre DTREF e hoje nao sao retroagidos.
==============================================================================*/
WITH DT_REF AS (
    /*-- Ultima data util (seg-sex) anterior a hoje ----------------------*/
    SELECT  MAX(D.DIA) AS DTREF
      FROM  (SELECT  TRUNC(SYSDATE) - LEVEL AS DIA
               FROM  DUAL
            CONNECT BY LEVEL <= 10) D
     WHERE  TO_CHAR(D.DIA, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') NOT IN ('SAT', 'SUN')
)
------------------------------------------------------------------------------
-- Boletos a vencer (em aberto na DTREF, vencimento >= DTREF)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'A VENCER'          AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

UNION ALL
------------------------------------------------------------------------------
-- Boletos vencidos (em aberto na DTREF, vencimento < DTREF)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'VENCIDO'           AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

UNION ALL
------------------------------------------------------------------------------
-- Boletos em cartorio (titulo protestado, vencimento < DTREF)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'BOLETO EM CARTORIO' AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

ORDER BY 1, 3
