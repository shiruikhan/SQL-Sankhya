create or replace TRIGGER TRG_DLT_TGFSER_SPARK
BEFORE DELETE ON TGFSER 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_DLT_TGFSER_SPARK
  Tipo           : Trigger
  Descrição      : Gerencia códigos de barras ao deletar série (TOP de produção 800).
                  Remove de TGFBAR ou reinsere em TGFEST conforme contexto de exclusão.
  Tabela         : TGFSER
  Evento         : BEFORE DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
  P_CODTIPOPER  TGFCAB.CODTIPOPER%TYPE;
  P_CODVOL         TGFPRO.CODVOL%TYPE;
  P_COUNT        NUMBER;
BEGIN
  
  IF NOT FPODEVALIDAR('TGFSER') THEN
    RETURN;
  END IF;

  BEGIN
    SELECT
      CAB.CODTIPOPER     
    INTO
      P_CODTIPOPER
    FROM
      TGFCAB CAB 
    WHERE CAB.NUNOTA = :OLD.NUNOTA;     
  EXCEPTION WHEN NO_DATA_FOUND THEN
    P_CODTIPOPER := 0;
  END TRG_DLT_TGFSER_SPARK; 
   
  SELECT COUNT(*) INTO P_COUNT FROM TGFBAR WHERE CODPROD = :OLD.CODPROD AND CODBARRA = :OLD.SERIE;
  
     BEGIN
      SELECT CODVOL INTO P_CODVOL
      FROM TGFPRO WHERE CODPROD = :OLD.CODPROD;
      EXCEPTION WHEN NO_DATA_FOUND THEN 
      RETURN;
      END;
  
  /* VERIFICA SE FOI IMPUTADO SERIE NAS TOPS DE PRODUÇÃO PA PARA EXCLUIR  DESTA FORMA NÃO FICARÁ DISPONÍVEL PARA CONFERENCIA EXPEDIÇÃO*/
  IF P_CODTIPOPER =800 AND P_COUNT = 0 THEN 
  DELETE FROM TGFBAR WHERE CODPROD = :OLD.CODPROD AND CODBARRA = :OLD.SERIE;
     
  END IF;
 
   IF P_CODTIPOPER =800 THEN
      /* AO EXCLUIR O APONTAMENTO PRODUÇÃO INSERIR NOVAMENTE O CÓDIGO DE BARRAS NA TABELA ESTOQUE PARA A CONFERENCIA DA PRODUÇÃO PODER LER*/
    UPDATE TGFEST SET CODBARRA=:OLD.SERIE
         WHERE CODPROD = :OLD.CODPROD 
           AND CODBARRA IS NULL
            AND CONTROLE = :OLD.SERIE
             AND CODLOCAL = 108;

  END IF;
   
END; 