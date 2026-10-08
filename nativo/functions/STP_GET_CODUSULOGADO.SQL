/*==============================================================================
  Nome do Script : STP_GET_CODUSULOGADO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo do usuario logado na sessao
                  (TSIUSU_LOG_PKG.V_CODUSULOG).
  Assinatura     : STP_GET_CODUSULOGADO RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'STP_GET_CODUSULOGADO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION STP_GET_CODUSULOGADO 
RETURN NUMBER
AS
BEGIN
  RETURN(TSIUSU_LOG_PKG.V_CODUSULOG);
END;
