/*==============================================================================
  Nome do Script : GET_TSIPAR_USUARIO_INTEIRO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Parametro inteiro do usuario logado em TSIPAR, com fallback
                  para o valor geral (CODUSU = 0).
  Assinatura     : GET_TSIPAR_USUARIO_INTEIRO (P_CHAVE VARCHAR2) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_USUARIO_INTEIRO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_USUARIO_INTEIRO (P_CHAVE VARCHAR2)
RETURN NUMBER IS
V_RETORNO    NUMBER(10);
BEGIN
  BEGIN
      SELECT INTEIRO INTO V_RETORNO
      FROM TSIPAR 
      WHERE CHAVE = P_CHAVE
        AND CODUSU = STP_GET_CODUSULOGADO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
          SELECT INTEIRO INTO V_RETORNO
          FROM TSIPAR 
          WHERE CHAVE = P_CHAVE
            AND CODUSU = 0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_RETORNO := 0;
      END;
  END;
   
  RETURN(V_RETORNO);
END;
