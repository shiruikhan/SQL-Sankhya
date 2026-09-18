/*==============================================================================
  Nome do Script : SNK_GET_CFO_NOTA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o CFO de entrada ou saida configurado na TOP da nota, considerando
                  se a operacao e dentro ou fora do estado.
  Assinatura     : SNK_GET_CFO_NOTA (P_NUNOTA NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CFO_NOTA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CFO_NOTA (P_NUNOTA	NUMBER)
RETURN NUMBER
AS
	P_RESULT				NUMBER;
	P_TIPMOV				VARCHAR(1);
	P_CODEMPNEGOC			NUMBER(10);
	P_CODEMP				NUMBER(10);
	P_CODPARC				NUMBER(10);
	P_CODPARCREMETENTE		NUMBER(10);
	P_CODPARCCONSIGNATARIO	NUMBER(10);
	P_CODPARCDEST			NUMBER(10);
	P_CODCFO_SAIDA			NUMBER(10);
	P_CODCFO_SAIDA_FORA		NUMBER(10);
	P_CODCFO_ENTRADA		NUMBER(10);
	P_CODCFO_ENTRADA_FORA	NUMBER(10);
	P_ATUALLIVFIS			VARCHAR(1);
	P_CFO_FORA				VARCHAR(1);
BEGIN
	BEGIN
		SELECT 
 			 C.TIPMOV
			,C.CODEMPNEGOC
			,C.CODEMP
			,C.CODPARC
			,C.CODPARCREMETENTE
			,C.CODPARCCONSIGNATARIO
			,C.CODPARCDEST
			,T.CODCFO_SAIDA
			,T.CODCFO_SAIDA_FORA
			,T.CODCFO_ENTRADA
			,T.CODCFO_ENTRADA_FORA
			,T.ATUALLIVFIS
		INTO 	
			 P_TIPMOV
			,P_CODEMPNEGOC
			,P_CODEMP
			,P_CODPARC
			,P_CODPARCREMETENTE
			,P_CODPARCCONSIGNATARIO
			,P_CODPARCDEST
			,P_CODCFO_SAIDA
			,P_CODCFO_SAIDA_FORA
			,P_CODCFO_ENTRADA
			,P_CODCFO_ENTRADA_FORA
			,P_ATUALLIVFIS
		FROM TGFCAB C
			,TGFTOP T
		WHERE C.NUNOTA = P_NUNOTA
			AND C.CODTIPOPER = T.CODTIPOPER
			AND C.DHTIPOPER = T.DHALTER;

		P_CFO_FORA := SNK_GET_DENTRO_FORA_ESTADO(P_CODEMP
											    ,P_CODEMPNEGOC
												,P_CODPARC
												,P_CODPARCREMETENTE
												,P_CODPARCCONSIGNATARIO
												,P_CODPARCDEST
												,P_TIPMOV);

		IF P_ATUALLIVFIS = 'E' THEN
			IF P_CFO_FORA = 'S' THEN
				P_RESULT := P_CODCFO_ENTRADA_FORA;
			ELSE
				P_RESULT := P_CODCFO_ENTRADA;
			END IF;
		ELSE
			IF P_CFO_FORA = 'S' THEN
				P_RESULT := P_CODCFO_SAIDA_FORA;
			ELSE
				P_RESULT := P_CODCFO_SAIDA;
			END IF;
		END IF;

		EXCEPTION WHEN NO_DATA_FOUND THEN
			P_RESULT := 0;
		END;

	RETURN P_RESULT;
END;
