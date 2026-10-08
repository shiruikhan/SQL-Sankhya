/*==============================================================================
  Nome do Script : TRG_UPD_ORIGPROD_SPARK
  Tipo           : Trigger (TGFITE)
  Descrição      : Atualizar a origem do produto, ao mesmo tempo na nota e no produto, automação devido a não poder utilizar a rotina de atualização de cadastro de produto do portal do XML, devido ao fato de nem sempre o fornecedor utilizar as informações corretas.
  Autor          : Lucas Gabriel - DM TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: tabela TGFITE, BEFORE EACH ROW UPDATE, ENABLED; criada em 24/01/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".; acrescentados "/" antes do ALTER TRIGGER e ";" final).
                   - Cabeçalho ainda não padronizado — revisar.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "TRG_UPD_ORIGPROD_SPARK" 
BEFORE UPDATE ON TGFITE 
FOR EACH ROW
DECLARE 
/******************************************************************************
Autor: Lucas Gabriel - DM TECH
Data: 24/01/2025
Objetivo: Atualizar a origem do produto, ao mesmo tempo na nota e no produto,
automação devido a não poder utilizar a rotina de atualização de cadastro de produto 
do portal do XML, devido ao fato de nem sempre o fornecedor utilizar as informações corretas.
******************************************************************************/
	V_NUNOTA    TGFITE.NUNOTA%TYPE;
    V_CODPROD   TGFITE.CODPROD%TYPE;
    V_SEQUENCIA TGFITE.SEQUENCIA%TYPE;
    V_ORIGPROD  TGFITE.AD_ORIGPROD%TYPE;
    V_TIPMOV    TGFCAB.TIPMOV%TYPE;

	BEGIN
		V_NUNOTA     := :NEW.NUNOTA;
        V_CODPROD    := :NEW.CODPROD;
        V_SEQUENCIA  := :NEW.SEQUENCIA;
        V_ORIGPROD   := :NEW.AD_ORIGPROD;

		BEGIN
			SELECT CAB.TIPMOV INTO V_TIPMOV
			FROM TGFCAB CAB
			WHERE CAB.NUNOTA = V_NUNOTA;

			IF V_TIPMOV = 'C' AND V_ORIGPROD IS NOT NULL
			THEN
				:NEW.ORIGPROD := :NEW.AD_ORIGPROD;

				UPDATE TGFPRO 
				SET ORIGPROD = V_ORIGPROD
				WHERE CODPROD = V_CODPROD;
			END IF;
		END;
	END;
/
ALTER TRIGGER "TRG_UPD_ORIGPROD_SPARK" ENABLE;
