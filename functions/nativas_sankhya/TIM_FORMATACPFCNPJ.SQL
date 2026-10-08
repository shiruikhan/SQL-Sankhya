/*==============================================================================
  Nome do Script : TIM_FORMATACPFCNPJ
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Aplica mascara de CPF ou CNPJ conforme o tipo de pessoa
                  (F/J).
  Assinatura     : TIM_FORMATACPFCNPJ (Documento IN VARCHAR2, Tipo IN CHAR)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_FORMATACPFCNPJ', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_FORMATACPFCNPJ (Documento IN VARCHAR2, Tipo IN CHAR) RETURN VARCHAR2 IS
 --Autor: Bosco
 Rsp VARCHAR2(20);
 
 
 BEGIN
 
 IF Tipo = 'F' THEN
   Rsp := SUBSTR(Documento, 1, 3) || '.' || SUBSTR(Documento, 4, 3)  || '.' || SUBSTR(Documento, 7, 3) || '-' || SUBSTR(Documento, 10, 2);
 ELSE
   Rsp := SUBSTR(Documento, 1, 2) || '.' || SUBSTR(Documento, 3, 3) || '.' || SUBSTR(Documento, 6, 3) || '/' || SUBSTR(Documento, 9, 4) || '-' || SUBSTR(Documento, 13, 2);
 END IF;

 RETURN Rsp;

END;
