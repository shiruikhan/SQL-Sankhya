create or replace TRIGGER TRG_TGFCOI2_SPARK 
BEFORE INSERT OR UPDATE ON TGFCOI2 FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TGFCOI2_SPARK
  Tipo           : Trigger
  Descrição      : Valida duplicidade de série na conferência, verifica disponibilidade
                   em estoque e vinculação com pedidos em aberto
  Tabela         : TGFCOI2
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 08/03/2022
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
 P_COUNT          INT;
 P_COUNT2         INT;
 P_NUNOTA2        NUMBER;
 P_COUNT3         INT;
 PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    SELECT COUNT(*) INTO P_COUNT
      FROM TGFCOI2
    WHERE CODBARRA = :NEW.CODBARRA
    AND NUCONF = :NEW.NUCONF; /* 08/03/22 - ACRESCENTADO REGRA PARA VALIDAR DENTRO DA MESMA CONFERENCIA, POIS OCORREU CASO DA MESMA SÉRIE SER CONFERIDA, FATURADA, DEVOLVIDA E  FEITO PEDIDO NOVAMENTE  DIONE/LUCAS*/
    
    /* VALIDAR SE EXISTE ALGUM PEDIDO EM ABERTO QUE ESTEJA VINCULADO A SÉRIE QUE SEJA DIFERENTE DO PEDIDO CONFERIDO DEVE CRITICAR */
    SELECT COUNT(*), MAX(S.NUNOTA) INTO P_COUNT2, P_NUNOTA2 FROM TGFSER S INNER JOIN TGFCAB C ON (S.NUNOTA = C.NUNOTA)
    WHERE C.TIPMOV='P' 
     AND C.PENDENTE='S'  
       AND S.ATUALESTOQUE=0
        AND S.SERIE = :NEW.CODBARRA
         AND NOT EXISTS (SELECT 1 FROM TGFCON2 CON WHERE CON.NUNOTAORIG = C.NUNOTA AND CON.NUCONF = :NEW.NUCONF) ;
   

  SELECT COUNT(*) INTO P_COUNT3
     FROM VGFSER 
       WHERE SERIE=:NEW.CODBARRA 
         AND CODPROD = :NEW.CODPROD 
          AND ATUALESTOQUE = 1;-- VERIFICA SE TEM ESTOQUE DA SÉRIE


    IF P_COUNT3 = 0 THEN 

        RAISE_APPLICATION_ERROR(-20101,'Este número de série:'|| :NEW.CODBARRA||' não possui estoque disponível');
    END IF;

    /* VALIDA DENTRO DA MESMA CONFERENCIA SE O CODIGO DE BARRAS JÁ FOI CONFERIDO */
    IF P_COUNT >  0    THEN 

    RAISE_APPLICATION_ERROR(-20101,'Este número de série:'|| :NEW.CODBARRA||' já foi conferido!');
    END IF;
    
    
    /* VALIDA SE JÁ EXISTE ALGUM PEDIDO EM ABERTO COM A SÉRIE VINCULADA E OUTRO PEDIDO NÃO PODE VINCULAR A MESMA SÉRIE */
    IF P_COUNT2 > 0  THEN 

    RAISE_APPLICATION_ERROR(-20101,'Este número de série:'|| :NEW.CODBARRA||' já foi conferido!Nro Único: '|| P_NUNOTA2);
    
    END IF;

END TRG_TGFCOI2_SPARK; 