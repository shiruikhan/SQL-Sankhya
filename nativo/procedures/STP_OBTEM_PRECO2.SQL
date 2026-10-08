/*==============================================================================
  Nome do Script : STP_OBTEM_PRECO2
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Wrapper de SNK_GET_PRECO(NUTAB, CODPROD, DTVIGOR) que devolve o preço vigente em P_PRECO (OUT). Usada por SNK_PRECO.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 06/06/2025.
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('PROCEDURE', 'STP_OBTEM_PRECO2', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_OBTEM_PRECO2" (
       P_NUTAB    INT,
       P_CODPROD  INT,
       P_DTVIGOR  DATE,
       P_PRECO  OUT  FLOAT)
AS
BEGIN
   P_PRECO := SNK_GET_PRECO( P_NUTAB, P_CODPROD, P_DTVIGOR );
END;
