CREATE OR REPLACE PROCEDURE STP_AJUSTARRATFRETE_SAPARK (
    P_CODUSU NUMBER,        -- Código do usuário logado
    P_IDSESSAO VARCHAR2,    -- Identificador da execução
    P_QTDLINHAS NUMBER,     -- Quantidade de registros selecionados
    P_MENSAGEM OUT VARCHAR2 -- Mensagem de retorno ao usuário
) AS
/*==============================================================================
  Nome do Script : STP_AJUSTARRATFRETE_SAPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Realiza rateio proporcional de frete, ICMS e PIS/COFINS
                   entre notas fiscais vinculadas ao mesmo CTE.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
    
    -- Variáveis de controle
    FIELD_NUNOTA NUMBER;     -- NUNOTA do registro atual sendo processado
    P_NUNOTA INT;            -- NUNOTA do CTE relacionado
    P_VLRNOTACTE FLOAT;      -- Valor total da nota CTE
    P_TOTNOTA FLOAT;         -- Soma total das notas vinculadas
    P_VLRICMS FLOAT;         -- Valor total do ICMS
    P_VLRPIS FLOAT;          -- Valor total do PIS/COFINS
          
          
BEGIN
    -- Inicializa mensagem de retorno
    P_MENSAGEM := 'Processamento concluído com sucesso';
    
    -- Loop para processar cada registro selecionado
    FOR I IN 1..P_QTDLINHAS LOOP
        -- Obtém o NUNOTA do registro atual
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        
        -- Busca o NUNOTA do CTE relacionado
        SELECT MAX(NUNOTA) INTO P_NUNOTA
        FROM TGFNCT
        WHERE CHAVENFE = (SELECT CHAVENFE FROM TGFCAB WHERE NUNOTA = FIELD_NUNOTA);
        
        -- Busca valores do CTE em uma única consulta otimizada
        SELECT 
            CAB.VLRNOTA,
            NVL(DIN_ICMS.VALOR, 0),
            NVL(DIN_PIS.VALOR, 0)
        INTO P_VLRNOTACTE, P_VLRICMS, P_VLRPIS
        FROM TGFCAB CAB
        LEFT JOIN (SELECT NUNOTA, SUM(VALOR) AS VALOR 
                   FROM TGFDIN 
                   WHERE CODIMP = 1 
                   GROUP BY NUNOTA) DIN_ICMS ON CAB.NUNOTA = DIN_ICMS.NUNOTA
        LEFT JOIN (SELECT NUNOTA, SUM(VALOR) AS VALOR 
                   FROM TGFDIN 
                   WHERE CODIMP IN (6,7) 
                   GROUP BY NUNOTA) DIN_PIS ON CAB.NUNOTA = DIN_PIS.NUNOTA
        WHERE CAB.NUNOTA = P_NUNOTA;
        
        -- Calcula o total das notas vinculadas ao CTE
        SELECT NVL(SUM(CAB.VLRNOTA), 0) INTO P_TOTNOTA
        FROM TGFNCT NCT
        INNER JOIN TGFCAB CAB ON NCT.CHAVENFE = CAB.CHAVENFE
        WHERE NCT.NUNOTA = P_NUNOTA;
          
        -- Atualiza valores das notas no CTE (otimizado sem cursor)
        UPDATE TGFNCT NCT
        SET VLRNOTA = (
            SELECT CAB.VLRNOTA
            FROM TGFCAB CAB
            WHERE CAB.CHAVENFE = NCT.CHAVENFE
              AND CAB.TIPMOV = 'C'
        )
        WHERE NCT.NUNOTA = P_NUNOTA
          AND EXISTS (
              SELECT 1
              FROM TGFCAB CAB
              WHERE CAB.CHAVENFE = NCT.CHAVENFE
                AND CAB.TIPMOV = 'C'
          );
        
        -- Aplica rateio proporcional do frete (otimizado sem cursor)
        IF P_TOTNOTA > 0 THEN
            UPDATE TGFCAB CAB
            SET VLRFRETE = ROUND(P_VLRNOTACTE * CAB.VLRNOTA / P_TOTNOTA, 2),
                ICMSFRETE = ROUND(P_VLRICMS * CAB.VLRNOTA / P_TOTNOTA, 2),
                AD_VLRPISCOFINS_FRETE = ROUND(P_VLRPIS * CAB.VLRNOTA / P_TOTNOTA, 2),
                AD_FRETERATEADO = 'S'
            WHERE EXISTS (
                SELECT 1
                FROM TGFNCT NCT
                WHERE NCT.CHAVENFE = CAB.CHAVENFE
                  AND NCT.NUNOTA = P_NUNOTA
                  AND CAB.TIPMOV = 'C'
            );
        END IF;
         
         -- Commit das alterações para cada registro processado
         COMMIT;
         
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback em caso de erro
        ROLLBACK;
        P_MENSAGEM := 'Erro no processamento: ' || SQLERRM;
        RAISE;
        
END;