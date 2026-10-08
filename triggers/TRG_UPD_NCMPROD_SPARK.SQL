/*==============================================================================
  Nome do Script : TRG_UPD_NCMPROD_SPARK
  Tipo           : Trigger (TGFPRO)
  Descrição      : Impedir alteração do NCM para produtos acabados se o usuário não pertencer ao grupo fiscal (CODGRUPO = 5). Caso seja do grupo 5, registrar a alteração em um log.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: tabela TGFPRO, BEFORE EACH ROW UPDATE, ENABLED; criada em 20/03/2025, última alteração em 20/03/2025.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".; acrescentados "/" antes do ALTER TRIGGER e ";" final).
                   - Cabeçalho ainda não padronizado — revisar.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "TRG_UPD_NCMPROD_SPARK" 
BEFORE UPDATE 
ON TGFPRO
FOR EACH ROW
 WHEN (NEW.NCM <> OLD.NCM 
    AND (NEW.USOPROD = 'V' OR OLD.USOPROD = 'V')
) DECLARE 
    V_CODGRUP  TSIUSU.CODGRUPO%TYPE; 
BEGIN 
    /***************************************************************
    * Autor: Lucas Gabriel 
    * Data: 20/03/2025
    * Objetivo: Impedir alteração do NCM para produtos acabados 
    * se o usuário não pertencer ao grupo fiscal (CODGRUPO = 5).
    Caso seja do grupo 5, registrar a alteração em um log.
    ***************************************************************/

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;


    BEGIN
        SELECT CODGRUPO 
        INTO V_CODGRUP
        FROM TSIUSU 
        WHERE CODUSU = STP_GET_CODUSULOGADO();
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            V_CODGRUP := NULL; 
    END;

    IF V_CODGRUP IS NULL OR V_CODGRUP <> 5 THEN
        :NEW.NCM := :OLD.NCM;
    ELSE
        INSERT INTO LOG_ALTERACAO_NCM 
            (ID_LOG, CODUSU, CODPROD, NCM_ANTIGO, NCM_NOVO, DATA_ALTERACAO)
        VALUES 
            (SEQ_LOG_ALTERACAO.NEXTVAL, STP_GET_CODUSULOGADO(), :NEW.CODPROD, :OLD.NCM, :NEW.NCM, SYSDATE);
    END IF;
END;
/
ALTER TRIGGER "TRG_UPD_NCMPROD_SPARK" ENABLE;
