create or replace TRIGGER TRG_INC_TGFVAR_SPARK 
BEFORE INSERT ON TGFVAR 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TGFVAR_SPARK
  Tipo           : Trigger
  Descrição      : Copia dados de embalagem de nota original para nota variação quando existe registro em AD_EMBPED
  Tabela         : TGFVAR
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE 

P_COUNT      INT;
P_COUNT2     INT;

BEGIN

    SELECT COUNT(*) INTO P_COUNT
      FROM AD_EMBPED
    WHERE NUNOTA = :NEW.NUNOTAORIG;
    
    SELECT COUNT(*) INTO P_COUNT2
      FROM AD_EMBPED
    WHERE NUNOTA = :NEW.NUNOTA;
    
    IF P_COUNT > 0 AND P_COUNT2 = 0 THEN 
     
    INSERT INTO AD_EMBPED (NUNOTA, SEQ, CODPROD, CODPRODEMB, PESOBRUTO, M3, IDCAIXA, TIPO)
    (SELECT :NEW.NUNOTA, SEQ, CODPROD, CODPRODEMB, PESOBRUTO, M3, IDCAIXA, TIPO
       FROM AD_EMBPED
     WHERE NUNOTA = :NEW.NUNOTAORIG);
    
    END IF;
    
    


END TRG_INC_TGFVAR_SPARK; 