create or replace PROCEDURE STP_LIBERASERIE_SPARK
AS
/*==============================================================================
  Nome do Script : STP_LIBERASERIE_SPARK
  Tipo           : Stored Procedure (Agendada)
  Descrição      : Procedure para liberação de séries de produtos em ordens de produção.
                   Atualiza status de liberação e limpa código de barras em estoque.

  Parâmetros     : [Procedure agendada - sem parâmetros de entrada]

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
    /* 
       TRECHO COMENTADO EM 24/03 PARA TRATAR O ERRO DE SN DUPLICADO NO AGENDADOR
       Refatorado para operações em lote (set-based) para evitar gargalos de performance 
       (Row-By-Agonizing-Row e Commits em laço).
    */
    
    /* 1. LIBERA APENAS SERIES QUE EXISTEM NA ORDEM DE PRODUÇÃO QUE ENTROU O PA E FICA NA TGFSER */
    UPDATE TPRSERPA P
    SET P.LIBERADO = 'S', 
        P.AD_LIBEXPED = 'S'
    WHERE EXISTS (
        SELECT 1 
        FROM TGFSER S 
        INNER JOIN TGFCAB C ON (S.NUNOTA = C.NUNOTA)
        INNER JOIN TPRIPROC PROC ON (PROC.IDIPROC = C.IDIPROC)
        WHERE C.CODTIPOPER IN (800,1214,1200,1201)
          AND S.CODPROD = P.CODPRODPA
          AND S.SERIE = P.SERIEPA
          AND C.IDIPROC = P.IDIPROC
          -- Trava Global: Não pode existir esse código para NENHUM produto
          AND NOT EXISTS (SELECT 1 FROM TGFBAR BAR WHERE BAR.CODBARRA = S.SERIE)
          AND NOT EXISTS (SELECT 1 FROM TGFSER SER INNER JOIN TGFCAB CAB ON SER.NUNOTA = CAB.NUNOTA WHERE CAB.CODTIPOPER = 512 AND SER.SERIE = S.SERIE)
    )
    -- Evita atualizar linhas que já estão com o status correto (ganho de performance e redução de redo/undo gerado)
    AND (NVL(P.LIBERADO, 'N') <> 'S' OR NVL(P.AD_LIBEXPED, 'N') <> 'S');

    
    /* 2. LIMPA CÓDIGO DE BARRAS NO ESTOQUE */
    UPDATE TGFEST E
    SET E.CODBARRA = NULL 
    WHERE EXISTS (
        SELECT 1 
        FROM TGFSER S 
        INNER JOIN TGFCAB C ON (S.NUNOTA = C.NUNOTA)
        WHERE C.CODTIPOPER IN (800,1214)
          AND S.CODPROD = E.CODPROD
          AND S.SERIE = E.CODBARRA
    )
    AND E.CODBARRA IS NOT NULL; 

    -- Executa um único commit no final do lote, otimizando I/O no banco de dados
    COMMIT;
    
END;