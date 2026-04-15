create or replace TRIGGER TRG_INC_TSICID_SPARK
BEFORE INSERT ON TSICID
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TSICID_SPARK
  Tipo           : Trigger
  Descrição      : Valida preenchimento de municipio fiscal e unicidade de cidades por nome e UF
  Tabela         : TSICID
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
  P_COUNT         INT;
  PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

    IF :NEW.CODMUNFIS IS NULL THEN 
    
     raise_application_error(-20101, 'É obrigatório preencher o campo Municipio Fiscal!');
    
    END IF;
    
    SELECT COUNT(*) INTO P_COUNT
      FROM TSICID 
     WHERE UPPER(NOMECID) = UPPER(:NEW.NOMECID)
       AND UF = :NEW.UF
       AND CODCID <> :NEW.CODCID;
       
       IF P_COUNT > 0 THEN 
             
        raise_application_error(-20101, 'Já possui uma cidade com esse nome cadastrado!');
       
       END IF;

END TRG_INC_TSICID_SPARK; 