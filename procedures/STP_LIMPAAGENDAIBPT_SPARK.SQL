CREATE OR REPLACE PROCEDURE STP_LIMPAAGENDAIBPT_SPARK AS
/*==============================================================================
  Nome do Script : STP_LIMPAAGENDAIBPT_SPARK
  Descrição      : Realiza a limpeza dos campos de percentual de ICMS e IPI
                   na tabela de produtos e na tabela de impostos.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 31/08/2022
  Última Revisão : 28/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/
BEGIN
    -- Limpar percentuais de ICMS e IPI na tabela de produtos
    UPDATE TGFPRO
       SET PERCCMTIMP = 0,
           PERCCMTNAC = 0
     WHERE USOPROD IN ('V', 'R');

    -- Limpar percentuais de ICMS e IPI na tabela de impostos
    UPDATE TGFPEM
       SET PERCCMTIMP = 0,
           PERCCMTNAC = 0
     WHERE USOPROD IN ('V', 'R');

EXCEPTION
    WHEN OTHERS THEN
        -- Captura e propaga o erro em caso de falha
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao limpar percentuais de ICMS/IPI: ' || SQLERRM);
END;