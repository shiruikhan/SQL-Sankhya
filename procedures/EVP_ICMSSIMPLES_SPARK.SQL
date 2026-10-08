/*==============================================================================
  Nome do Script : EVP_ICMSSIMPLES_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : Não levar mais o ICMS do Simples nacional em campos proprio, devido a adequação da legislação, a costumização se fez necessaria para não ter que separar em top, aquisição de RPTA e simples, facilitar a vida do fiscal.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 31/03/2025, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "EVP_ICMSSIMPLES_SPARK" (
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
	   V_SIMPLES TGFPAR.SIMPLES%TYPE;
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
Data: 31/03/2025
Objetivo: Não levar mais o ICMS do Simples nacional em campos proprio, devido 
a adequação da legislação, a costumização se fez necessaria para não ter que 
separar em top, aquisição de RPTA e simples, facilitar a vida do fiscal.
********************************************************************************/

     IF P_TIPOEVENTO = BEFORE_INSERT
	  OR P_TIPOEVENTO = BEFORE_UPDATE
	 THEN
		SELECT NVL(PAR.SIMPLES,'N')
		 INTO V_SIMPLES
		  FROM TGFPAR PAR 
		 WHERE PAR.CODPARC = EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPARC');
		IF V_SIMPLES = 'S'
		  AND EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODCFO') < 3000 
		  AND TRUNC(EVP_GET_CAMPO_DTA(P_IDSESSAO, 'DHMOV')) >= '01/04/2025'
		  AND EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODCFO') IN (1101,2101,1124,2124,1125,2125,2102,1102,2116,1116)
		   THEN 
            EVP_SET_CAMPO_TEXTO(P_IDSESSAO,  'TIPICMS', 3);
			EVP_SET_CAMPO_INT(P_IDSESSAO,  'TIPICMS', 3);
			EVP_SET_CAMPO_INT(P_IDSESSAO,  'CODTRIB',  90);
			EVP_SET_CAMPO_DEC(P_IDSESSAO,  'BASEICMS', 0);
			EVP_SET_CAMPO_DEC(P_IDSESSAO,  'ALIQICMS', 0);
			EVP_SET_CAMPO_DEC(P_IDSESSAO,  'VLRICMS', 0);
            EVP_SET_CAMPO_DEC(P_IDSESSAO,  'OUTRASICMS',EVP_GET_CAMPO_DEC(P_IDSESSAO, 'VLRCTB'));
		END IF;
     END IF;
END;
