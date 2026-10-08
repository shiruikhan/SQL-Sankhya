/*==============================================================================
  Nome do Script : MULTIPLICA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Multiplica um valor pelo parametro inteiro de TSIPAR (chave
                  informada); 0 se valor nulo/zero ou parametro inexistente.
  Assinatura     : MULTIPLICA (P_VALOR IN NUMBER, P_CHAVE VARCHAR2) RETURN
                  NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'MULTIPLICA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION MULTIPLICA (P_VALOR IN NUMBER, P_CHAVE VARCHAR2)
RETURN NUMBER
IS VLRTOTAL NUMBER;
   WINT NUMBER;
BEGIN
  IF P_VALOR IS NULL OR
     P_VALOR = 0 THEN
    VLRTOTAL := 0;
  ELSE
    BEGIN
      SELECT INTEIRO INTO WINT FROM TSIPAR
      WHERE CHAVE = P_CHAVE AND CODUSU = 0;
      VLRTOTAL := WINT * P_VALOR;
    END;
  END IF;
  RETURN (VLRTOTAL);
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN (0);
END;
