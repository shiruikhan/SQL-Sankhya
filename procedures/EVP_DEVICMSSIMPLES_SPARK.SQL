/*==============================================================================
  Nome do Script : EVP_DEVICMSSIMPLES_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : Corrigir as devolução do simples nacional para poder gerar o ajsute posteriormente.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 01/04/2025, última alteração em 29/05/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "EVP_DEVICMSSIMPLES_SPARK" (
       P_TIPOEVENTO INT,    
       P_IDSESSAO VARCHAR2, 
       P_CODUSU INT        
) AS
       BEFORE_INSERT INT;
       AFTER_INSERT  INT;
       BEFORE_DELETE INT;
       AFTER_DELETE  INT;
       BEFORE_UPDATE INT;
       AFTER_UPDATE  INT;
       BEFORE_COMMIT INT;
       V_TIPMOV    TGFCAB.TIPMOV%TYPE;
       V_SIMPLES   TGFPAR.SIMPLES%TYPE;
	   V_BASE      TGFITE.BASEICMS%TYPE;
	   V_BASESP    TGFITE.BASEICMS%TYPE;
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;
/*******************************************************************************
Autor: Lucas Gabriel    
Data:  31/03/2025
Objetivo: Corrigir as devolução do simples nacional para poder gerar o ajsute 
posteriormente.
********************************************************************************/
    IF P_TIPOEVENTO = BEFORE_INSERT 
		OR P_TIPOEVENTO = BEFORE_UPDATE
	THEN

        SELECT NVL(PAR.SIMPLES,'N')
			 , CAB.TIPMOV
        INTO V_SIMPLES
			, V_TIPMOV
        FROM TGFCAB CAB 
        INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
        WHERE CAB.NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
		V_BASE   := EVP_GET_CAMPO_DEC(P_IDSESSAO, 'BASEICMS');
		V_BASESP := EVP_GET_CAMPO_DEC(P_IDSESSAO, 'AD_BASEICMSSP');
        IF V_SIMPLES = 'S' 
			AND V_TIPMOV = 'E'
			 AND V_BASE > 0
			 AND V_BASE <> NVL(V_BASESP,0)
			THEN

            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'AD_BASEICMSSP', EVP_GET_CAMPO_DEC(P_IDSESSAO, 'BASEICMS'));
            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'AD_ALIQICMSSP', EVP_GET_CAMPO_DEC(P_IDSESSAO, 'ALIQICMS'));
            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'AD_VLRICMSSP', EVP_GET_CAMPO_DEC(P_IDSESSAO, 'VLRICMS'));

            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'BASEICMS', 0);
            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'ALIQICMS', 0);
            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'VLRICMS', 0);
        END IF;
    END IF;
END;
