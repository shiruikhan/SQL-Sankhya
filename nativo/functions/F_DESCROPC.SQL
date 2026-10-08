/*==============================================================================
  Nome do Script : F_DESCROPC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a descricao da opcao (TDDOPC) de um campo (TDDCAM)
                  para um valor de lista.
  Assinatura     : F_DESCROPC ( P_NOMETAB TDDCAM.NOMETAB%TYPE, P_NOMECAMPO
                  TDDCAM.NOMECAMPO%TYPE, P_VALOR TDDOPC.VALOR%TYPE) RETURN
                  TDDOPC.OPCAO%TYPE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_DESCROPC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_DESCROPC (
	P_NOMETAB			TDDCAM.NOMETAB%TYPE, 
	P_NOMECAMPO			TDDCAM.NOMECAMPO%TYPE,
	P_VALOR				TDDOPC.VALOR%TYPE)
RETURN TDDOPC.OPCAO%TYPE
IS
	V_OPCAO				TDDOPC.OPCAO%TYPE;
BEGIN

	SELECT
		OPC.OPCAO
		INTO V_OPCAO
	FROM
		TDDOPC OPC
		join TDDCAM CAM on OPC.NUCAMPO = CAM.NUCAMPO
	WHERE
		CAM.NOMETAB = P_NOMETAB 
		and CAM.NOMECAMPO = P_NOMECAMPO
		and OPC.VALOR = P_VALOR;

	RETURN(V_OPCAO);

END;
