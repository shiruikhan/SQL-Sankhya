create or replace PROCEDURE STP_VALIDARSERIECONS_SPARK (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) AS
/*==============================================================================
  Nome do Script : STP_VALIDARSERIECONS_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Valida séries de devoluções comparando quantidade de séries
                   apontadas com série da nota original, detectando divergências
                   de quantidade e séries não encontradas.

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

        P_SEQUENCIA        INT;
        P_NUNOTAORIG       INT;
        P_SEQUENCIAORIG    INT;

        P_COUNT            INT;
        P_COUNTORIG        INT;
        P_COUNTSER         INT;
        P_CODPROD          INT;
        P_DESCRPROD VARCHAR2(100);

        
        CURSOR CUR_ITENS IS 
        SELECT SEQUENCIA, NUNOTAORIG, SEQUENCIAORIG
          FROM TGFVAR VAR
         WHERE VAR.NUNOTA = P_NUNOTA;
      
      
    BEGIN
    
            P_SUCESSO := 'S';
            P_MENSAGEM := NULL;
                
    
    OPEN CUR_ITENS;
    LOOP 
    FETCH CUR_ITENS INTO P_SEQUENCIA, P_NUNOTAORIG, P_SEQUENCIAORIG;
    EXIT WHEN CUR_ITENS%NOTFOUND; 
    
    SELECT COUNT(*) INTO P_COUNT
      FROM TGFSER
     WHERE NUNOTA = P_NUNOTA
       AND SEQUENCIA = P_SEQUENCIA;
       
    SELECT COUNT(*) INTO P_COUNTORIG
      FROM TGFSER
     WHERE NUNOTA = P_NUNOTAORIG
       AND SEQUENCIA = P_SEQUENCIAORIG;
       
       IF P_COUNT > P_COUNTORIG THEN 
       
        SELECT PRO.CODPROD, PRO.DESCRPROD INTO P_CODPROD, P_DESCRPROD
          FROM TGFITE ITE , TGFPRO PRO 
         WHERE ITE.CODPROD = PRO.CODPROD
           AND NUNOTA = P_NUNOTA
           AND SEQUENCIA = P_SEQUENCIA;
       
            IF P_MENSAGEM IS NULL THEN
                P_MENSAGEM := 'As séries apontadas não conferem com a quantidade lançada! Produto: '|| P_CODPROD || ' - ' || P_DESCRPROD;
            ELSE
                P_MENSAGEM := P_MENSAGEM || CHR(10) || 'As séries apontadas não conferem com a quantidade lançada! Produto: '|| P_CODPROD || ' - ' || P_DESCRPROD;
            END IF;
            P_SUCESSO := 'N';
       
       END IF;
       
           SELECT COUNT(*) INTO P_COUNTSER
             FROM TGFSER
            WHERE NUNOTA = P_NUNOTA
              AND SEQUENCIA = P_SEQUENCIA
              AND SERIE NOT IN (SELECT SERIE FROM TGFSER WHERE NUNOTA = P_NUNOTAORIG AND SEQUENCIA = P_SEQUENCIAORIG);
              
              IF P_COUNTSER > 0 THEN
              
                    SELECT PRO.CODPROD, PRO.DESCRPROD INTO P_CODPROD, P_DESCRPROD
                      FROM TGFITE ITE , TGFPRO PRO 
                     WHERE ITE.CODPROD = PRO.CODPROD
                       AND NUNOTA = P_NUNOTA
                       AND SEQUENCIA = P_SEQUENCIA;
              
                 IF P_MENSAGEM IS NULL THEN
                    P_MENSAGEM := 'As séries apontadas não confere com a quantidade lançada! Produto: '|| P_CODPROD || ' - ' || P_DESCRPROD;
                 ELSE
                    P_MENSAGEM := P_MENSAGEM || CHR(10) || 'As séries apontadas não confere com a quantidade lançada! Produto: '|| P_CODPROD || ' - ' || P_DESCRPROD;
                 END IF;
                 P_SUCESSO := 'N';
            
              END IF;
    
    
    END LOOP;
    CLOSE CUR_ITENS; 
  
    END;
    
END; 
