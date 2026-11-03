SELECT
    TGFMBC.NUBCO                                                    AS NUM_LANCAMENTO,
    TGFMBC.DTLANC                                                   AS DT_LANCAMENTO,
    TGFMBC.DHCONCILIACAO                                            AS DT_CONCILIACAO,
    TGFMBC.NUMDOC                                                   AS NUM_DOCUMENTO,
    TGFMBC.ORIGMOV                                                  AS TIPO_MOVIMENTO,
    CASE TGFMBC.CONCILIADO
        WHEN 'S' THEN 'Conciliado'
        WHEN 'N' THEN 'Pendente'
        ELSE TGFMBC.CONCILIADO
    END                                                             AS STATUS,
    CASE TGFMBC.RECDESP
        WHEN  1 THEN 'Receita'
        WHEN -1 THEN 'Despesa'
    END                                                             AS NATUREZA,
    TGFMBC.VLRLANC                                                  AS VLR_LANCAMENTO,
    TGFMBC.VLRLANC * TGFMBC.RECDESP                                 AS VLR_LIQUIDO,
    TGFMBC.HISTORICO                                                AS HISTORICO,
    TSICTA.DESCRICAO                                                AS CONTA
FROM TGFMBC
INNER JOIN TSICTA ON TSICTA.CODCTABCOINT = TGFMBC.CODCTABCOINT
WHERE TGFMBC.CODCTABCOINT = :P_CONTA
  AND TGFMBC.DTLANC >= :P_PERIODO.INI
  AND TGFMBC.DTLANC <=  :P_PERIODO.FIN
  AND TGFMBC.ORIGMOV IN ('A','D','F','R','S','T')
  AND TGFMBC.RECDESP IN (1, -1)
ORDER BY TGFMBC.DTLANC, TGFMBC.NUBCO
