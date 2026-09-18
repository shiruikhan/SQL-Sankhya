/*==============================================================================
  Nome do Script : SNK_GET_VLRLIQUIDO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o valor liquido unitario de um item de nota, com regra especial
                  quando a tabela de preco e do tipo 9 (soma ST e IPI).
  Assinatura     : SNK_GET_VLRLIQUIDO (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_VLRLIQUIDO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_VLRLIQUIDO (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER) 
RETURN FLOAT IS V_RESULT FLOAT;

BEGIN BEGIN
SELECT (CASE
            WHEN ITE.QTDNEG = 0 THEN 0
            ELSE (CASE
                      WHEN CAB.TIPMOV IN('O',
                                         'C',
                                         'E') THEN ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED
                      ELSE (CASE
                                WHEN NVL(
                                           (SELECT INTEIRO
                                            FROM TSIPAR
                                            WHERE CHAVE = 'TIPTABPRECO'), 0) <> 9 THEN ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED
                                ELSE (ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED) + ITE.VLRSUBST + ((CASE
                                                                                                       WHEN ITE.VLRIPI > 0
                                                                                                            AND NVL(
                                                                                                                      (SELECT SOMARIPI
                                                                                                                       FROM TGFTOP TP
                                                                                                                       WHERE TP.CODTIPOPER = CAB.CODTIPOPER
                                                                                                                         AND TP.DHALTER = CAB.DHTIPOPER), 'N') <> 'N' THEN ITE.VLRIPI
                                                                                                       ELSE 0
                                                                                                   END))
                            END)
                  END) / ITE.QTDNEG
        END) INTO V_RESULT
FROM TGFCAB CAB
INNER JOIN TGFITE ITE ON CAB.NUNOTA = ITE.NUNOTA
WHERE CAB.NUNOTA = P_NUNOTA
  AND ITE.SEQUENCIA = P_SEQUENCIA;

END;

RETURN V_RESULT;

END;
