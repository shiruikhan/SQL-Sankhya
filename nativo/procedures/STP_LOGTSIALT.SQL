/*==============================================================================
  Nome do Script : STP_LOGTSIALT
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Grava em TSIALT o novo conteúdo de um campo alterado (tabela, chave, campo, data/hora): atualiza o registro se já existe a mesma combinação, senão insere. É a mais chamada pelas triggers nativas (24 chamadas).
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 08/12/2021.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_LOGTSIALT', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_LOGTSIALT" (
    P_NOMETAB IN VARCHAR2,
    P_CHAVE   IN VARCHAR2,
    P_CAMPO   IN VARCHAR2,
    P_NEW     IN VARCHAR2,
    P_DHACAO  IN DATE DEFAULT SYSDATE )
AS
  P_COUNT NUMBER(5);
BEGIN
  BEGIN
    SELECT COUNT(1)
    INTO P_COUNT
    FROM TSIALT
    WHERE NOMETAB = P_NOMETAB
    AND DHACAO    = P_DHACAO
    AND CHAVE     = P_CHAVE
    AND CAMPO     = P_CAMPO;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  IF P_COUNT > 0 THEN
    UPDATE TSIALT
    SET CONTEUDO  = P_NEW
    WHERE NOMETAB = P_NOMETAB
    AND DHACAO    = P_DHACAO
    AND CHAVE     = P_CHAVE
    AND CAMPO     = P_CAMPO;
  ELSE
    INSERT
    INTO TSIALT
      (
        NOMETAB,
        DHACAO,
        CHAVE,
        CAMPO,
        CONTEUDO
      )
      VALUES
      (
        P_NOMETAB,
        P_DHACAO,
        P_CHAVE,
        P_CAMPO,
        P_NEW
      );
  END IF;
END;
