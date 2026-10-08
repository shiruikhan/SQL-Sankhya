/*==============================================================================
  Nome do Script : GET_TSIPAR_TEXTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o parametro de sistema texto (TSIPAR.TEXTO, CODUSU =
                  0) pela chave.
  Assinatura     : GET_TSIPAR_TEXTO ( P_PARAMETRO IN VARCHAR ) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_TEXTO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_TEXTO ( P_PARAMETRO IN VARCHAR )
   RETURN VARCHAR2 IS
   V_TEXTO   VARCHAR2(4000);
BEGIN
   BEGIN
      SELECT NVL(TEXTO, '')
        INTO V_TEXTO
        FROM TSIPAR
       WHERE CHAVE = P_PARAMETRO
         AND CODUSU = 0;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     V_TEXTO    := '';
   END;

   RETURN V_TEXTO;
END;
