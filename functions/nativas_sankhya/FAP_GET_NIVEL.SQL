/*==============================================================================
  Nome do Script : FAP_GET_NIVEL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula recursivamente o nivel de uma etapa na arvore de
                  etapas da FAP (TCSFET).
  Assinatura     : FAP_GET_NIVEL ( P_NUFAP IN NUMBER, P_NUMETAPA IN NUMBER,
                  P_NUMSEQ IN NUMBER, P_NUMETAPAPAI IN NUMBER ) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FAP_GET_NIVEL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FAP_GET_NIVEL (
	P_NUFAP IN NUMBER,
	P_NUMETAPA IN NUMBER,
	P_NUMSEQ IN NUMBER,
	P_NUMETAPAPAI IN NUMBER
)
RETURN NUMBER
IS
L_NUMSEQ NUMBER;
L_NUMETAPA NUMBER;
L_NUMETAPAPAI NUMBER;
BEGIN
	IF P_NUMETAPAPAI <> 99999 THEN
		BEGIN  
			SELECT NUMSEQ,
					 NUMETAPA,
					 NUMETAPAPAI 
			  INTO L_NUMSEQ,
			  		 L_NUMETAPA,
			  		 L_NUMETAPAPAI
			  FROM TCSFET
			 WHERE NUFAP = P_NUFAP 
			   AND NUMETAPA = P_NUMETAPAPAI;
			
			RETURN FAP_GET_NIVEL(P_NUFAP,L_NUMETAPA,L_NUMSEQ,L_NUMETAPAPAI) + 1;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
			RETURN 0;
		END;
  ELSE
      RETURN 1;
  END IF;
END;
