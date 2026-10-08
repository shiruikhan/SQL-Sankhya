/*==============================================================================
  Nome do Script : FLW_GET_CAMPO_INT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a variavel inteira (NUMINT) de uma instancia de
                  processo do workflow (TWFIVAR).
  Assinatura     : FLW_GET_CAMPO_INT (P_INSTANCIA_PROCESSO NUMBER, P_NOME
                  VARCHAR2) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FLW_GET_CAMPO_INT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FLW_GET_CAMPO_INT (P_INSTANCIA_PROCESSO NUMBER, P_NOME VARCHAR2)
RETURN NUMBER
AS  
    P_VALOR NUMBER(10);
BEGIN
    BEGIN
        SELECT TWFIVAR.NUMINT INTO P_VALOR
        FROM TWFIVAR
        WHERE TWFIVAR.IDINSTPRN = P_INSTANCIA_PROCESSO
          AND TWFIVAR.NOME = P_NOME;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
      
    RETURN P_VALOR;
END;
