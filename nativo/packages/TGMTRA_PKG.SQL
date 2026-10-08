/*==============================================================================
  Nome do Script : TGMTRA_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Variaveis de controle do rastreio de metas (TGMTRA): flag e
                  chaves de nota, financeiro, empresa, produto, parceiro,
                  regiao e demais dimensoes.
  Uso            : Triggers do modulo de metas.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGMTRA_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGMTRA_PKG 
AS
	V_FLAG BINARY_INTEGER := 0;
	V_NUNOTA TGMTRA.NUNOTA%TYPE;
	V_NUFIN TGMTRA.NUFIN%TYPE;
	V_SINAL TGMTRA.SINAL%TYPE;
	V_STATUS TGMTRA.STATUS%TYPE;
	V_CODMETA TGMTRA.CODMETA%TYPE;
	V_DTREF TGMTRA.DTREF%TYPE;
	V_CODEMP TGMTRA.CODEMP%TYPE;
	V_CODGRUPOPROD TGMTRA.CODGRUPOPROD%TYPE;
	V_CODPROD TGMTRA.CODPROD%TYPE;
	V_CODLOCAL TGMTRA.CODLOCAL%TYPE;
	V_CONTROLE TGMTRA.CONTROLE%TYPE;
	V_MARCA TGMTRA.MARCA%TYPE;
	V_CODREG TGMTRA.CODREG%TYPE;
	V_CODGER TGMTRA.CODGER%TYPE;
	V_CODVEND TGMTRA.CODVEND%TYPE;
	V_CODCENCUS TGMTRA.CODCENCUS%TYPE;
	V_CODNAT TGMTRA.CODNAT%TYPE;
	V_CODPROJ TGMTRA.CODPROJ%TYPE;
	V_CODPARC TGMTRA.CODPARC%TYPE;
	V_CODUF TGMTRA.CODUF%TYPE;
	V_CODCID TGMTRA.CODCID%TYPE;
	V_CODPAIS TGMTRA.CODPAIS%TYPE;
	V_CODTIPPARC TGMTRA.CODTIPPARC%TYPE;
	V_CODGRUPONAT TGMTRA.CODGRUPONAT%TYPE;
END;
