/*==============================================================================
  Nome do Script : GET_TSIPAR_USUARIO_TEXTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Parametro texto do usuario logado em TSIPAR, com fallback
                  para o valor geral (CODUSU = 0).
  Assinatura     : GET_TSIPAR_USUARIO_TEXTO (P_CHAVE VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_USUARIO_TEXTO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_USUARIO_TEXTO (P_CHAVE VARCHAR2)
RETURN VARCHAR2 IS
V_RETORNO    VARCHAR2(4000);
BEGIN
  BEGIN
      SELECT TEXTO INTO V_RETORNO
      FROM TSIPAR 
      WHERE CHAVE = P_CHAVE
        AND CODUSU = STP_GET_CODUSULOGADO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
          SELECT TEXTO INTO V_RETORNO
          FROM TSIPAR 
          WHERE CHAVE = P_CHAVE
            AND CODUSU = 0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_RETORNO := '';
      END;
  END;
   
  RETURN(V_RETORNO);
END;
