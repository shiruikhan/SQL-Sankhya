CREATE OR REPLACE PROCEDURE STP_ATUALIZA_FRETE_COTA(
    P_NUNOTA IN NUMBER
) AS
/*==============================================================================
  Nome do Script : STP_ATUALIZA_FRETE_COTA
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Atualiza o valor do frete (VLRFRETE) de uma nota fiscal com base
                   no valor definido na cotação de frete associada (AD_TGSCTF).

  Parâmetros     : P_NUNOTA — número da nota fiscal para atualização do frete

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
    V_VLRFRETE NUMBER;
BEGIN
    -- Busca o VLRFRETE da cotação associada a nota
    -- Utiliza ROWNUM = 1 para garantir apenas um registro caso existam múltiplos
    BEGIN
        SELECT VLRFRETE 
        INTO V_VLRFRETE
        FROM AD_TGSCTF 
        WHERE NUNOTA = P_NUNOTA 
        AND ROWNUM = 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            V_VLRFRETE := NULL;
    END;

    IF V_VLRFRETE IS NOT NULL THEN
        -- Atualiza o valor do frete na TGFCAB
        UPDATE TGFCAB 
        SET VLRFRETE = V_VLRFRETE
        WHERE NUNOTA = P_NUNOTA;
    END IF;
END;
/
