/*==============================================================================
  Nome do Script : SNK_GET_CFO_ANT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Ajusta o CFO para a tabela de regras 'antiga' (versao anterior de CFOP),
                  usada como fallback por SNK_GET_CFO.
  Assinatura     : SNK_GET_CFO_ANT (P_TIPSUBST VARCHAR2 ,P_USOPROD VARCHAR2 ,P_CODCFO NUMBER ,P_CONSUMIDOR VARCHAR2)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CFO_ANT', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CFO_ANT (P_TIPSUBST		VARCHAR2
										  ,P_USOPROD		VARCHAR2
										  ,P_CODCFO			NUMBER
										  ,P_CONSUMIDOR		VARCHAR2)
RETURN NUMBER
AS
	P_RESULT		NUMBER(10);
	P_CODCFO_AUX	NUMBER(10);
BEGIN
	P_CODCFO_AUX := NVL(P_CODCFO, 0);
	P_RESULT := P_CODCFO_AUX;

	IF NVL(P_TIPSUBST, '*') <> 'N' THEN
		IF P_CODCFO_AUX = 111 THEN
			P_RESULT := 171;

		ELSIF P_CODCFO_AUX = 112 THEN
			P_RESULT := 172;

		ELSIF P_CODCFO_AUX = 211 THEN
			P_RESULT := 271;

		ELSIF P_CODCFO_AUX = 212 THEN
			P_RESULT := 272;

		ELSIF P_CODCFO_AUX = 122 THEN
			P_RESULT := 176;

		ELSIF P_CODCFO_AUX = 222 THEN
			P_RESULT := 276;

		ELSIF P_CODCFO_AUX = 522 THEN
			P_RESULT := 576;

		ELSIF P_CODCFO_AUX = 622 THEN
			P_RESULT := 676;

		ELSIF P_CODCFO_AUX IN (131, 132) THEN
			IF NVL(P_USOPROD, '*') = 'V' THEN
				P_RESULT := 177;
			ELSE 
				P_RESULT := 178;
			END IF;
		ELSIF P_CODCFO_AUX IN (231, 232) THEN
			IF NVL(P_USOPROD, '*') = 'V' THEN
				P_RESULT := 277;
			ELSE 
				P_RESULT := 278;
			END IF;
		ELSIF P_CODCFO_AUX IN (531, 532) THEN
			IF NVL(P_USOPROD, '*') = 'V' THEN
				P_RESULT := 577;
			ELSE 
				P_RESULT := 578;
			END IF;
		ELSIF P_CODCFO_AUX = 512 THEN
			IF NVL(P_CONSUMIDOR, 'N') = 'S' THEN
				IF NVL(P_USOPROD, '*') = 'V' THEN
					P_RESULT := 572;
				ELSE 
					P_RESULT := 574;
				END IF;
			ELSE
				P_RESULT := 573;
			END IF;
		ELSIF P_CODCFO_AUX = 511 THEN
			IF NVL(P_CONSUMIDOR, 'N') = 'S' THEN
				IF NVL(P_USOPROD, '*') = 'R' THEN
					P_RESULT := 574;
				ELSE 
					P_RESULT := 572;
				END IF;
			ELSE
				P_RESULT := 571;
			END IF;
		ELSIF P_CODCFO_AUX = 612 THEN
			IF NVL(P_CONSUMIDOR, 'N') = 'S' THEN
				IF NVL(P_USOPROD, '*') = 'V' THEN
					P_RESULT := 672;
				ELSE 
					P_RESULT := 674;
				END IF;
			ELSE
				P_RESULT := 673;
			END IF;
		ELSIF P_CODCFO_AUX = 611 THEN
			IF NVL(P_CONSUMIDOR, 'N') = 'S' THEN
				IF NVL(P_USOPROD, '*') = 'R' THEN
					P_RESULT := 674;
				ELSE 
					P_RESULT := 672;
				END IF;
			ELSE
				P_RESULT := 671;
			END IF;

		ELSIF P_CODCFO_AUX IN (631, 632) THEN
			IF NVL(P_USOPROD, '*') = 'V' THEN
				P_RESULT := 677;
			ELSE 
				P_RESULT := 678;
			END IF;
		END IF;
	ELSIF NVL(P_CONSUMIDOR, 'N') = 'S' THEN
		IF P_CODCFO_AUX = 611 THEN
			P_RESULT := 618;

		ELSIF P_CODCFO_AUX = 612 THEN
			P_RESULT := 619;
		END IF;
	END IF;

	RETURN P_RESULT;
END;
