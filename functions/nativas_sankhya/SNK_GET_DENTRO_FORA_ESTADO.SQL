/*==============================================================================
  Nome do Script : SNK_GET_DENTRO_FORA_ESTADO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina se uma operacao e dentro ou fora do estado, comparando a UF de
                  origem e destino de parceiro/empresa.
  Assinatura     : SNK_GET_DENTRO_FORA_ESTADO (P_CODEMP NUMBER ,P_CODEMPNEGOC NUMBER ,P_CODPARC NUMBER ,P_CODPARCREMETENTE NUMBER ,P_CODPARCCONSIGNATARIO NUMBER ,P_CODPARCDEST NUMBER ,P_TIPMOV VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DENTRO_FORA_ESTADO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DENTRO_FORA_ESTADO (P_CODEMP					NUMBER
													 ,P_CODEMPNEGOC				NUMBER
													 ,P_CODPARC                 NUMBER
													 ,P_CODPARCREMETENTE        NUMBER
													 ,P_CODPARCCONSIGNATARIO    NUMBER
													 ,P_CODPARCDEST             NUMBER
													 ,P_TIPMOV					VARCHAR2)
RETURN VARCHAR2
AS
	P_RESULT				VARCHAR(1);
	P_CIDPARC_ORIG			NUMBER(10);
	P_CIDPARC_DEST			NUMBER(10);
	P_CIDEMP_AUX			NUMBER(10); /*CRIADA APENAS PARA EVITAR ERRO DE PARAMETRO NA PROCEDURE. SEU VALOR NAO SERA UTILIZADO*/
	P_UF_ORIG				NUMBER(10);
	P_UF_DEST				NUMBER(10);
	P_CODPARC_AUX			NUMBER(10);
	P_CODEMPNEGOC_AUX		NUMBER(10);
	P_TIPMOV_AUX			VARCHAR2(1);
	P_UF_ORIG_STR			VARCHAR2(2);
	P_UF_DEST_STR			VARCHAR2(2);
BEGIN
	P_RESULT := 'N';

	IF (P_TIPMOV = 'V' OR (GET_TSIPAR_USUARIO_LOGICO('USAPARREMDESCPA') = 'S' AND P_TIPMOV = 'C')) 
		AND NVL(P_CODPARCDEST, 0) <> 0 
		AND NVL(P_CODPARCREMETENTE, 0) <> 0 THEN

		STP_END_ICMS(P_CODPARCREMETENTE, 0, P_CIDPARC_ORIG, P_CIDEMP_AUX);
		STP_END_ICMS(P_CODPARCDEST, 0, P_CIDPARC_DEST, P_CIDEMP_AUX);

		IF NVL(P_CIDPARC_ORIG, 0) = NVL(P_CIDPARC_DEST, 0) THEN
			P_RESULT := 'N';
		ELSE
			BEGIN
				SELECT UF INTO P_UF_ORIG
				FROM TSICID
				WHERE CODCID = P_CIDPARC_ORIG;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				P_UF_ORIG := 0;
			END;

			BEGIN
				SELECT UF INTO P_UF_DEST
				FROM TSICID
				WHERE CODCID = P_CIDPARC_DEST;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				P_UF_DEST := 0;
			END;
		
			IF P_UF_ORIG <> P_UF_DEST THEN
				P_RESULT := 'S';
			ELSE 
				P_RESULT := 'N';
			END IF;
		END IF;
	ELSE 
		IF NVL(P_CODPARCDEST, 0) <> 0  AND P_TIPMOV = 'T' THEN
			P_CODPARC_AUX := P_CODPARCDEST;
			P_TIPMOV_AUX := 'V';
		ELSE 
			P_CODPARC_AUX := P_CODPARC;
			P_TIPMOV_AUX := P_TIPMOV;
		END IF;

		IF NVL(P_CODEMPNEGOC, 0) = 0 THEN
			P_CODEMPNEGOC_AUX := P_CODEMP;
		ELSE
			P_CODEMPNEGOC_AUX := P_CODEMPNEGOC;
		END IF;

		IF NVL(P_CODEMP, 0) = 0 OR
			(P_TIPMOV_AUX = 'T' AND NVL(P_CODEMPNEGOC_AUX, 0) = NVL(P_CODEMP, 0)) OR 
			(P_TIPMOV_AUX = 'T' AND NVL(P_CODEMPNEGOC_AUX, 0) = 0) OR 
			(P_TIPMOV_AUX <> 'T' AND NVL(P_CODPARC_AUX, 0) = 0) THEN
			P_RESULT := 'N';
		ELSE
			STP_UF_ORIG_DEST(P_TIPMOV_AUX, P_CODEMP, P_CODEMPNEGOC_AUX, P_CODPARC_AUX, P_UF_ORIG_STR, P_UF_DEST_STR);

			IF NVL(P_UF_ORIG_STR, '*') <> NVL(P_UF_DEST_STR, '*') THEN
				P_RESULT := 'S';
			ELSE
				P_RESULT := 'N';
			END IF;
		END IF;
	END IF;

	RETURN P_RESULT;
END;
