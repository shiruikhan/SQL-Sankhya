create or replace PROCEDURE STP_IMPRIMIETIQUETA_SPARK (P_NUNOTA FLOAT,
       P_DTIMPRESS TIMESTAMP,
       P_CODPROD FLOAT)
AS
/*==============================================================================
  Nome do Script : STP_IMPRIMIETIQUETA_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Procedure para registro de impressão de etiquetas de produtos.
                   Atualiza data/hora de impressão em registros de itens de nota.

  Parâmetros     : P_NUNOTA     — número único da nota fiscal
                   P_DTIMPRESS  — data e hora da impressão da etiqueta
                   P_CODPROD    — código do produto

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
  DECLARE
  P_Notas       VARCHAR2(1);

BEGIN

UPDATE TGFITE SET AD_DHIMPRESSAO=P_DTIMPRESS WHERE CODPROD=P_CODPROD AND NUNOTA=P_NUNOTA;

END;
END;