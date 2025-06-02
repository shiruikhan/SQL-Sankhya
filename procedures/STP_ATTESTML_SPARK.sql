CREATE OR REPLACE PROCEDURE STP_ATTESTML_SPARK AS
/*==============================================================================
  Nome do Script : STP_ATTESTML_SPARK
  Descrição      : Atualiza a quantidade disponível de produtos no marketplace Mercado Livre
                   com base no estoque disponível na tabela VGF_ESTOQUEMELI_SPARK.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 22/05/2025
  Última Revisão : 28/05/2025 - Padronização e melhorias de legibilidade
==============================================================================*/
    CURSOR C_PRODUTOS IS
        SELECT M.CODPROD,
               NVL(M.DISPESTOQUE, 0) AS DISPESTOQUE,
               M.LOCAL,
               M.IDANUNCIO,
               M.AVAILABLE_QUANTITY,
               NVL(E.ESTOQUE, 0) AS ESTOQUE
        FROM AD_MKTPMELI M
        LEFT JOIN VGF_ESTOQUEMELI_SPARK E
               ON E.CODPROD = M.CODPROD AND E.CODLOCAL = M.LOCAL
        WHERE M.ACTIVE = 'active';
    V_ESTOQUE_FINAL   NUMBER := 0;
BEGIN
    FOR REG IN C_PRODUTOS LOOP
        
        -- Calcula o percentual do estoque
        V_ESTOQUE_FINAL := NVL(TRUNC(REG.ESTOQUE * (REG.DISPESTOQUE  / 100)),0);

        -- Atualiza apenas se a quantidade mudou
        IF NVL(V_ESTOQUE_FINAL,0) <> NVL(REG.AVAILABLE_QUANTITY,0) THEN
            UPDATE AD_MKTPMELI
            SET AVAILABLE_QUANTITY = V_ESTOQUE_FINAL, ENVSTK = 'S'
            WHERE CODPROD = REG.CODPROD
                AND LOCAL = REG.LOCAL
                AND IDANUNCIO = REG.IDANUNCIO;
        END IF;
    END LOOP;

    COMMIT;
END STP_ATTESTML_SPARK;
