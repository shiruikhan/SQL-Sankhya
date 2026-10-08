/*==============================================================================
  Nome do Script : VGF_OBSNOTAS2_SPARK
  Tipo           : View
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 28/01/2022, última alteração em 02/04/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGF_OBSNOTAS2_SPARK" ("NUNOTA", "NUMNOTA", "OBSDEV") AS 
  SELECT CAB.NUNOTA AS NUNOTA
	,CAB.NUMNOTA AS NUMNOTA
	,'Troca em garantia seguindo vigência: ' || TO_CHAR(CAB.AD_DTVENCGAR, 'DD/MM/YYYY') AS OBSDEV 
FROM TGFCAB CAB
WHERE CAB.CODTIPOPER = 1215
	AND CAB.NUNOTA = 1962

UNION ALL

SELECT CAB.NUNOTA AS NUNOTA
	,CAB.NUMNOTA AS NUMNOTA
	,'Remessa de merc. em comodato devido a contrato: ' || CAB.AD_NUCONTRCOMOD AS OBSDEV 
FROM TGFCAB CAB
WHERE CAB.CODTIPOPER IN (1109)
	AND CAB.NUNOTA = 1962
	
UNION ALL 
SELECT 
	 CAB.NUNOTA AS NUNOTA
	,CAB.NUMNOTA AS NUMNOTA
	,'Procedimento autorizado pelo Ajuste SINIEF 49/2025' AS OBSDEV
FROM TGFCAB CAB 
WHERE CAB.CODTIPOPER IN (1111,1112);
