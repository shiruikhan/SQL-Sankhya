/*==============================================================================
  Nome do Script : Filtro — Grupo de Produto (P_CODGRUPOPROD)
  Tipo           : Componente BI — Filtro Multilist
  Descrição      : Popula o parâmetro :P_CODGRUPOPROD do componente
                   "Tabela de Características de Produto" com a lista de
                   grupos cujo código inicia com '3', permitindo seleção
                   múltipla pelo usuário.
  Parâmetros     : —
  Tabelas        : TGFGRU
  Dependencias   : p1.sql (componente principal)
  Uso            : Parâmetro multilist do componente BI — P_CODGRUPOPROD

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Maio/2026
  Última Revisão : —

  Observações    : Retorna apenas grupos com CODGRUPOPROD iniciado em '3'.
                   O campo VALUE é o código; LABEL é a descrição exibida
                   na interface do filtro.
==============================================================================*/
SELECT  G.CODGRUPOPROD AS VALUE
       ,G.DESCRGRUPOPROD AS LABEL
  FROM TGFGRU G
 WHERE SUBSTR(G.CODGRUPOPROD, 1, 1) = '3'
 ORDER BY G.CODGRUPOPROD
