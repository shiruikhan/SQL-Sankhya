create or replace PROCEDURE STP_REGRA_VALID_FINAN_SPARK (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) AS
/*==============================================================================
  Nome do Script : STP_REGRA_VALID_FINAN_SPARK
  Tipo           : Stored Procedure (Validação de Regra)
  Descrição      : Valida o total da nota fiscal com o total dos valores
                   financeiros, verificando inconsistências de valores.

  Parâmetros     : P_NUNOTA     — número único da nota fiscal
                   P_SUCESSO    — indicador de sucesso da validação (S/N)
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)
                   P_CODUSULIB  — código do usuário liberador (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
    DECLARE
        P_VLRNOTA   NUMBER;
        P_VLRFIN    NUMBER;
    BEGIN
    
        BEGIN
            SELECT NVL(VLRNOTA,0) + NVL(VLROUTROS,0) + NVL(AD_VLROUTROSFRETE,0)INTO P_VLRNOTA
            FROM TGFCAB 
            WHERE NUNOTA = P_NUNOTA;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_VLRNOTA := 0;
        END;
        
        BEGIN
            SELECT SUM(NVL(VLRDESDOB,0)) INTO P_VLRFIN
            FROM TGFFIN 
            WHERE NUNOTA = P_NUNOTA
                AND RECDESP = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_VLRFIN := 0;
        END;
    
        P_SUCESSO := 'S';
    
        IF P_VLRFIN <> P_VLRNOTA THEN
            P_MENSAGEM := 'Valor Total da nota diferente do valor total do financeiro.';
            P_SUCESSO := 'N';
        END IF;
    
     --P_MENSAGEM := 'A REGRA FALHOU DE PROPÓSITO, SÓ PARA TESTAR.';
    
     --SE FOR NECESSÁRIO DETERMINAR O LIBERADOR BASTA ATRIBUIR:
    
    -- P_CODUSULIB := 10;
    END;
    
END;