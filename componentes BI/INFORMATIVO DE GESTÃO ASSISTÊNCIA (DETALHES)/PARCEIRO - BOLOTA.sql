/*==============================================================================
  Nome do Script : PARCEIRO - BOLOTA
  Tipo           : Componente BI — Gráfico
  Dashboard      : INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)
  Componente     : PARCEIRO - BOLOTA
  Descrição      : Distribuição de ordens de serviço por parceiro (cliente) em
                   formato de bolha com filtros por período e estado.

  Parâmetros     : :P_PERIODO.INI e :P_PERIODO.FIN — Período de análise
                   :P_DTFAB.INI e :P_DTFAB.FIN — Filtro por data de fabricação (opcional)
                   :A_UFS — Filtro por UF (opcional)

  Tabelas        : AD_TGFASS, TGFPAR, TSICID

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT COUNT(ASS.NUMOS) AS QTD,
    ASS.CODPARC,
    SUBSTR(PAR.RAZAOSOCIAL, 1, 
        CASE 
            WHEN INSTR(SUBSTR(PAR.RAZAOSOCIAL, INSTR(PAR.RAZAOSOCIAL, ' ') + 1), ' ') > 0
            THEN INSTR(PAR.RAZAOSOCIAL, ' ', 1, 2)
            ELSE LENGTH(PAR.RAZAOSOCIAL)
        END
    ) AS RAZAOSOCIAL
FROM AD_TGFASS ASS
    INNER JOIN TGFPAR PAR ON ASS.CODPARC = PAR.CODPARC
    LEFT JOIN TSICID CID ON PAR.CODCID = CID.CODCID
WHERE ASS.DTRECEB BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
    AND (:P_DTFAB.INI IS NULL OR TRUNC(ASS.T_DTFABRICACAO) >= :P_DTFAB.INI)
    AND (:P_DTFAB.FIN IS NULL OR TRUNC(ASS.T_DTFABRICACAO) <= :P_DTFAB.FIN)
    AND (:A_UFS IS NULL OR CID.UF = :A_UFS)
GROUP BY ASS.CODPARC,
    PAR.RAZAOSOCIAL
ORDER BY COUNT(ASS.NUMOS) DESC