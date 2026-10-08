/*==============================================================================
  Nome do Script : FORMATAR_CPF_CNPJ
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Aplica mascara de CPF ou CNPJ conforme o tamanho do
                  documento.
  Assinatura     : FORMATAR_CPF_CNPJ (Valor VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FORMATAR_CPF_CNPJ', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FORMATAR_CPF_CNPJ (Valor VARCHAR2)
   RETURN VARCHAR2
IS
   Result   VARCHAR2 (20);
BEGIN
   IF LENGTH (Valor) > 11
   THEN
      result :=
            SUBSTR (Valor, 1, 2)
         || '.'
         || SUBSTR (Valor, 3, 3)
         || '.'
         || SUBSTR (Valor, 6, 3)
         || '/'
         || SUBSTR (Valor, 9, 4)
         || '-'
         || SUBSTR (Valor, 13, 2);
   ELSE
      result :=
            SUBSTR (Valor, 1, 3)
         || '.'
         || SUBSTR (Valor, 4, 3)
         || '.'
         || SUBSTR (Valor, 7, 3)
         || '-'
         || SUBSTR (Valor, 10, 2);
   END IF;

   RETURN (Result);
END;
