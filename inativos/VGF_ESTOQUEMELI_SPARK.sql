CREATE OR REPLACE VIEW VGF_ESTOQUEMELI_SPARK AS
/*=============================================================
  View: VGF_ESTOQUEMELI_SPARK
  Descrição:
      Retorna o estoque consolidado de produtos ativos no 
      Mercado Livre (tabela AD_MKTPMELI), substituindo valores 
      negativos por zero.
  Observações:
      - Considera apenas CODEMP = 1.
      - Agrupamento por produto e local.
      - Estoques negativos são tratados como zero.
===============================================================*/
SELECT
    CODPROD,                           -- Código do produto
    CODLOCAL,                          -- Código do local de estoque
    CODEMP,                            -- Código da empresa
    SUM(
        CASE 
            WHEN ESTOQUE < 0 THEN 0     -- Estoque negativo é zerado
            ELSE ESTOQUE                -- Caso contrário, mantém valor original
        END
    ) AS ESTOQUE                        -- Estoque total do produto/local
FROM TGFEST
WHERE CODEMP = 1                        -- Filtra apenas a empresa 1
  AND CODPROD IN (                      -- Apenas produtos ativos no Mercado Livre
      SELECT CODPROD 
      FROM AD_MKTPMELI 
      WHERE ACTIVE = 'active'
  )
GROUP BY 
    CODPROD, 
    CODLOCAL;                           -- Agrupamento por produto e local
