/*==============================================================================
  Nome do Script : STP_TROCA_NUMTRANSF
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Troca o NUMTRANSF de TGMTRA (antigo para novo) para a nota e suas variações (SNK_GET_VAR), no compromisso de maior CODMETA; usada por TRG_INC_TGFVAR.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 08/12/2021.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_TROCA_NUMTRANSF', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_TROCA_NUMTRANSF" (P_NUMTRANSF TGMTRA.NUMTRANSF%TYPE, P_NEWNUMTRANSF TGMTRA.NUMTRANSF%TYPE, P_NUNOTA NUMBER)
AS
BEGIN  
    UPDATE TGMTRA T
	   SET NUMTRANSF=P_NEWNUMTRANSF 
	 WHERE T.NUMTRANSF = P_NUMTRANSF 
	   AND (T.NUNOTA = P_NUNOTA OR T.NUNOTA IN (SNK_GET_VAR(P_NUNOTA)))
	   AND T.CODMETA = (SELECT MAX(CODMETA) FROM TGMTRA T2 WHERE T2.NUMTRANSF = P_NUMTRANSF);
END;
