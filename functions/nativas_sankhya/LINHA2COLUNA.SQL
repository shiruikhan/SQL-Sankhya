/*==============================================================================
  Nome do Script : LINHA2COLUNA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Executa um SELECT dinamico de coluna unica e devolve os
                  valores concatenados e separados por virgula (limite de 4000
                  caracteres).
  Assinatura     : LINHA2COLUNA (P_SELECT IN VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'LINHA2COLUNA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION LINHA2COLUNA (P_SELECT IN VARCHAR2) RETURN VARCHAR2 IS  
  Saida VARCHAR2(4000);
  P_LINHA VARCHAR2(250);
  type DinCursor is REF CURSOR;
  ORIGEM DinCursor;
BEGIN
    OPEN ORIGEM FOR P_SELECT;
        LOOP
            FETCH ORIGEM INTO P_LINHA;
            EXIT WHEN ORIGEM%NOTFOUND;
            IF LENGTH(SAIDA || ', ' || P_LINHA) > 4000 THEN
              EXIT;
            END IF;
            IF P_LINHA IS NOT NULL THEN
              IF SAIDA IS NULL THEN
                SAIDA := P_LINHA;
              ELSE
                SAIDA := SAIDA || ', ' || P_LINHA;
              END IF;
            END IF;
        END LOOP;
    CLOSE ORIGEM;
   
    RETURN TRIM(Saida);
END;
