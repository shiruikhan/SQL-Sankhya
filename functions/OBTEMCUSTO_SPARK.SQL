/*==============================================================================
  Nome do Script : OBTEMCUSTO_SPARK
  Descrição      : Retorna o custo de um produto conforme critérios de controle,
                   local, empresa e data de movimentação, baseado no tipo solicitado.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 10/03/2022
  Última Revisão : 23/04/2025 - Padronização, tratamento de exceções e legibilidade

  Observações:
  - Tipos de custo:
      0 = Custo de reposição
      1 = Custo médio
      2 = Custo variável
      3 = Custo sem ICMS
      4 = Custo médio com ICMS
      5 = Entrada sem ICMS
      6 = Entrada com ICMS
==============================================================================*/

CREATE OR REPLACE FUNCTION OBTEMCUSTO_SPARK (
    P_CODPROD        IN NUMBER,
    P_POREMP         IN CHAR,
    P_CODEMP         IN NUMBER,
    P_PORLOCAL       IN CHAR,
    P_CODLOCAL       IN NUMBER,
    P_PORCONTROLE    IN CHAR,
    P_CONTROLE       IN VARCHAR2,
    P_DATA           IN DATE,
    P_TIPO           IN NUMBER
)
RETURN FLOAT
IS
    -- Variáveis para armazenar os custos
    V_CUSREP           TGFCUS.CUSREP%TYPE := 0;
    V_CUSGER           TGFCUS.CUSMED%TYPE := 0;
    V_CUSVARIAVEL      TGFCUS.CUSVARIAVEL%TYPE := 0;
    V_CUSSEMICM        TGFCUS.CUSSEMICM%TYPE := 0;
    V_CUSMEDICM        TGFCUS.CUSMEDICM%TYPE := 0;
    V_ENTRADASEMICMS   TGFCUS.ENTRADASEMICMS%TYPE := 0;
    V_ENTRADACOMICMS   TGFCUS.ENTRADACOMICMS%TYPE := 0;
BEGIN
    BEGIN
        SELECT NVL(CUSREP, 0), 
               NVL(CUSMED, 0), 
               NVL(CUSVARIAVEL, 0), 
               NVL(CUSSEMICM, 0), 
               NVL(CUSMEDICM, 0), 
               NVL(ENTRADASEMICMS, 0), 
               NVL(ENTRADACOMICMS, 0)
          INTO V_CUSREP, 
               V_CUSGER, 
               V_CUSVARIAVEL, 
               V_CUSSEMICM, 
               V_CUSMEDICM, 
               V_ENTRADASEMICMS, 
               V_ENTRADACOMICMS
          FROM TGFCUS
         WHERE CODPROD = P_CODPROD
           AND (P_PORCONTROLE = 'N' OR CONTROLE = P_CONTROLE)
           AND (P_PORLOCAL    = 'N' OR CODLOCAL = P_CODLOCAL)
           AND (P_POREMP      = 'N' OR CODEMP = P_CODEMP)
           AND DTATUAL = (
                SELECT MAX(DTATUAL)
                  FROM TGFCUS CN
                 WHERE CODPROD = P_CODPROD
                   AND DTATUAL <= P_DATA
                   AND (P_PORCONTROLE = 'N' OR CONTROLE = P_CONTROLE)
                   AND (P_PORLOCAL    = 'N' OR CODLOCAL = P_CODLOCAL)
                   AND (P_POREMP      = 'N' OR CODEMP = P_CODEMP)
            );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Valores já estão inicializados com 0
            NULL;
    END;

    -- Seleciona qual custo retornar com base no parâmetro P_TIPO
    CASE P_TIPO
        WHEN 0 THEN RETURN V_CUSREP;
        WHEN 1 THEN RETURN V_CUSGER;
        WHEN 2 THEN RETURN V_CUSVARIAVEL;
        WHEN 3 THEN RETURN V_CUSSEMICM;
        WHEN 4 THEN RETURN V_CUSMEDICM;
        WHEN 5 THEN RETURN V_ENTRADASEMICMS;
        WHEN 6 THEN RETURN V_ENTRADACOMICMS;
        ELSE RETURN 0;
    END CASE;

EXCEPTION
    WHEN OTHERS THEN
        -- Tratamento genérico para qualquer falha inesperada
        RETURN 0;
END;
