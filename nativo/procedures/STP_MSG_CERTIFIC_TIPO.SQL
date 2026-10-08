/*==============================================================================
  Nome do Script : STP_MSG_CERTIFIC_TIPO
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Devolve o rótulo textual (usuário, empresa, vendedor, funcionário ou 'Regras Gerais') de um tipo/chave, para mensagens do módulo de certificação.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 12/05/2026.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_MSG_CERTIFIC_TIPO', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_MSG_CERTIFIC_TIPO" (
   P_TIPO             IN VARCHAR,
   P_CHAVE            IN NUMBER,
   P_MSG              OUT VARCHAR2   )
AS
BEGIN
  DECLARE P_DESCR   VARCHAR2(30);
  BEGIN
    IF P_TIPO = 'U' THEN
      SELECT NOMEUSU
      INTO P_DESCR
      FROM TSIUSU
      WHERE CODUSU = P_CHAVE;
      P_MSG := 'Usuario "'|| P_DESCR ||'"';
    ELSIF P_TIPO = 'E' THEN
      SELECT NOMEFANTASIA
      INTO P_DESCR
      FROM TSIEMP
      WHERE CODEMP = P_CHAVE;
      P_MSG := 'Emp."'|| P_DESCR ||'"';
    ELSIF P_TIPO = 'V' THEN
      SELECT APELIDO
      INTO P_DESCR
      FROM TGFVEN
      WHERE CODVEND = P_CHAVE;
      P_MSG := 'Vend."'|| P_DESCR ||'"';
    ELSIF P_TIPO = 'F' THEN
      SELECT NOMEFUNC
      INTO P_DESCR
      FROM TFPFUN
      WHERE CODFUNC = P_CHAVE;
      P_MSG := 'Func."'|| P_DESCR ||'"';
    ELSE
      P_MSG := 'Regras Gerais';
    END IF;
  END;
END;
