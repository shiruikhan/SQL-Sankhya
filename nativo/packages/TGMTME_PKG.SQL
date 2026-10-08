/*==============================================================================
  Nome do Script : TGMTME_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Variaveis de controle da meta por TOP (TGMTME): flag e
                  valores novos/anteriores (meta, TOP, receita/despesa,
                  usuario, compromisso).
  Uso            : Triggers do modulo de metas.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGMTME_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGMTME_PKG AS  
	V_FLAG 		    BINARY_INTEGER := 0;
	V_CODMETA       TGMTME.CODMETA%TYPE;
	V_CODTIPOPER    TGMTME.CODTIPOPER%TYPE; 
	V_RECDESP       TGMTME.RECDESP%TYPE; 
	V_CODUSU        TGMTME.CODUSU%TYPE; 
	V_DTALTER       TGMTME.DTALTER%TYPE; 
	V_COMPROMISSO   TGMTME.COMPROMISSO%TYPE; 
	V_CODMETA_D     TGMTME.CODMETA%TYPE;
	V_CODTIPOPER_D  TGMTME.CODTIPOPER%TYPE; 
END;
