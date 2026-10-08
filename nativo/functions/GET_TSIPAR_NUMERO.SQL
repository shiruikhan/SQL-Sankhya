/*==============================================================================
  Nome do Script : GET_TSIPAR_NUMERO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o parametro de sistema decimal (TSIPAR.NUMDEC,
                  CODUSU = 0) pela chave; 0 se nao existir.
  Assinatura     : GET_TSIPAR_NUMERO ( P_PARAMETRO IN VARCHAR ) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_NUMERO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_NUMERO ( P_PARAMETRO IN VARCHAR )
   RETURN FLOAT IS
   V_VALOR   FLOAT;
BEGIN
   BEGIN
      SELECT NVL( NUMDEC, 0 )
      INTO   V_VALOR
      FROM   TSIPAR
      WHERE  CHAVE = P_PARAMETRO AND CODUSU = 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         V_VALOR := 0;
   END;

   RETURN V_VALOR;
END;
