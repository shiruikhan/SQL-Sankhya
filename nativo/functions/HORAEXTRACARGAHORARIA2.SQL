/*==============================================================================
  Nome do Script : HORAEXTRACARGAHORARIA2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Versao simplificada de HORAEXTRACARGAHORARIA para calculo
                  dos minutos fora da carga horaria.
  Assinatura     : HORAEXTRACARGAHORARIA2 (P_CARGAHORAINI IN INT,
                  P_CARGAHORAFIM IN INT, P_HORAINI IN INT, P_HORAFIM IN INT)
                  RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'HORAEXTRACARGAHORARIA2', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION HORAEXTRACARGAHORARIA2 (P_CARGAHORAINI IN INT, P_CARGAHORAFIM IN INT, P_HORAINI IN INT, P_HORAFIM IN INT)
RETURN NUMBER
IS
  CARGAHORINI INT; 
  CARGAHORFIM INT; 
  HORAINI     INT; 
  HORAFIM     INT;
  TIMCALCULO  INT := 0;
BEGIN

/*
  A HORA DEVE SER EM NUMERO INTEIRO. EX.: 8:00 -> 800, 11:48 -> 1148, ETC. 
*/

  CARGAHORINI := FLOOR(P_CARGAHORAINI / 100) * 60 + MOD(P_CARGAHORAINI, 100); 
  CARGAHORFIM := FLOOR(P_CARGAHORAFIM / 100) * 60 + MOD(P_CARGAHORAFIM, 100); 
  HORAINI     := FLOOR(P_HORAINI / 100) * 60 + MOD(P_HORAINI, 100); 
  HORAFIM     := FLOOR(P_HORAFIM / 100) * 60 + MOD(P_HORAFIM, 100);

  IF HORAINI < CARGAHORINI THEN
    TIMCALCULO := CARGAHORINI - HORAINI;
  ELSE
    TIMCALCULO := (HORAINI - CARGAHORINI)*-1;
  END IF;

  IF HORAFIM > CARGAHORFIM THEN
    TIMCALCULO := TIMCALCULO + (HORAFIM - CARGAHORFIM);
  ELSE
    TIMCALCULO := TIMCALCULO + ((CARGAHORFIM - HORAFIM)*-1);
  END IF;

  RETURN( TIMCALCULO );

END;
