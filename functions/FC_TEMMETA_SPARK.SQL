/*==============================================================================
  Nome do Script : FC_TEMMETA_SPARK
  Descrição      : Verifica se determinado produto possui a meta de código 3
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 16/12/2021
  Última Revisão : 23/04/2025 - Padronização e melhorias de legibilidade

  Observações:
  - Retorna 'S' se houver meta cadastrada para o produto informado (CODMETA = 3)
  - Retorna 'N' caso contrário
==============================================================================*/

CREATE OR REPLACE FUNCTION FC_TEMMETA_SPARK(P_CODPROD IN NUMBER)
RETURN VARCHAR2
AS
    -- Contador de registros com meta para o produto
    V_COUNT INTEGER;
BEGIN
    SELECT COUNT(0)
      INTO V_COUNT
      FROM TGMMET
     WHERE CODMETA = 3
       AND CODPROD = P_CODPROD;

    -- Retorno baseado na existência da meta
    IF V_COUNT > 0 THEN
        RETURN 'S';
    ELSE
        RETURN 'N';
    END IF;
END;