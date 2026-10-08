/*==============================================================================
  Nome do Script : VGF_CALCFINIMP_SPARK
  Tipo           : View
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 16/12/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGF_CALCFINIMP_SPARK" ("NUNOTA", "FINACEIRO") AS 
  SELECT 
     CAB.NUNOTA 
    ,SUM( NVL(III.VLRDESPADUA,0) + NVL(III.VLRIMPOSTO,0) + NVL(ITE.VLRICMS,0)) AS FINACEIRO
    
FROM TGFCAB CAB 

INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 
INNER JOIN TGFIDI IDI 
    ON IDI.NUNOTA = CAB.NUNOTA 
        AND IDI.SEQUENCIA = ITE.SEQUENCIA

INNER JOIN TGFIII III
    ON III.NUNOTA = CAB.NUNOTA 
      AND III.SEQUENCIA = ITE.SEQUENCIA

GROUP BY CAB.NUNOTA;
