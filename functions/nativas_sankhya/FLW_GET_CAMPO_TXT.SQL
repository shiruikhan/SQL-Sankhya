/*==============================================================================
  Nome do Script : FLW_GET_CAMPO_TXT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a variavel texto de uma instancia de processo do
                  workflow (TWFIVAR).
  Assinatura     : FLW_GET_CAMPO_TXT (P_INSTANCIA_PROCESSO NUMBER, P_NOME
                  VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FLW_GET_CAMPO_TXT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FLW_GET_CAMPO_TXT (P_INSTANCIA_PROCESSO NUMBER, P_NOME VARCHAR2)
RETURN VARCHAR2
AS  
    P_VALOR VARCHAR(4000);
BEGIN
    BEGIN
        SELECT TWFIVAR.TEXTO INTO P_VALOR
        FROM TWFIVAR
        WHERE TWFIVAR.IDINSTPRN = P_INSTANCIA_PROCESSO
          AND TWFIVAR.NOME = P_NOME;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    
    RETURN P_VALOR;
END;
