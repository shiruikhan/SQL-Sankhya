/*==============================================================================
  Nome do Script : GET_TSIPAR_INTEIRO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o parametro de sistema inteiro (TSIPAR.INTEIRO,
                  CODUSU = 0) pela chave; 0 se nao existir.
  Assinatura     : GET_TSIPAR_INTEIRO ( P_PARAMETRO IN VARCHAR ) RETURN INTEGER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_INTEIRO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_INTEIRO ( P_PARAMETRO IN VARCHAR )
   RETURN INTEGER IS
   V_INTEIRO   INTEGER;
BEGIN
   BEGIN
      SELECT NVL(INTEIRO, 0)
        INTO V_INTEIRO
        FROM TSIPAR
       WHERE CHAVE = P_PARAMETRO
         AND CODUSU = 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         V_INTEIRO    := 0;
   END;

   RETURN V_INTEIRO;
END;
