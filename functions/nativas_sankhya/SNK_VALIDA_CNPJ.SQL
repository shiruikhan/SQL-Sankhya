/*==============================================================================
  Nome do Script : SNK_VALIDA_CNPJ
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Valida os digitos verificadores de um CNPJ, com opcao de remover mascara
                  antes de validar.
  Assinatura     : SNK_VALIDA_CNPJ (P_CNPJ IN CHAR, P_REMOVE_MASK IN NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_VALIDA_CNPJ', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_VALIDA_CNPJ (P_CNPJ IN CHAR, P_REMOVE_MASK IN NUMBER) RETURN NUMBER
AS
   M_TOTAL     NUMBER   :=  0;
   M_DIGITO    NUMBER   :=  0;
   M_CNPJ  VARCHAR2(255);
BEGIN
  IF  P_REMOVE_MASK = 1 THEN
  	M_CNPJ := TRIM(REGEXP_REPLACE(P_CNPJ, '[-_\./ ]', ''));
  ELSE
	M_CNPJ := TRIM(P_CNPJ);
  END IF;

 IF P_CNPJ IS NULL OR LENGTH(M_CNPJ) <> 14 OR REGEXP_LIKE(M_CNPJ, '[^0-9]')  THEN
 	RETURN 0;
 END IF;

 FOR I IN 1..4 LOOP
     M_TOTAL := M_TOTAL + SUBSTR(M_CNPJ,I,1) * (6 - I);
 END LOOP;

 FOR I IN 5..12 LOOP
     M_TOTAL := M_TOTAL + SUBSTR(M_CNPJ,I,1) * (14 - I);
 END LOOP;

 M_DIGITO := 11 - MOD(M_TOTAL,11);

 IF M_DIGITO > 9 THEN
    M_DIGITO := 0;
 END IF;

 IF M_DIGITO != SUBSTR(M_CNPJ,13,1) THEN
    RETURN 0;
 END IF;

 M_DIGITO := 0;
 M_TOTAL  := 0;

 FOR I IN 1..5 LOOP
     M_TOTAL := M_TOTAL + SUBSTR(M_CNPJ,I,1) * (7 - I);
 END LOOP;

 FOR I IN 6..13 LOOP
     M_TOTAL := M_TOTAL + SUBSTR(M_CNPJ,I,1) * (15 - I);
 END LOOP;

 M_DIGITO := 11 - MOD(M_TOTAL,11);

 IF M_DIGITO > 9 THEN
    M_DIGITO := 0;
 END IF;

 IF M_DIGITO != SUBSTR(M_CNPJ,14,1) THEN
    RETURN 0;
 END IF;

 RETURN 1;
END;
