/*==============================================================================
  Nome do Script : HORAEXTRACARGAHORARIA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula os minutos de hora extra de um periodo em relacao a
                  carga horaria (inicio/fim), tratando antes/depois da
                  jornada.
  Assinatura     : HORAEXTRACARGAHORARIA (P_CARGAHORAINI IN INT, P_CARGAHORAFIM
                  IN INT, P_HORAINI IN INT, P_HORAFIM IN INT) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'HORAEXTRACARGAHORARIA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION HORAEXTRACARGAHORARIA (P_CARGAHORAINI IN INT, P_CARGAHORAFIM IN INT, P_HORAINI IN INT, P_HORAFIM IN INT)
RETURN NUMBER
IS
  CARGAHORINI INT; 
  CARGAHORFIM INT; 
  HORAINI      INT; 
  HORAFIM      INT;
  BOOINIHOR  BOOLEAN;  
  BOOFIMHOR  BOOLEAN;  
  BOOINIANT  BOOLEAN; 
  BOOINIAPOS BOOLEAN; 
  BOOFIMANT  BOOLEAN;
  BOOFIMAPOS BOOLEAN;
  TIMCALCULO INT;
BEGIN
  TIMCALCULO := 0;
  CARGAHORINI := FLOOR(P_CARGAHORAINI / 100) * 60 + MOD(P_CARGAHORAINI, 100); 
  CARGAHORFIM := FLOOR(P_CARGAHORAFIM / 100) * 60 + MOD(P_CARGAHORAFIM, 100); 
  HORAINI      := FLOOR(P_HORAINI / 100) * 60 + MOD(P_HORAINI, 100); 
  HORAFIM      := FLOOR(P_HORAFIM / 100) * 60 + MOD(P_HORAFIM, 100);
  BOOINIHOR := (HORAINI >= CARGAHORINI) AND (HORAINI <= CARGAHORFIM);
  BOOFIMHOR := (HORAFIM >= CARGAHORINI) AND (HORAFIM <= CARGAHORFIM);
  IF NOT(BOOINIHOR AND BOOFIMHOR) THEN
      BOOINIANT := (HORAINI < CARGAHORINI);
      BOOINIAPOS := (HORAINI > CARGAHORFIM);
      BOOFIMANT := (HORAFIM < CARGAHORINI);
      BOOFIMAPOS := (HORAFIM > CARGAHORFIM);
      IF BOOINIANT AND BOOFIMHOR THEN
        TIMCALCULO := CARGAHORINI - HORAINI;
      ELSIF (BOOINIANT AND BOOFIMANT) OR (BOOINIAPOS AND BOOFIMAPOS) THEN
        TIMCALCULO := HORAFIM - HORAINI;
      ELSIF BOOINIANT AND BOOFIMAPOS THEN
        TIMCALCULO := (CARGAHORINI - HORAINI) + (HORAFIM - CARGAHORFIM);
      ELSIF BOOINIHOR AND BOOFIMAPOS THEN
        TIMCALCULO := HORAFIM - CARGAHORFIM;
      END IF;
  END IF;
  IF TIMCALCULO > 14 THEN 
    RETURN( TIMCALCULO );
  ELSE 
    RETURN( 0 );
  END IF; 
END;
