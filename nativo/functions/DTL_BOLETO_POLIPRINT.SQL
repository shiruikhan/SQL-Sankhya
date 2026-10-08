/*==============================================================================
  Nome do Script : DTL_BOLETO_POLIPRINT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta a instrucao de multa, mora e correcao monetaria
                  impressa no boleto Poliprint.
  Assinatura     : DTL_BOLETO_POLIPRINT (VLRDESDOB NUMBER, TIMCONTRATOLOC
                  NUMBER, DTVENC DATE) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'DTL_BOLETO_POLIPRINT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION DTL_BOLETO_POLIPRINT (VLRDESDOB NUMBER, TIMCONTRATOLOC NUMBER, DTVENC DATE)
  RETURN VARCHAR2
  IS
    TEXTO CLOB;
    COTACAO NUMBER;
    DATAMOV DATE;
  BEGIN
    TEXTO := 'Após vencimento, multa de R$ ';
    TEXTO := TEXTO||TRIM(TO_CHAR(VLRDESDOB * 0.1, '999990,00'));
    TEXTO := TEXTO||' (10%), mora diária de R$ ';
    TEXTO := TEXTO||TRIM(TO_CHAR(VLRDESDOB * 0.01 / 30, '9999990,00'));
    TEXTO := TEXTO||' (1% a.m.) e C.M. de R$ ';
    SELECT COT.COTACAO, 
           COT.DTMOV INTO   COTACAO, 
                            DATAMOV
    FROM TSICOT COT 
    WHERE COT.CODMOEDA = (SELECT LOCINDEXADOR 
                          FROM TIMLOC 
                          WHERE LOCCODIGO = TIMCONTRATOLOC) 
          AND COT.DTMOV = (SELECT MAX(COT2.DTMOV) 
                           FROM TSICOT COT2 
                           WHERE COT2.CODMOEDA = COT.CODMOEDA 
                                 AND COT2.DTMOV <= TRUNC(DTVENC));
    TEXTO := TEXTO||TRIM(TO_CHAR((VLRDESDOB * (NVL(COTACAO, 0))) / 100, '99990,00'));
    TEXTO := TEXTO||' (IGPM  ';            
    TEXTO := TEXTO||MONTH_TO_CHAR(EXTRACT(MONTH FROM DATAMOV), 1);
    TEXTO := TEXTO||' '||TRIM(TO_CHAR(COTACAO, '90,00'));                                
    TEXTO := TEXTO||'% a.m.) ';
    TEXTO := FRMT_LINHA_BOLETO(TEXTO, 60, 0, 3);
    RETURN TEXTO;
  END;
