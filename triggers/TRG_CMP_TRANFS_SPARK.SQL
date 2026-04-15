create or replace TRIGGER TRG_CMP_TRANFS_SPARK
    FOR DELETE ON TGFCAB 
COMPOUND TRIGGER
/*==============================================================================
  Nome do Script : TRG_CMP_TRANFS_SPARK
  Tipo           : Trigger
  Descrição      : Limpa referências de transferência ao deletar notas (COMPOUND TRIGGER).
                  Anula AD_NUNOTAENT e AD_NUNOTASAI de documentos relacionados.
  Tabela         : TGFCAB
  Evento         : FOR DELETE (COMPOUND TRIGGER)
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
    V_PEDORIG          INTEGER:=0;
    V_CODEMP           INTEGER:=0;
    V_NUNOTA          TGFCAB.NUNOTA%TYPE;
    V_TIPMOV           TGFCAB.TIPMOV %TYPE;
    
    V_COUNT          INT;
    V_COUNT2         INT;
   
BEFORE EACH ROW IS
BEGIN
        BEGIN
           
          V_NUNOTA :=  :OLD.NUNOTA;
          V_TIPMOV  :=  :OLD.TIPMOV;
          
        END;
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
     
     SELECT COUNT(0) 
        INTO V_COUNT
      FROM TGFCAB
     WHERE AD_NUNOTAENT = V_NUNOTA;
     
    SELECT COUNT(0)
       INTO V_COUNT2
      FROM TGFCAB
     WHERE AD_NUNOTASAI = V_NUNOTA;
     
     IF V_COUNT > 0 AND V_TIPMOV IN ('C', 'V') THEN     
             UPDATE TGFCAB SET AD_NUNOTAENT = NULL
             WHERE AD_NUNOTAENT = V_NUNOTA;   
     END IF;
     
     IF V_COUNT2 > 0 AND V_TIPMOV IN ('C', 'V')  THEN     
             UPDATE TGFCAB SET AD_NUNOTASAI = NULL
             WHERE AD_NUNOTASAI = V_NUNOTA;
     END IF;
     
END AFTER STATEMENT;
END TRG_CMP_TRANFS_SPARK;