/*==============================================================================
  Nome do Script : GET_TSIPAR_DATA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o parametro de sistema do tipo data (TSIPAR.DATA)
                  pela chave.
  Assinatura     : GET_TSIPAR_DATA ( P_PARAMETRO IN VARCHAR ) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_DATA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_DATA ( P_PARAMETRO IN VARCHAR )
   RETURN DATE IS
   V_DATA   DATE;
BEGIN
   BEGIN
      SELECT NVL(DATA, '')
        INTO V_DATA
        FROM TSIPAR
       WHERE CHAVE = P_PARAMETRO;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     V_DATA   := '';
   END;

   RETURN V_DATA;
END;
