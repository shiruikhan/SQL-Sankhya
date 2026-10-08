/*==============================================================================
  Nome do Script : STP_POPULA_MSG
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Levanta ORA-20101 com a mensagem padrão "registro não cadastrado, inativo ou não analítico" para a tabela informada, usando a descrição da instância em TDDINS.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 11/07/2023.
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('PROCEDURE', 'STP_POPULA_MSG', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_POPULA_MSG" (P_TABMAE VARCHAR2)
AS
BEGIN
  DECLARE
    P_DESCRINSTANCIA    VARCHAR2(255);
  BEGIN
    BEGIN
       SELECT DESCRINSTANCIA INTO P_DESCRINSTANCIA
		 FROM TDDINS
        WHERE NUINSTANCIA = ( SELECT
								 MIN (NUINSTANCIA)
								FROM TDDINS
							   WHERE NOMETAB = P_TABMAE
								 AND NUINSTANCIAPAI IS NULL );
	
    EXCEPTION WHEN NO_DATA_FOUND THEN
      P_DESCRINSTANCIA := NULL;
    END;
  
    IF P_DESCRINSTANCIA IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20101, 'O registro de "' || P_DESCRINSTANCIA || '" (' || P_TABMAE || ') selecionado não está cadastrado, ou não está ativo, ou não é analítico.');
    ELSE 
      RAISE_APPLICATION_ERROR(-20101, 'A linha referenciada na tabela '|| P_TABMAE ||' não está cadastrada, ou não está ativa, ou não é analítica.');
    END IF ;
  END;
END;
