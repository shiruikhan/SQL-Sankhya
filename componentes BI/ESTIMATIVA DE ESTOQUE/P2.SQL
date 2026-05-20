/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela
  Dashboard      : ESTIMATIVA DE ESTOQUE
  Componente     : P2
  Descrição      : Pedidos abertos de vendas com detalhes de cliente, datas e
                   quantidade pendente de entrega de um produto específico.

  Parâmetros     : :P_DATA — Data limite para filtro de entrega prevista
                   :A_CODPROD — Código do produto para filtro

  Tabelas        : TGFCAB, TGFITE, TGFPAR, TGFTPV

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
    CAB.NUNOTA,
    CAB.CODPARC,
    PAR.RAZAOSOCIAL,
    SUM(ITE.QTDNEG - ITE.QTDENTREGUE) AS QTDNEG,
    CAB.DTNEG,
    CAB.DTPREVENT,
    TPV.DESCRTIPVENDA
FROM TGFCAB CAB
INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
INNER JOIN TGFTPV TPV ON TPV.CODTIPVENDA = CAB.CODTIPVENDA AND TPV.DHALTER = CAB.DHTIPVENDA
WHERE CAB.PENDENTE = 'S'
  AND CAB.TIPMOV = 'P'
  AND ITE.PENDENTE = 'S'
  AND CAB.CODTIPOPER <> 900
  AND (CAB.CODEMP = 2 OR CAB.DTPREVENT <= :P_DATA)
  AND ITE.CODPROD = :A_CODPROD
GROUP BY 
    CAB.NUNOTA,
    CAB.CODPARC,
    PAR.RAZAOSOCIAL,
    CAB.DTNEG,
    CAB.DTPREVENT,
    TPV.DESCRTIPVENDA
ORDER BY CAB.DTPREVENT, PAR.RAZAOSOCIAL
