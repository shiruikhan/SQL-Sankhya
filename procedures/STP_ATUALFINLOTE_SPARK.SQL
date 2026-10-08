/*==============================================================================
  Nome do Script : STP_ATUALFINLOTE_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Ajustar data de vencimento de mais de um titulo de uma so vez.
  Autor          : Lucas Gabriel - DM TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 14/01/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_ATUALFINLOTE_SPARK" (
       P_CODUSU NUMBER,       
       P_IDSESSAO VARCHAR2,    
       P_QTDLINHAS NUMBER,     
       P_MENSAGEM OUT VARCHAR2 
) AS
       PARAM_P_DATA DATE;
       FIELD_NUFIN NUMBER;
	   /******************************************************
	   Autor: Lucas Gabriel - DM TECH
	   Data: 14/01/2025
	   Objetivo: Ajustar data de vencimento de mais de um titulo 
	   de uma so vez.
	   ******************************************************/
BEGIN
		PARAM_P_DATA := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATA');

       FOR I IN 1..P_QTDLINHAS 
       LOOP                    

           FIELD_NUFIN := ACT_INT_FIELD(P_IDSESSAO, I, 'NUFIN');

			UPDATE TGFFIN 
			SET DTVENC = PARAM_P_DATA
		WHERE NUFIN = FIELD_NUFIN;

       END LOOP;
	   P_MENSAGEM :=  'Data dos vencimentos dos titulos selecionados foram alteradas com sucesso!';
END;
