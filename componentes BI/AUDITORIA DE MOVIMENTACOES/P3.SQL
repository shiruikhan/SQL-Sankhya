/*==============================================================================
  Nome do Script : P3
  Tipo           : Componente BI — Tabela
  Dashboard      : AUDITORIA DE MOVIMENTACOES
  Componente     : P3
  Descrição      : Detalhes de movimentações para um dia específico com operação e usuário

  Parâmetros     : :P_MES — mês da movimentação
                   :P_ANO — ano da movimentação
                   :A_DIA — dia específico
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
    C.DTNEG AS DATA_NEGOCIACAO,
    U.NOMEUSU AS USUARIO
FROM TGFCAB C
    INNER JOIN TGFITE I ON (C.NUNOTA = I.NUNOTA)
    INNER JOIN TGFTOP T ON (C.CODTIPOPER = T.CODTIPOPER AND C.DHTIPOPER = T.DHALTER)
    INNER JOIN TSIUSU U ON (C.CODUSUINC = U.CODUSU)
WHERE 
    EXTRACT(MONTH FROM C.DTNEG) = :P_MES
    AND EXTRACT(YEAR FROM C.DTNEG) = :P_ANO
    AND EXTRACT(DAY FROM C.DTNEG) = :A_DIA
    AND C.TIPMOV = 'J'
    AND C.STATUSNOTA = 'L'
    AND C.CODTIPOPER IN :P_CODTIPOPER
GROUP BY C.NUNOTA,
    C.CODTIPOPER,
    T.DESCROPER,
    C.DTNEG,
    U.NOMEUSU
ORDER BY C.NUNOTA
