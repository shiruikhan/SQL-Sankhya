/*==============================================================================
  Nome do Script : DEC2HR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Converte horas decimais em hora no formato HHMM (ex.: 8,5 ->
                  830).
  Assinatura     : DEC2HR (P_DEC IN NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'DEC2HR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION DEC2HR (P_DEC IN NUMBER)
RETURN NUMBER
IS
FLOOR_OF_DEC   INT;
BEGIN
  FLOOR_OF_DEC := FLOOR(P_DEC); 

  RETURN (FLOOR_OF_DEC * 100) + ((P_DEC - FLOOR_OF_DEC) * 60);
END;
