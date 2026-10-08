/*==============================================================================
  Nome do Script : TIM_COMPOEVALORCFI
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub: retorna 100 (ponto de extensao do modulo imobiliario).
  Assinatura     : TIM_COMPOEVALORCFI (P_CFIDESCRICAO IN VARCHAR2) RETURN
                  NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_COMPOEVALORCFI', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_COMPOEVALORCFI (P_CFIDESCRICAO IN VARCHAR2) RETURN NUMBER IS
 BEGIN
 RETURN 100;
END;
