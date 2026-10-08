/*==============================================================================
  Nome do Script : HR2DEC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Converte hora no formato HHMM em horas decimais (ex.: 830 ->
                  8,5).
  Assinatura     : HR2DEC (P_HORA IN NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'HR2DEC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION HR2DEC (P_HORA IN NUMBER)
RETURN NUMBER
IS
BEGIN
  RETURN NVL(FLOOR(P_HORA/100) + (MOD(P_HORA,100)/60),0);
END;
