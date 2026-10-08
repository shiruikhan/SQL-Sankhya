/*==============================================================================
  Nome do Script : HR2MIN
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Converte hora no formato HHMM em minutos.
  Assinatura     : HR2MIN (P_HORA IN NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'HR2MIN', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION HR2MIN (P_HORA IN NUMBER)
RETURN NUMBER
IS
BEGIN
  RETURN NVL(FLOOR(P_HORA/100) * 60 + MOD(P_HORA,100),0);
END;
