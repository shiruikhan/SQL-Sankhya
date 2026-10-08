/*==============================================================================
  Nome do Script : GET_EXTRATO_POUPANCA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna (colecao T_EXTRATO_TABLE) o extrato de uma aplicacao
                  indexada por moeda/indice entre duas datas.
  Assinatura     : GET_EXTRATO_POUPANCA ( P_CODMOEDA NUMBER, P_VLRINI NUMBER
                  ,P_DATAINI DATE, P_DATAFIM DATE) RETURN T_EXTRATO_TABLE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_EXTRATO_POUPANCA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_EXTRATO_POUPANCA (
P_CODMOEDA NUMBER, P_VLRINI NUMBER ,P_DATAINI DATE, P_DATAFIM DATE)
RETURN T_EXTRATO_TABLE AS
  v_ret  T_EXTRATO_TABLE;
  P_VLRANT     FLOAT;
  P_VLRAPLICADO    FLOAT;   
  P_DTMOV        TSICOT.DTMOV %TYPE;
  P_COTACAO    TSICOT.COTACAO%TYPE;
    CURSOR COTACOES IS
        SELECT  DTMOV, COTACAO
    FROM TSICOT
    WHERE CODMOEDA = P_CODMOEDA AND DTMOV > P_DATAINI AND DTMOV <=P_DATAFIM
    AND  TO_CHAR(DTMOV,'DD') = CASE WHEN TO_CHAR(P_DATAINI,'DD') < 29 THEN TO_CHAR(P_DATAINI,'DD')ELSE '28'END
    ORDER BY DTMOV;
BEGIN
    v_ret  := T_EXTRATO_TABLE();
    P_VLRAPLICADO := P_VLRINI;
    OPEN COTACOES;
    LOOP
    FETCH COTACOES INTO P_DTMOV, P_COTACAO;
    EXIT WHEN COTACOES%NOTFOUND;
        v_ret.EXTEND;
        P_VLRANT := P_VLRAPLICADO;
        P_VLRAPLICADO := P_VLRAPLICADO + (P_VLRAPLICADO*P_COTACAO/100) ;
        v_ret(v_ret.COUNT) := T_EXTRATO(P_DTMOV, P_COTACAO,P_VLRANT, P_VLRAPLICADO);
    END LOOP;
    CLOSE COTACOES; 
    RETURN v_ret;
END;
