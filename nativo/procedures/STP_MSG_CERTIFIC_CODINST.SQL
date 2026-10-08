/*==============================================================================
  Nome do Script : STP_MSG_CERTIFIC_CODINST
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Devolve a descrição de uma instância (centro de resultado, natureza, projeto, TOP, local, conta bancária …) a partir do nome da instância e da chave, para compor mensagens do módulo de certificação.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 29/05/2026.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_MSG_CERTIFIC_CODINST', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_MSG_CERTIFIC_CODINST" (
   P_INST             IN VARCHAR2,
   P_CHAVE            IN NUMBER,
   P_MSG              OUT VARCHAR2   )
AS
BEGIN
    IF P_CHAVE IS NULL THEN
    P_MSG := '';   
    ELSIF UPPER(P_INST) = 'CENTRO DE RESULTADO' THEN
      SELECT SNK_TRIM(DESCRCENCUS)
      INTO P_MSG
      FROM TSICUS
      WHERE CODCENCUS = P_CHAVE;

    ELSIF UPPER(P_INST) = 'NATUREZA' THEN
      SELECT SNK_TRIM(DESCRNAT)
      INTO P_MSG
      FROM TGFNAT
      WHERE CODNAT = P_CHAVE;

    ELSIF UPPER(P_INST) = 'PROJETO' THEN
      SELECT SNK_TRIM(IDENTIFICACAO)
      INTO P_MSG
      FROM TCSPRJ
      WHERE CODPROJ = P_CHAVE;

    ELSIF UPPER(P_INST) = 'TOP' THEN
      SELECT SNK_TRIM(MIN(DESCROPER))
      INTO P_MSG
      FROM TGFTOP
      WHERE CODTIPOPER = P_CHAVE;

    ELSIF UPPER(P_INST) = 'LOCAL' THEN
      SELECT SNK_TRIM(DESCRLOCAL)
      INTO P_MSG
      FROM TGFLOC
      WHERE CODLOCAL = P_CHAVE; 

    ELSIF UPPER(P_INST) = 'CONTA BANCARIA' THEN
      SELECT SNK_TRIM(DESCRICAO)
      INTO P_MSG
      FROM TSICTA
      WHERE CODCTABCOINT = P_CHAVE; 

    ELSIF UPPER(P_INST) = 'TIPO DE NEGOCIAC?O' THEN
      SELECT SNK_TRIM(MIN(DESCRTIPVENDA))
      INTO P_MSG
      FROM TGFTPV
      WHERE CODTIPVENDA = P_CHAVE;

    ELSIF UPPER(P_INST) = 'PARCEIRO' THEN
      SELECT SNK_TRIM(NOMEPARC)
      INTO P_MSG
      FROM TGFPAR
      WHERE CODPARC = P_CHAVE;
   
    ELSIF UPPER(P_INST) = 'PRODUTO' THEN
      SELECT SNK_TRIM(DESCRPROD)
      INTO P_MSG 
      FROM TGFPRO
      WHERE CODPROD = P_CHAVE; 

    ELSIF UPPER(P_INST) = 'GRUPO DE PRODUTO' THEN
      SELECT SNK_TRIM(DESCRGRUPOPROD)
      INTO P_MSG
      FROM TGFGRU
      WHERE CODGRUPOPROD = P_CHAVE; 

    ELSIF UPPER(P_INST) = 'EMPRESA' THEN
      SELECT SNK_TRIM(NOMEFANTASIA)
      INTO P_MSG
      FROM TSIEMP
      WHERE CODEMP = P_CHAVE;
        
    ELSIF UPPER(P_INST) = 'DEPARTAMENTO' THEN
      SELECT SNK_TRIM(DESCRDEP)
      INTO P_MSG
      FROM TFPDEP
      WHERE CODDEP = P_CHAVE;
    
    ELSE
      P_MSG := '';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    P_MSG := '0';    
END;
