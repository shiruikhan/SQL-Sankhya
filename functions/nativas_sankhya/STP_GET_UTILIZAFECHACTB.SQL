/*==============================================================================
  Nome do Script : STP_GET_UTILIZAFECHACTB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Le a variavel TCBBFC_LOG_PKG.V_UTILIZA_FECHACTB (uso de
                  fechamento contabil).
  Assinatura     : STP_GET_UTILIZAFECHACTB RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'STP_GET_UTILIZAFECHACTB', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION STP_GET_UTILIZAFECHACTB 
RETURN BOOLEAN
IS 
BEGIN  
  RETURN TCBBFC_LOG_PKG.V_UTILIZA_FECHACTB;
END;
