/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela
  Dashboard      : ESTIMATIVA DE ESTOQUE GERENCIAL
  Componente     : P2
  Descrição      : Pedidos abertos de vendas com detalhes de cliente, datas e
                   quantidade faltante para entrega de um produto específico.

  Parâmetros     : :P_DATA — Data limite para filtro de entrega prevista
                   :A_CODPROD — Código do produto para filtro

  Tabelas        : TGFCAB, TGFITE, TGFTPV, TGFPAR

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT CAB.NUNOTA, CAB.CODPARC, PAR.RAZAOSOCIAL, SUM(QTDNEG-QTDENTREGUE) AS QTDNEG, CAB.DTNEG, CAB.DTPREVENT, TPV.DESCRTIPVENDA
    FROM TGFCAB CAB, TGFITE ITE, TGFTPV TPV, TGFPAR PAR
   WHERE CAB.NUNOTA= ITE.NUNOTA
     AND CAB.CODPARC = PAR.CODPARC
     AND CAB.CODTIPVENDA = TPV.CODTIPVENDA
     AND CAB.DHTIPVENDA = TPV.DHALTER
     AND CAB.PENDENTE = 'S'
     AND CAB.TIPMOV = 'P'
     AND ITE.PENDENTE = 'S'
	    AND CAB.CODTIPOPER <> 900
     AND CAB.DTPREVENT <= :P_DATA
     AND ITE.CODPROD = :A_CODPROD
GROUP BY 
CAB.NUNOTA, CAB.CODPARC, PAR.RAZAOSOCIAL,CAB.DTNEG, CAB.DTPREVENT, TPV.DESCRTIPVENDA
order by CAB.DTPREVENT, PAR.RAZAOSOCIAL