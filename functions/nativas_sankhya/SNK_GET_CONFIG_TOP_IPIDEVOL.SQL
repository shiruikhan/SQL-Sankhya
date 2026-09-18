/*==============================================================================
  Nome do Script : SNK_GET_CONFIG_TOP_IPIDEVOL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se a TOP de uma nota de entrada esta configurada para devolucao
                  de IPI sem destaque.
  Assinatura     : SNK_GET_CONFIG_TOP_IPIDEVOL (P_NUNOTA IN NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CONFIG_TOP_IPIDEVOL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CONFIG_TOP_IPIDEVOL (P_NUNOTA IN NUMBER)
RETURN NUMBER
IS
    V_COUNT_ITENS NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO V_COUNT_ITENS
    FROM TGFCAB CAB
    INNER JOIN TGFTOP TOP ON CAB.DHTIPOPER = TOP.DHALTER
    WHERE CAB.NUNOTA = P_NUNOTA
      AND CAB.TIPMOV = 'E'
      AND TOP.CALCICMS = 'B'
      AND NVL(TOP.TEMIPI, 'N') <> 'S'
      AND TOP.CSTIPISAI = -1
      AND NVL(TOP.DEVSEMDESTAQUEIPI, 'N') <> 'S';

    IF V_COUNT_ITENS > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END; 
