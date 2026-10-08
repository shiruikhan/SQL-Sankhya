/*==============================================================================
  Nome do Script : GET_TSIPAR_USUARIO_LOGICO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Parametro logico do usuario logado em TSIPAR, com fallback
                  para o valor geral (CODUSU = 0).
  Assinatura     : GET_TSIPAR_USUARIO_LOGICO (P_CHAVE VARCHAR2) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_USUARIO_LOGICO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_USUARIO_LOGICO (P_CHAVE VARCHAR2)
RETURN CHAR IS
V_RETORNO    CHAR(1);
BEGIN
  BEGIN
      SELECT LOGICO INTO V_RETORNO
      FROM TSIPAR 
      WHERE CHAVE = P_CHAVE
        AND CODUSU = STP_GET_CODUSULOGADO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
          SELECT LOGICO INTO V_RETORNO
          FROM TSIPAR 
          WHERE CHAVE = P_CHAVE
            AND CODUSU = 0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_RETORNO := 'N';
      END;
  END;
   
  RETURN(V_RETORNO);
END;
