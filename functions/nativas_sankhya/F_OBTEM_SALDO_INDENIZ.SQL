/*==============================================================================
  Nome do Script : F_OBTEM_SALDO_INDENIZ
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o saldo de indenizacao de um parceiro na data (saldo
                  inicial + movimentos das notas).
  Assinatura     : F_OBTEM_SALDO_INDENIZ ( P_CODPARC IN NUMBER, P_DATA IN DATE)
                  RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_OBTEM_SALDO_INDENIZ', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_OBTEM_SALDO_INDENIZ (
  P_CODPARC IN NUMBER,
  P_DATA IN DATE)
RETURN FLOAT
IS  P_SALDO   TGFPAR.SALDOINDENIZ%TYPE;
    P_MOV     FLOAT;
BEGIN
   SELECT NVL(SALDOINDENIZ,0) 
   INTO P_SALDO
   FROM TGFPAR 
   WHERE CODPARC = P_CODPARC;

   SELECT SUM(CAB.VLRINDENIZ * TPO.ATUALINDENIZ)
   INTO P_MOV
   FROM TGFCAB CAB
   , TGFTOP TPO
   WHERE CAB.CODPARC = P_CODPARC
   AND CAB.CODTIPOPER = TPO.CODTIPOPER
   AND CAB.DHTIPOPER = TPO.DHALTER
   AND CAB.DTNEG >= P_DATA
   AND TPO.ATUALINDENIZ <> 0; 

   RETURN(P_SALDO - P_MOV);
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN (0);
END;
