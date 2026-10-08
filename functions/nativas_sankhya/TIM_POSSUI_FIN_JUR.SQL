/*==============================================================================
  Nome do Script : TIM_POSSUI_FIN_JUR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o contrato de locacao tem titulos vencidos em
                  juridico (TGFFIN).
  Assinatura     : TIM_POSSUI_FIN_JUR (P_CONTRATOLOC NUMBER, P_NUFIN NUMBER
                  DEFAULT NULL ) RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_POSSUI_FIN_JUR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_POSSUI_FIN_JUR (P_CONTRATOLOC NUMBER, P_NUFIN NUMBER DEFAULT NULL )
   RETURN BOOLEAN
IS
   P_COUNT   NUMBER;
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   SELECT COUNT (1)
     INTO P_COUNT
     FROM TGFFIN
    WHERE     NUFIN <> P_NUFIN
          AND TIMCONTRATOLOC = P_CONTRATOLOC
          AND DHBAIXA IS NULL
          AND TIMDATADEJUR IS NOT NULL
          AND DTVENC < SYSDATE
          AND RECDESP = 1;
    
   COMMIT;
   RETURN P_COUNT > 0;
END;
