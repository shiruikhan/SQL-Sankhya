/*==============================================================================
  Nome do Script : P4
  Tipo           : Componente BI — Tabela
  Dashboard      : AUDITORIA DE MOVIMENTACOES
  Componente     : P4
  Descrição      : Detalhes de movimentações para um usuário específico

  Parâmetros     : :P_MES — mês da movimentação
                   :P_ANO — ano da movimentação
                   :A_CODUSU — código do usuário
                   :P_CODTIPOPER — códigos de tipos de operação

  Tabelas        : TGFCAB, TGFITE, TGFTOP, TSIUSU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT C.NUNOTA,
    SUM(I.QTDNEG) AS QTDNEG,
    C.CODTIPOPER || ' - ' || T.DESCROPER AS DESCROPER,
    C.DTNEG AS DATA_NEGOCIACAO
FROM TGFCAB C
    INNER JOIN TGFITE I ON (C.NUNOTA = I.NUNOTA)
    INNER JOIN TGFTOP T ON (C.CODTIPOPER = T.CODTIPOPER AND C.DHTIPOPER = T.DHALTER)
    INNER JOIN TSIUSU U ON (C.CODUSUINC = U.CODUSU)
WHERE 
    EXTRACT(MONTH FROM C.DTNEG) = :P_MES
    AND EXTRACT(YEAR FROM C.DTNEG) = :P_ANO
    AND C.CODUSUINC = :A_CODUSU
    AND C.TIPMOV = 'J'
    AND C.STATUSNOTA = 'L'
    AND C.CODTIPOPER IN :P_CODTIPOPER
GROUP BY C.NUNOTA,
    C.CODTIPOPER,
    T.DESCROPER,
    C.DTNEG
ORDER BY V.DTNEG
