/*==============================================================================
  Nome do Script : FLW_GET_CAMPO_DEC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a variavel decimal (NUMDEC) de uma instancia de
                  processo do workflow (TWFIVAR).
  Assinatura     : FLW_GET_CAMPO_DEC (P_INSTANCIA_PROCESSO NUMBER, P_NOME
                  VARCHAR2) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FLW_GET_CAMPO_DEC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FLW_GET_CAMPO_DEC (P_INSTANCIA_PROCESSO NUMBER, P_NOME VARCHAR2)
RETURN FLOAT
AS  
    P_VALOR FLOAT;
BEGIN 
    BEGIN
        SELECT TWFIVAR.NUMDEC INTO P_VALOR 
        FROM TWFIVAR
        WHERE TWFIVAR.IDINSTPRN = P_INSTANCIA_PROCESSO
          AND TWFIVAR.NOME = P_NOME;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
      
    RETURN P_VALOR;
END;
