WITH PARCEIROS AS
(
    /* ============================================================
       BASE DE CLIENTES
       Aqui nascem TODOS os parceiros, inclusive quem nunca vendeu
       ============================================================ */
    SELECT
         PAR.CODPARC
        ,PAR.RAZAOSOCIAL
        ,PAR.CODCID
        ,PAR.CODVEND
        ,NVL(NULLIF(PAR.CODPARCMATRIZ,0), PAR.CODPARC) AS CODGRUPO

    FROM TGFPAR PAR

    INNER JOIN TGFVEN VEN
            ON VEN.CODVEND = PAR.CODVEND

    WHERE VEN.TIPVEND <> 'C'
      AND PAR.CLIENTE = 'S'

      AND (
            :P_CODPARC IS NULL
            OR NVL(NULLIF(PAR.CODPARCMATRIZ,0), PAR.CODPARC) = :P_CODPARC
          )

      /* 
         IMPORTANTE:
         Uso o vendedor cadastrado no PARCEIRO.
         Assim quem nunca vendeu também aparece no filtro.
      */
      AND PAR.CODVEND IN :P_CODVEND

),

GRUPOS AS
(
    /* ============================================================
       UMA LINHA POR GRUPO ECONÔMICO
       ============================================================ */
    SELECT
         P.CODGRUPO

        ,MAX(
            CASE
                WHEN P.CODPARC = P.CODGRUPO
                THEN P.RAZAOSOCIAL
            END
         ) AS GRUPO_ECONOMICO

        ,COUNT(DISTINCT P.CODPARC) AS QTD_CLIENTES_CADASTRADOS

    FROM PARCEIROS P

    GROUP BY
         P.CODGRUPO
),

NOTAS AS
(
    /* ============================================================
       MOVIMENTO DO ANO SELECIONADO
       ============================================================ */
    SELECT
         CAB.NUNOTA
        ,CAB.NUMNOTA
        ,CAB.DTNEG
        ,CAB.CODPARC
        ,P.CODGRUPO
        ,EXTRACT(MONTH FROM CAB.DTNEG) AS MES

        ,(
              NVL(CAB.VLRNOTA,0)
            + NVL(CAB.VLROUTROS,0)
            - NVL(CAB.VLRIPI,0)
            - NVL(CAB.VLRSUBST,0)
            - CASE
                  WHEN CAB.TIPFRETE = 'S'
                  THEN NVL(CAB.VLRFRETE,0)
                  ELSE 0
              END
         ) AS VLRVENDA

    FROM TGFCAB CAB

    INNER JOIN PARCEIROS P
            ON P.CODPARC = CAB.CODPARC

    WHERE CAB.TIPMOV = 'V'

      AND CAB.CODTIPOPER IN (
             1100,
             2200,
             1111,
             1190,
             1124,
             2202
          )

      AND EXTRACT(YEAR FROM CAB.DTNEG) = :P_ANO

      AND (
             CAB.CODEMP = 501
             OR CAB.STATUSNFE <> 'D'
          )
),

PRODUTOS AS
(
    SELECT
         ITE.NUNOTA
        ,SUM(ITE.QTDNEG) AS QTDPRODUTOS
        ,COUNT(DISTINCT ITE.CODPROD) AS QTDPRODUTOS_DISTINTOS

    FROM TGFITE ITE

    WHERE EXISTS
    (
        SELECT 1
          FROM NOTAS N
         WHERE N.NUNOTA = ITE.NUNOTA
    )

    GROUP BY
         ITE.NUNOTA
),

VENDAS AS
(
    SELECT
         N.NUNOTA
        ,N.NUMNOTA
        ,N.DTNEG
        ,N.CODPARC
        ,N.CODGRUPO
        ,N.MES
        ,N.VLRVENDA
        ,NVL(P.QTDPRODUTOS,0) AS QTDPRODUTOS
        ,NVL(P.QTDPRODUTOS_DISTINTOS,0) AS QTDPRODUTOS_DISTINTOS

    FROM NOTAS N

    LEFT JOIN PRODUTOS P
           ON P.NUNOTA = N.NUNOTA
),

ULTIMA_VENDA AS
(
    /* ============================================================
       ÚLTIMA VENDA / PEDIDO
       
       SEM FILTRO DE ANO.
       Conforme solicitado, considera TIPMOV = 'P'.
       ============================================================ */
    SELECT
         P.CODGRUPO
        ,MAX(CAB.DTNEG) AS ULTIMA_VENDA

    FROM PARCEIROS P

    INNER JOIN TGFCAB CAB
            ON CAB.CODPARC = P.CODPARC
           AND CAB.TIPMOV = 'P'

    GROUP BY
         P.CODGRUPO
),

