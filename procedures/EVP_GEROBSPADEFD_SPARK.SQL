/*==============================================================================
  Nome do Script : EVP_GEROBSPADEFD_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : Preencher o campo CODOBSPADRAO do cabeçalho da nota para que o SPED entenda que aquela nota precisa de documento relacionado, e apartir dai gere os registro que precise, tentamos via forma nativa de preencher a sugstão no layout porém nem sempre os usuarios clicam em novo gerando erros no EFD.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 11/08/2025, última alteração em 16/04/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "EVP_GEROBSPADEFD_SPARK" (
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
	   V_CODOBS       TGFCAB.CODOBSPADRAO%TYPE;
	   V_CODTIPOPER   TGFCAB.CODTIPOPER%TYPE;
	   V_QTD          INT;
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
Data: 11/08/2025
Objetivo: Preencher o campo CODOBSPADRAO do cabeçalho da nota para que o SPED 
entenda que aquela nota precisa de documento relacionado, e apartir dai gere os 
registro que precise, tentamos via forma nativa de preencher a sugstão no layout 
porém nem sempre os usuarios clicam em novo gerando erros no EFD.

********************************************************************************/

    IF P_TIPOEVENTO = BEFORE_INSERT 
		OR P_TIPOEVENTO = BEFORE_UPDATE
		THEN
		SELECT CODOBSPADRAO
			  ,CODTIPOPER
		INTO V_CODOBS
			,V_CODTIPOPER
		FROM TGFCAB 
		WHERE NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
		SELECT COUNT(0)
		INTO V_QTD
		FROM AD_RELPARMTOP
		WHERE NURELPARM = 1
		  AND CODTIPOPER = V_CODTIPOPER;
		IF V_QTD > 0 THEN
			IF V_CODOBS <> 121
			THEN 
				EVP_SET_CAMPO_INT(P_IDSESSAO,  'CODOBSPADRAO', 121);
			END IF;
		END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND 
	THEN
        NULL; 
END;
