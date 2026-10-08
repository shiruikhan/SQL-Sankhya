/*==============================================================================
  Nome do Script : GET_VALEST_BLOQWMS_FAT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Le a variavel de sessao VARIAVEIS_PKG.V_VALEST_BLOQWMS_FAT.
  Assinatura     : GET_VALEST_BLOQWMS_FAT RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_VALEST_BLOQWMS_FAT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_VALEST_BLOQWMS_FAT RETURN VARCHAR2 AS 
BEGIN     
   RETURN VARIAVEIS_PKG.V_VALEST_BLOQWMS_FAT;
END;