COMERCIAL AS
(
    SELECT
         G.CODGRUPO

        /* NOME DO GRUPO */
        ,NVL(
             G.GRUPO_ECONOMICO,
             MAX(PGRUPO.RAZAOSOCIAL)
         ) AS GRUPO_ECONOMICO

        /* UF DA MATRIZ / GRUPO */
        ,MAX(UF.UF) AS UF

        /* TODOS OS CNPJS CADASTRADOS NO GRUPO */
        ,G.QTD_CLIENTES_CADASTRADOS

        /* CNPJS QUE COMPRARAM NO ANO */
        ,COUNT(DISTINCT V.CODPARC) AS QTD_CLIENTES_COM_COMPRA

        /* ÚLTIMA VENDA HISTÓRICA */
        ,MAX(UV.ULTIMA_VENDA) AS ULTIMA_VENDA

        /* DIAS SEM VENDA */
        ,CASE
            WHEN MAX(UV.ULTIMA_VENDA) IS NULL
            THEN NULL
            ELSE TRUNC(SYSDATE) - TRUNC(MAX(UV.ULTIMA_VENDA))
         END AS DIAS_SEM_VENDA

        /* QUANTIDADE DE VENDAS NO ANO */
        ,COUNT(DISTINCT V.NUNOTA) AS QTD_VENDAS

        /* QUANTIDADE DE PRODUTOS */
        ,NVL(SUM(V.QTDPRODUTOS),0) AS QTD_PRODUTOS_VENDIDOS

        /* JANEIRO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 1
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS JANEIRO

        /* FEVEREIRO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 2
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS FEVEREIRO

        /* MARÇO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 3
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS MARCO

        /* ABRIL */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 4
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS ABRIL

        /* MAIO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 5
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS MAIO

        /* JUNHO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 6
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS JUNHO

        /* JULHO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 7
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS JULHO

        /* AGOSTO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 8
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS AGOSTO

        /* SETEMBRO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 9
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS SETEMBRO

        /* OUTUBRO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 10
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS OUTUBRO

        /* NOVEMBRO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 11
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS NOVEMBRO

        /* DEZEMBRO */
        ,NVL(SUM(
            CASE
                WHEN V.MES = 12
                THEN V.VLRVENDA
                ELSE 0
            END
         ),0) AS DEZEMBRO

        /* TOTAL */
        ,NVL(SUM(V.VLRVENDA),0) AS TOTAL

        /* TICKET MÉDIO */
        ,NVL(
            ROUND(
                SUM(V.VLRVENDA)
                /
                NULLIF(COUNT(DISTINCT V.NUNOTA),0)
            ,2)
         ,0) AS TICKET_MEDIO

        /* MÉDIA PRODUTOS POR VENDA */
        ,NVL(
            ROUND(
                SUM(V.QTDPRODUTOS)
                /
                NULLIF(COUNT(DISTINCT V.NUNOTA),0)
            ,2)
         ,0) AS QTD_MEDIA_PROD_PEDIDO

        /* VALOR MÉDIO POR PRODUTO */
        ,NVL(
            ROUND(
                SUM(V.VLRVENDA)
                /
                NULLIF(SUM(V.QTDPRODUTOS),0)
            ,2)
         ,0) AS VLR_MEDIO_PRODUTO

    FROM GRUPOS G

    /* GRUPO / MATRIZ */
    LEFT JOIN TGFPAR PGRUPO
           ON PGRUPO.CODPARC = G.CODGRUPO

    LEFT JOIN TSICID CID
           ON CID.CODCID = PGRUPO.CODCID

    LEFT JOIN TSIUFS UF
           ON UF.CODUF = CID.UF

    /* VENDAS DO ANO */
    LEFT JOIN VENDAS V
           ON V.CODGRUPO = G.CODGRUPO

    /* ÚLTIMA VENDA HISTÓRICA */
    LEFT JOIN ULTIMA_VENDA UV
           ON UV.CODGRUPO = G.CODGRUPO

    GROUP BY
         G.CODGRUPO
        ,G.GRUPO_ECONOMICO
        ,G.QTD_CLIENTES_CADASTRADOS
)

SELECT
     C.CODGRUPO
    ,C.GRUPO_ECONOMICO
    ,C.UF

    ,C.QTD_CLIENTES_CADASTRADOS
    ,C.QTD_CLIENTES_COM_COMPRA

    ,C.ULTIMA_VENDA
    ,C.DIAS_SEM_VENDA

    ,C.QTD_VENDAS
    ,C.QTD_PRODUTOS_VENDIDOS
    ,C.QTD_MEDIA_PROD_PEDIDO
    ,C.VLR_MEDIO_PRODUTO
    ,C.TICKET_MEDIO

    ,C.JANEIRO
    ,C.FEVEREIRO
    ,C.MARCO
    ,C.ABRIL
    ,C.MAIO
    ,C.JUNHO
    ,C.JULHO
    ,C.AGOSTO
    ,C.SETEMBRO
    ,C.OUTUBRO
    ,C.NOVEMBRO
    ,C.DEZEMBRO

    ,C.TOTAL

FROM COMERCIAL C

WHERE
    (
        :P_DIASSVEND IS NULL

        /* NUNCA VENDEU */
        OR C.ULTIMA_VENDA IS NULL

        /* ESTÁ SEM VENDER HÁ X DIAS OU MAIS */
        OR C.DIAS_SEM_VENDA >= :P_DIASSVEND
    )

ORDER BY
     C.DIAS_SEM_VENDA DESC NULLS FIRST
    ,C.TOTAL DESC
