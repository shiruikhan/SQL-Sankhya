create or replace TRIGGER TRG_DEL_TPRSERPA_SPARK3
BEFORE DELETE ON TPRSERPA 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_DEL_TPRSERPA_SPARK3
  Tipo           : Trigger
  Descrição      : Remove código de barras de TGFBAR ao deletar série de produto PA.
                  Mantém consistência entre série de lote e código de barras.
  Tabela         : TPRSERPA
  Evento         : BEFORE DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE 
P_COUNT     INT;
P_CODVOL    VARCHAR2(100);

BEGIN

    SELECT COUNT(*) INTO P_COUNT
      FROM TGFBAR
     WHERE CODBARRA = :OLD.SERIEPA
       AND CODPROD = :OLD.CODPRODPA;
       
       IF P_COUNT = 0 THEN 
       
       DELETE FROM TGFBAR
       WHERE CODBARRA = :OLD.SERIEPA
       AND CODPROD = :OLD.CODPRODPA;
       
       END IF;
  

END TRG_DEL_TPRSERPA_SPARK3; 