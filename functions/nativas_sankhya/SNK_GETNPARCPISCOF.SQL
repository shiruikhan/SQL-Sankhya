/*==============================================================================
  Nome do Script : SNK_GETNPARCPISCOF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o numero de parcelas para apropriacao de credito de PIS/COFINS de
                  bens do imobilizado, conforme regra da MP 540/2011.
  Assinatura     : SNK_GETNPARCPISCOF (P_NPARCPISCOF INT, P_PISCOFMP540 CHAR, P_DTCOMPRA DATE)
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETNPARCPISCOF', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETNPARCPISCOF (P_NPARCPISCOF INT, P_PISCOFMP540 CHAR, P_DTCOMPRA DATE) RETURN INT
IS
   P_MESES INT;
BEGIN
/*
Func?o que retorna o numero parcelas para apropriac?o do credito de PIS/COFINS pelo valor de aquisic?o considerando a MP 540
*/

    IF P_PISCOFMP540 = 'S' THEN
    	BEGIN
		    IF P_DTCOMPRA < TO_DATE('03/08/2011', 'DD/MM/YYYY') THEN
			    P_MESES := 0;
			ELSE
			    IF P_DTCOMPRA >= TO_DATE('01/07/2012', 'DD/MM/YYYY') THEN
				    P_MESES := 1;
				ELSE
				    P_MESES := MONTHS_BETWEEN(TO_DATE('01/07/2012', 'DD/MM/YYYY'), TRUNC(P_DTCOMPRA, 'MM'));
				END IF;
			END IF;
		END;
    ELSE  
	   P_MESES := P_NPARCPISCOF;
    END IF;
    RETURN P_MESES;
END;

 
 
