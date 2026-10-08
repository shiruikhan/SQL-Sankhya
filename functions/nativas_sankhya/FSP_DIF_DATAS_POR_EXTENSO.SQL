/*==============================================================================
  Nome do Script : FSP_DIF_DATAS_POR_EXTENSO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Diferenca entre duas datas em texto ('N dias e HH:MM:SS').
  Assinatura     : FSP_DIF_DATAS_POR_EXTENSO ( DATAFIM DATE,DATAINI DATE )
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FSP_DIF_DATAS_POR_EXTENSO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FSP_DIF_DATAS_POR_EXTENSO ( DATAFIM DATE,DATAINI DATE )
RETURN VARCHAR2
IS
ATRASO NUMBER;
BEGIN
  ATRASO := DATAFIM - DATAINI;
  IF ABS(ATRASO) >= 1 THEN 
  
    RETURN    EXTRACT (DAY FROM NUMTODSINTERVAL (ATRASO, 'DAY') )
           || ' dias e '
           || TRIM (TO_CHAR (EXTRACT (HOUR FROM NUMTODSINTERVAL (ATRASO, 'DAY') )
                           , '00') )
           || ':'
           || TRIM (TO_CHAR (EXTRACT (MINUTE FROM NUMTODSINTERVAL (ATRASO, 'DAY') )
                           , '00') )
           || ':'
           || TRIM
                (TO_CHAR (ROUND (EXTRACT (SECOND FROM NUMTODSINTERVAL (ATRASO
                                                                     , 'DAY') )
                               , 0)
                        , '00') )
           || ' horas';
  END IF;
  
  RETURN  TRIM (TO_CHAR (EXTRACT (HOUR FROM NUMTODSINTERVAL (ATRASO, 'DAY') )
                       , '00') )
       || ':'
       || TRIM (TO_CHAR (EXTRACT (MINUTE FROM NUMTODSINTERVAL (ATRASO, 'DAY') )
                       , '00') )
       || ':'
       || TRIM
            (TO_CHAR (ROUND (EXTRACT (SECOND FROM NUMTODSINTERVAL (ATRASO
                                                                 , 'DAY') )
                           , 0)
                    , '00') )
       || ' horas';
 END;
