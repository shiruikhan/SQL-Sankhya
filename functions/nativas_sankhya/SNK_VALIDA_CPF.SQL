/*==============================================================================
  Nome do Script : SNK_VALIDA_CPF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Valida os digitos verificadores de um CPF, com opcao de remover mascara
                  antes de validar.
  Assinatura     : SNK_VALIDA_CPF (P_CPF IN CHAR, P_REMOVE_MASK IN NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_VALIDA_CPF', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_VALIDA_CPF (P_CPF IN CHAR, P_REMOVE_MASK IN NUMBER) RETURN NUMBER IS
  M_TOTAL  NUMBER := 0;
  M_DIGITO NUMBER := 0;
  M_CPF VARCHAR2(255);
BEGIN
  IF P_REMOVE_MASK = 1 THEN
	  M_CPF := TRIM(REGEXP_REPLACE(P_CPF, '[-_\. ]', ''));
  ELSE
	M_CPF := TRIM(P_CPF);
  END IF;
 
 IF P_CPF IS NULL OR LENGTH(M_CPF) <> 11 OR REGEXP_LIKE(P_CPF, '[^0-9]') THEN
 	RETURN 0;
 END IF;

  FOR I IN 1 .. 9 LOOP
    M_TOTAL := M_TOTAL + SUBSTR(M_CPF, I, 1) * (11 - I);
  END LOOP;

  M_DIGITO := 11 - MOD(M_TOTAL, 11);

  IF M_DIGITO > 9 THEN
    M_DIGITO := 0;
  END IF;

  IF M_DIGITO != SUBSTR(M_CPF, 10, 1) THEN
    RETURN 0;
  END IF;

  M_DIGITO := 0;
  M_TOTAL  := 0;

  FOR I IN 1 .. 10 LOOP
    M_TOTAL := M_TOTAL + SUBSTR(M_CPF, I, 1) * (12 - I);
  END LOOP;

  M_DIGITO := 11 - MOD(M_TOTAL, 11);

  IF M_DIGITO > 9 THEN
    M_DIGITO := 0;
  END IF;

  IF M_DIGITO != SUBSTR(M_CPF, 11, 1) THEN
    RETURN 0;
  END IF;

  RETURN 1;
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN 0;
END;
