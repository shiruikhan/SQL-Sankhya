/*==============================================================================
  Nome do Script : ESTOQUE SEM MOVIMENTO
  Tipo           : Componente BI — Tabela
  Dashboard      : Gestão de Estoque
  Descrição      : Produtos em estoque sem movimento há períodos
                   (3, 2 ou 1 ano), com indicação visual por cor.

  Parâmetros     : :P_DTCORTE — Data de corte para análise de movimento
                   :P_CODLOCAL — Código do local de estoque (ou NULL para todos)
                   :P_USOPROD — Uso do produto para filtro

  Tabelas        : TGFITE, TGFCAB, TGFPRO, TGFEST

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

WITH MovAgg AS (
    SELECT I.CODPROD, I.CODLOCALORIG AS CODLOCAL, MAX(C.DTNEG) AS MOVIMENTACAO
    FROM TGFITE I
    INNER JOIN TGFCAB C ON I.NUNOTA = C.NUNOTA
    GROUP BY I.CODPROD, I.CODLOCALORIG
),
MovAfter AS (
    SELECT DISTINCT I.CODPROD, I.CODLOCALORIG AS CODLOCAL
    FROM TGFITE I
    INNER JOIN TGFCAB C ON I.NUNOTA = C.NUNOTA
    WHERE TRUNC(C.DTNEG) > :P_DTCORTE
)
SELECT V.CODPROD,
    V.DESCRPROD,
    V.CODVOL,
    V.CODLOCAL,
    SUM(V.ESTOQUE) AS ESTOQUE,
    SUM(V.RESERVADO) AS RESERVADO,
    V.LOCALIZACAO,
    MAX(V.MOVIMENTACAO) AS MOVIMENTACAO,
    CASE 
        WHEN MAX(V.MOVIMENTACAO) IS NULL OR MAX(V.MOVIMENTACAO) < ADD_MONTHS(TRUNC(SYSDATE), -36) THEN '#FF6666'
        WHEN MAX(V.MOVIMENTACAO) < ADD_MONTHS(TRUNC(SYSDATE), -24) THEN '#FF9999'
        WHEN MAX(V.MOVIMENTACAO) < ADD_MONTHS(TRUNC(SYSDATE), -12) THEN '#FFCCCC'
        ELSE NULL
    END AS bkcolor,
    V.OPCAO
FROM (
    SELECT PRO.CODPROD,
        PRO.DESCRPROD,
        PRO.CODVOL,
        EST.CODLOCAL,
        EST.ESTOQUE,
        EST.RESERVADO,
        NVL(PRO.LOCALIZACAO,'SEM LOC') AS LOCALIZACAO,
        MA.MOVIMENTACAO,
        OPC.OPCAO
    FROM TGFPRO PRO
        INNER JOIN TGFEST EST ON PRO.CODPROD = EST.CODPROD
        LEFT JOIN MovAgg MA ON MA.CODPROD = PRO.CODPROD AND MA.CODLOCAL = EST.CODLOCAL
        LEFT JOIN TDDOPC OPC ON PRO.USOPROD = OPC.VALOR AND OPC.NUCAMPO = 613
    WHERE NOT EXISTS (
            SELECT 1 FROM MovAfter MX
            WHERE MX.CODPROD = PRO.CODPROD
              AND MX.CODLOCAL = EST.CODLOCAL
        )
        AND (:P_CODLOCAL IS NULL OR EST.CODLOCAL = :P_CODLOCAL)
        AND EST.CODEMP = 1	
        AND PRO.USOPROD IN :P_USOPROD
    UNION ALL
    SELECT PRO.CODPROD,
        PRO.DESCRPROD,
        PRO.CODVOL,
        EST.CODLOCAL,
        EST.ESTOQUE,
        EST.RESERVADO,
        NVL(PRO.LOCALIZACAO,'SEM LOC') AS LOCALIZACAO,
        MA.MOVIMENTACAO,
        OPC.OPCAO
    FROM TGFPRO PRO
        INNER JOIN TGFEST EST ON PRO.CODPROD = EST.CODPROD
        LEFT JOIN MovAgg MA ON MA.CODPROD = PRO.CODPROD AND MA.CODLOCAL = EST.CODLOCAL
        LEFT JOIN TDDOPC OPC ON PRO.USOPROD = OPC.VALOR AND OPC.NUCAMPO = 613
    WHERE NOT EXISTS (
            SELECT 1 FROM MovAfter MX
            WHERE MX.CODPROD = PRO.CODPROD
              AND MX.CODLOCAL = EST.CODLOCAL
        )
        AND (:P_CODLOCAL IS NULL OR EST.CODLOCAL = :P_CODLOCAL)
        AND EST.CODEMP = 501
        AND PRO.USOPROD IN :P_USOPROD
) V
GROUP BY V.CODPROD, V.DESCRPROD, V.CODVOL, V.CODLOCAL, V.LOCALIZACAO, V.OPCAO
HAVING (:P_VALIDEST <> 'S' OR SUM(V.ESTOQUE) > 0)
ORDER BY V.CODPROD, V.CODLOCAL
