/*==============================================================================
  Nome do Script : TRANSFERENCIA ENTRE EMPRESAS
  Tipo           : Componente BI — Tabela
  Dashboard      : Gestão de Transferências de Estoque
  Descrição      : Cálculo de quantidades a transferir entre empresas, identificando
                   produtos com saldo negativo em uma filial e positivo em outra.

  Parâmetros     : :DATE — data de contagem de estoque (DATE)

  Tabelas        : TGFCTE, TGFPRO, TGFGRU, TGFLOC (principais)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
  EST.CODPROD,
  PRO.DESCRPROD,
  EST.CODVOL,
  EST.CODLOCAL,
  LOC.DESCRLOCAL,
  EST.CODEMP,
  EST.CONTROLE,
  CASE
    WHEN -EST.QTDEST <= POS.SUM_QTDEST THEN -EST.QTDEST
    ELSE POS.SUM_QTDEST
  END AS QTDTRANSF
FROM TGFCTE EST
  INNER JOIN TGFPRO PRO ON EST.CODPROD = PRO.CODPROD
  INNER JOIN TGFGRU GRU ON PRO.CODGRUPOPROD = GRU.CODGRUPOPROD
  INNER JOIN TGFLOC LOC ON EST.CODLOCAL = LOC.CODLOCAL
  INNER JOIN (
    SELECT E.CODPROD, SUM(E.QTDEST) AS SUM_QTDEST
    FROM TGFCTE E
    WHERE E.CODEMP = 501
      AND E.CODLOCAL = 101
      AND E.DTCONTAGEM = :DATE
      AND E.QTDEST > 0
    GROUP BY E.CODPROD
  ) POS ON POS.CODPROD = EST.CODPROD
WHERE EST.DTCONTAGEM = :DATE
  AND PRO.USOPROD IN ('V','T','M','R','E','P','O')
  AND EST.QTDEST < 0
  AND EST.CODEMP = 1
  AND EST.CODLOCAL = 101
  AND POS.SUM_QTDEST > 0
ORDER BY PRO.CODPROD