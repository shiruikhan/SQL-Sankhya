/*==============================================================================
  Nome do Script : OBTEM_ALIQ_IPI
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub: retorna NULL (ponto de extensao para obter a aliquota
                  de IPI).
  Assinatura     : OBTEM_ALIQ_IPI (P_CODEMP IN NUMBER, P_CODPARC IN NUMBER,
                  P_CODPROD IN NUMBER, P_NUNOTA IN NUMBER, P_SEQUENCIA IN
                  NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OBTEM_ALIQ_IPI', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION OBTEM_ALIQ_IPI (P_CODEMP IN NUMBER, P_CODPARC IN NUMBER, P_CODPROD IN NUMBER, P_NUNOTA IN NUMBER, P_SEQUENCIA IN NUMBER)
RETURN NUMBER IS 
CODALIQ NUMBER;
BEGIN
    RETURN (CODALIQ);
END;
