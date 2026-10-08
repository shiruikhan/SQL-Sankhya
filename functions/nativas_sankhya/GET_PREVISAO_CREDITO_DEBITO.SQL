/*==============================================================================
  Nome do Script : GET_PREVISAO_CREDITO_DEBITO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula a data prevista de credito/debito de um titulo
                  (baixa, vencimento + carencia, proximo dia util).
  Assinatura     : GET_PREVISAO_CREDITO_DEBITO (P_DHBAIXA DATE, P_RECDESP INT,
                  P_PROVISAO CHAR, P_DTVENC DATE, P_CODPARCEIRO INT,
                  P_CARENCIA INT) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_PREVISAO_CREDITO_DEBITO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_PREVISAO_CREDITO_DEBITO (P_DHBAIXA DATE, P_RECDESP INT, P_PROVISAO CHAR, P_DTVENC DATE, P_CODPARCEIRO INT, P_CARENCIA INT) 
RETURN DATE AS
BEGIN 

    IF(P_DHBAIXA IS NOT NULL) THEN -- Se o financeiro ja foi baixado, retorna a data de baixa  
        RETURN P_DHBAIXA;
    ELSE
        IF(P_RECDESP = 1 AND P_PROVISAO = 'N') THEN -- Se for um titulo real, adiciona a carencia e pega o proximo dia útil

            IF(NVL(P_CARENCIA,0) = 0) THEN
                RETURN P_DTVENC;
            END IF;

            RETURN GET_PROXIMO_DIA_UTIL(P_DTVENC + NVL(P_CARENCIA,0), P_CODPARCEIRO, 0, 0);

        ELSE IF((P_RECDESP = 1 AND P_PROVISAO = 'S') OR P_RECDESP = -1) THEN

            RETURN P_DTVENC;

        END IF;
        END IF;

    END IF;

    RETURN P_DTVENC;

END;
