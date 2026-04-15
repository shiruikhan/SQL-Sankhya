create or replace PROCEDURE STP_VALIDARSERIE_SPARK (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) AS
/*==============================================================================
  Nome do Script : STP_VALIDARSERIE_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Valida registros de série para produtos com controle de
                   serial (TIPCONTEST='S'), comparando quantidade de séries
                   apontadas com quantidade negociada do item.

  Parâmetros     : P_NUNOTA      — número da nota a validar
                   P_SUCESSO     — indicador de sucesso da operação (OUT)
                   P_MENSAGEM    — mensagem de retorno ao usuário (OUT)
                   P_CODUSULIB   — código do usuário liberador (OUT)

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
        P_SEQUENCIA INT;
        P_CODPROD   INT;
        P_DESCRPROD VARCHAR2(100);
        P_QTDNEG    FLOAT;
        P_COUNT     INT;
        
        CURSOR CUR_ITENS IS 
        SELECT ITE.SEQUENCIA, ITE.CODPROD , PRO.DESCRPROD, ITE.QTDNEG 
          FROM TGFITE ITE, TGFPRO PRO
         WHERE ITE.CODPROD = PRO.CODPROD
           AND ITE.NUNOTA = P_NUNOTA
           AND PRO.TIPCONTEST = 'S';
      
      
    BEGIN
    
            P_SUCESSO := 'S';
            
    
    OPEN CUR_ITENS;
    LOOP 
    FETCH CUR_ITENS INTO P_SEQUENCIA,  P_CODPROD , P_DESCRPROD, P_QTDNEG ;
    EXIT WHEN CUR_ITENS%NOTFOUND; 
    
    SELECT COUNT(*) INTO P_COUNT
      FROM TGFSER
     WHERE NUNOTA = P_NUNOTA
       AND SEQUENCIA = P_SEQUENCIA;
       
       IF P_COUNT <> P_QTDNEG THEN 
       
            P_MENSAGEM := 'As séries apontadas não confere com a quantidade lançada! Produto: '|| P_CODPROD || ' - ' || P_DESCRPROD;
            P_SUCESSO := 'N';
       
       END IF;
    
    
    END LOOP;
    CLOSE CUR_ITENS; 
  
    END;
    
END; 