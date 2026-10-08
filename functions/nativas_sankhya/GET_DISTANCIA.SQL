/*==============================================================================
  Nome do Script : GET_DISTANCIA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula a distancia entre dois pontos por latitude/longitude
                  (formula de haversine).
  Assinatura     : GET_DISTANCIA (LAINI FLOAT, LOINI FLOAT, LAFIN FLOAT, LOFIN
                  FLOAT) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_DISTANCIA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_DISTANCIA (LAINI FLOAT, LOINI FLOAT, LAFIN FLOAT, LOFIN FLOAT)
RETURN FLOAT
IS
    D2R FLOAT;
    DLONG FLOAT;
    DLAT FLOAT;
    TEMP_SIN FLOAT;
    TEMP_COS FLOAT;
    TEMP_SIN2 FLOAT;
    A FLOAT;
    C FLOAT;
BEGIN
    D2R := 0.017453292519943295769236;

    DLONG := (LOFIN - LOINI) * D2R;
    DLAT := (LAFIN - LAINI) * D2R;

    TEMP_SIN := SIN(DLAT/2.0);
    TEMP_COS := COS(LAINI * D2R);
    TEMP_SIN2 := SIN(DLONG/2.0);

    A := (TEMP_SIN * TEMP_SIN) + (TEMP_COS * TEMP_COS) * (TEMP_SIN2 * TEMP_SIN2);
    C := 2.0 * ATAN2(SQRT(A), SQRT(1.0 - A));

    RETURN 6368.1 * C;
END;
