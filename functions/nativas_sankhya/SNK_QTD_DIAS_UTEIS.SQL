/*==============================================================================
  Nome do Script : SNK_QTD_DIAS_UTEIS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Conta a quantidade de dias uteis entre duas datas para uma empresa, usando
                  EH_DIA_UTIL_EMP_GIRO.
  Assinatura     : SNK_QTD_DIAS_UTEIS (P_DATAINI DATE, P_DATAFIM DATE,P_CODEMP NUMBER )
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_QTD_DIAS_UTEIS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_QTD_DIAS_UTEIS (P_DATAINI DATE, P_DATAFIM DATE,P_CODEMP NUMBER ) RETURN INT
IS   
    P_DATATEMP   DATE;
    P_COUNT      NUMBER;
BEGIN
    P_COUNT :=0;
    P_DATATEMP := P_DATAINI;
    WHILE P_DATATEMP <= P_DATAFIM LOOP
        IF EH_DIA_UTIL_EMP_GIRO(P_DATATEMP, P_CODEMP) = 1 THEN
            P_COUNT := P_COUNT + 1;
        END IF;
        P_DATATEMP := P_DATATEMP+1;
    END LOOP;
RETURN P_COUNT;
END;
