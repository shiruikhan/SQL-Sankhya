/*==============================================================================
  Nome do Script : TIM_DNORM_ENDERECO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Normaliza e escreve o endereco por extenso a partir de
                  codigos de logradouro, bairro e cidade.
  Assinatura     : TIM_DNORM_ENDERECO ( CODEND_IN NUMBER, NUMERO VARCHAR2,
                  COMPLEMENTO VARCHAR2, APTO NUMBER, CODBAI_IN NUMBER,
                  CODCID_IN NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_DNORM_ENDERECO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_DNORM_ENDERECO (
	CODEND_IN      NUMBER,
	NUMERO         VARCHAR2,
	COMPLEMENTO    VARCHAR2,
	APTO           NUMBER,
	CODBAI_IN      NUMBER,
	CODCID_IN      NUMBER)
RETURN VARCHAR2
IS
	CODREG_VAR   NUMBER;
	EXTENSO      VARCHAR2 (500) := '';
BEGIN
	IF CODEND_IN IS NOT NULL AND CODEND_IN != 0
	THEN
		SELECT TIPO || '. ' || NVL (NOMEEND, '<SEM DESCRIÇÃO DO ENDERECO>')
			INTO EXTENSO
			FROM TSIEND
		WHERE CODEND = CODEND_IN;
	END IF;

	IF NUMERO IS NOT NULL
	THEN
		IF (EXTENSO IS NOT NULL)
		THEN
			EXTENSO := EXTENSO || ', ' || NUMERO;
		ELSE
			EXTENSO := NUMERO;
		END IF;
	END IF;

	IF COMPLEMENTO IS NOT NULL
	THEN
		IF (EXTENSO IS NOT NULL)
		THEN
			EXTENSO := EXTENSO || ' ' || COMPLEMENTO;
		ELSE
			EXTENSO := NUMERO;
		END IF;
	END IF;

	IF APTO IS NOT NULL
	THEN
		IF (EXTENSO IS NOT NULL)
		THEN
			EXTENSO := EXTENSO || ' APTO ' || APTO;
		ELSE
			EXTENSO := NUMERO;
		END IF;
	END IF;

	IF CODBAI_IN IS NOT NULL AND CODBAI_IN != 0
	THEN
		SELECT CASE
					WHEN EXTENSO IS NOT NULL
					THEN
						EXTENSO
					|| ', '
					|| NVL (NOMEBAI, '<SEM DESCRIÇÃO DO BAIRRO>')
					ELSE
					NVL (NOMEBAI, '<SEM DESCRIÇÃO DO BAIRRO>')
				END,         
				CODREG
			INTO EXTENSO, CODREG_VAR
			FROM TSIBAI
		WHERE CODBAI = CODBAI_IN;

		IF CODREG_VAR IS NOT NULL AND CODREG_VAR != 0
		THEN
			SELECT CASE
					WHEN EXTENSO IS NOT NULL
					THEN
							EXTENSO
						|| ', '
						|| NVL (NOMEREG, '<SEM DESCRIÇÃO DA REGIÃO>')
					ELSE
						NVL (NOMEREG, '<SEM DESCRIÇÃO DA REGIÃO>')
					END
			INTO EXTENSO
			FROM TSIREG
			WHERE CODREG = CODREG_VAR;
		END IF;
	END IF;

	IF CODCID_IN IS NOT NULL AND CODCID_IN != 0
	THEN
		SELECT CASE
					WHEN EXTENSO IS NOT NULL
					THEN
						EXTENSO
					|| ', '
					|| NVL (NOMECID, '<SEM DESCRIÇÃO DA CIDADE>')
					ELSE
					NVL (NOMECID, '<SEM DESCRIÇÃO DA CIDADE>')
				END,
				CODREG
			INTO EXTENSO, CODREG_VAR
			FROM TSICID
		WHERE CODCID = CODCID_IN;

		IF CODREG_VAR IS NOT NULL AND CODREG_VAR != 0
		THEN
			SELECT CASE
					WHEN EXTENSO IS NOT NULL
					THEN
							EXTENSO
						|| ', '
						|| NVL (NOMEREG, '<SEM DESCRIÇÃO DA REGIÃO>')
					ELSE
						NVL (NOMEREG, '<SEM DESCRIÇÃO DA REGIÃO>')
					END
			INTO EXTENSO
			FROM TSIREG
			WHERE CODREG = CODREG_VAR;
		END IF;
	END IF;

	RETURN EXTENSO;
END;
