/*==============================================================================
  Nome do Script : INTERVALO_CARGA_HORARIA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o intervalo em minutos entre duas horas HHMM,
                  virando a meia-noite quando necessario.
  Assinatura     : INTERVALO_CARGA_HORARIA (HORAINI IN NUMBER, HORAFIM IN
                  NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'INTERVALO_CARGA_HORARIA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION INTERVALO_CARGA_HORARIA (HORAINI IN NUMBER, HORAFIM  IN NUMBER)
RETURN NUMBER
IS
    HINI NUMBER;
    HFIM NUMBER;
    INTERVALO NUMBER;
BEGIN

	HINI := HR2MIN(HORAINI);
	HFIM := HR2MIN(HORAFIM);

	IF HINI <= HFIM THEN
		INTERVALO := HFIM - HINI;
	ELSE
		INTERVALO := HR2MIN(2359) - HINI + HFIM;
    END IF;

	RETURN INTERVALO;
END;
