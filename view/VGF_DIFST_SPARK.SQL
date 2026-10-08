/*==============================================================================
  Nome do Script : VGF_DIFST_SPARK
  Tipo           : View
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 12/03/2026, última alteração em 12/03/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGF_DIFST_SPARK" ("NUNOTA", "SEQUENCIA", "BASE", "ALIQUOTA", "VALOR") AS 
  SELECT 
     NUNOTA,
     SEQUENCIA,
     BASE,
     ALIQUOTA,
     VALOR
FROM TGFIMN
WHERE CODIMP = 17;
