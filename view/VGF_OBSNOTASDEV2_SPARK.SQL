/*==============================================================================
  Nome do Script : VGF_OBSNOTASDEV2_SPARK
  Tipo           : View
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 12/11/2025, última alteração em 26/08/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGF_OBSNOTASDEV2_SPARK" ("NUNOTA_DEV", "NUMNOTA_DEV", "NUNOTAS_VENDA", "OBSDEV") AS 
  WITH BASE AS (
  SELECT
      CAB.NUNOTA                    AS NUNOTA_DEV
    , CAB.NUMNOTA                   AS NUMNOTA_DEV
    , VAR.NUNOTAORIG                AS NUNOTA_VENDA
    , CAB2.NUMNOTA                  AS NUMNOTA_VENDA
    , CAB2.DTNEG                    AS DATA_VENDA
    , CAB2.CHAVENFE                 AS CHAVENFE_VENDA
    , CAB.AD_MOTIVODEV              AS MOTIVODEV
    , SUM(VAR.QTDATENDIDA)          AS QTD_DEVOLVIDA
    , (SELECT SUM(ITE1.QTDNEG)
         FROM TGFITE ITE1
        WHERE ITE1.NUNOTA = VAR.NUNOTAORIG) AS QTD_VENDIDA
  FROM TGFCAB CAB
  JOIN TGFVAR VAR   ON VAR.NUNOTA  = CAB.NUNOTA
  JOIN TGFCAB CAB2  ON CAB2.NUNOTA = VAR.NUNOTAORIG
  WHERE CAB.CODTIPOPER IN (300,301,305,306,1200,1206,308,331,1204,1266,1314,1234)
  GROUP BY
      CAB.NUNOTA, CAB.NUMNOTA,
      VAR.NUNOTAORIG, CAB2.NUMNOTA, CAB2.DTNEG, CAB2.CHAVENFE,
      CAB.AD_MOTIVODEV
),
DESC_POR_ORIGEM AS (
  SELECT
      B.*
    , 'Devolucao Ref. NFe: ' || B.NUMNOTA_VENDA
      || ' |Chave: ' || B.CHAVENFE_VENDA
      || ' |Emitida em: ' || TO_CHAR(B.DATA_VENDA,'DD/MM/YYYY')
      || ' |Devolucao Conforme Motivo: ' || CASE
            WHEN B.MOTIVODEV IS NULL THEN 'Devolução Acordada'
            WHEN B.MOTIVODEV = '1'    THEN 'Desistencia Compra'
            WHEN B.MOTIVODEV = '2'    THEN 'Desacordo Comercial'
            WHEN B.MOTIVODEV = '3'    THEN 'Avaria ou Defeito de Produto'
            WHEN B.MOTIVODEV = '4'    THEN 'Falta de Mercadoria'
            ELSE 'Vazio'
         END
      || ' |Dev. de mercadorias: '
      || CASE WHEN B.QTD_DEVOLVIDA < B.QTD_VENDIDA THEN 'Parcial' ELSE 'Total' END
      AS OBSDEV_ITEM
  FROM BASE B
)
SELECT
    NUNOTA_DEV
  , NUMNOTA_DEV
  , LISTAGG(NUNOTA_VENDA, ', ') WITHIN GROUP (ORDER BY DATA_VENDA) AS NUNOTAS_VENDA
  , LISTAGG(OBSDEV_ITEM, CHR(10)) WITHIN GROUP (ORDER BY DATA_VENDA) AS OBSDEV
FROM DESC_POR_ORIGEM
GROUP BY NUNOTA_DEV, NUMNOTA_DEV;
