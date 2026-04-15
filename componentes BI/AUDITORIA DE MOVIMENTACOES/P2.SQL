/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Gráfico
  Dashboard      : AUDITORIA DE MOVIMENTACOES
  Componente     : P2
  Descrição      : Auditoria de movimentações por usuário — quantidade ou contagem de notas

  Parâmetros     : :P_DETALHE — 'S' para somar quantidade, outro valor para contar notas
                   :P_MES — mês da movimentação
                   :P_ANO — ano da movimentação
                   :P_CODTIPOPER — códigos de tipos de operação

  Tabelas        : TGFCAB, TGFITE, TGFTOP, TSIUSU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT (CASE WHEN :P_DETALHE = 'S' THEN SUM(V.QTDNEG) ELSE COUNT(V.NUNOTA) END) AS VALUE,
    V.USUARIO AS LABEL,
    V.CODUSUINC AS CODUSUINC
FROM (
    SELECT C.NUNOTA,
        SUM(I.QTDNEG) AS QTDNEG,
        C.CODTIPOPER || ' - ' || T.DESCROPER AS DESCROPER,
        EXTRACT(MONTH FROM C.DTNEG) AS MES,
        EXTRACT(YEAR FROM C.DTNEG) AS ANO,
        EXTRACT(DAY FROM C.DTNEG) AS DIA,
        C.DTNEG AS DATA_NEGOCIACAO,
        U.NOMEUSU AS USUARIO,
        C.CODUSUINC AS CODUSUINC
    FROM TGFCAB C
        INNER JOIN TGFITE I ON (C.NUNOTA = I.NUNOTA)
        INNER JOIN TGFTOP T ON (C.CODTIPOPER = T.CODTIPOPER AND C.DHTIPOPER = T.DHALTER)
        INNER JOIN TSIUSU U ON (C.CODUSUINC = U.CODUSU)
    WHERE 
        EXTRACT(MONTH FROM C.DTNEG) = :P_MES
        AND EXTRACT(YEAR FROM C.DTNEG) = :P_ANO
        AND C.TIPMOV = 'J'
        AND C.STATUSNOTA = 'L'
        AND C.CODTIPOPER IN :P_CODTIPOPER
    GROUP BY C.NUNOTA,
        C.CODTIPOPER,
        T.DESCROPER,
        C.DTNEG,
        U.NOMEUSU,
        C.CODUSUINC
    ) V
WHERE (:P_MES IS NULL OR V.MES = :P_MES)
    AND (:P_ANO IS NULL OR V.ANO = :P_ANO)
GROUP BY V.USUARIO,
    V.CODUSUINC
ORDER BY V.USUARIO
