/*==============================================================================
  Nome do Script : AUDITOR E-COMMERCE GODEEP
  Tipo           : Componente BI — Tabela
  Dashboard      : Auditoria E-Commerce
  Descrição      : Auditoria de movimentações de produtos no e-commerce, com
                   filtros por código de produto e período.

  Parâmetros     : :P_CODPROD — Código do produto a filtrar (ou NULL para todos)
                   :P_PERIODO.INI — Data inicial da auditoria
                   :P_PERIODO.FIN — Data final da auditoria

  Tabelas        : TECLOG

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT *
FROM TECLOG
WHERE CODPROD = :P_CODPROD OR :P_CODPROD IS NULL
    AND TRUNC(DTHRALTER) >= :P_PERIODO.INI
    AND TRUNC(DTHRALTER) <= :P_PERIODO.FIN
ORDER BY DTHRALTER DESC