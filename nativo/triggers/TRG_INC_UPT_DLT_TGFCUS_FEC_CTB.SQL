/*==============================================================================
  Nome do Script : TRG_INC_UPT_DLT_TGFCUS_FEC_CTB
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE OR DELETE sobre TGFCUS.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_INC_UPT_DLT_TGFCUS_FEC_CTB', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_DLT_TGFCUS_FEC_CTB" 
BEFORE INSERT OR UPDATE OR DELETE ON TGFCUS
FOR EACH ROW 
DECLARE 
  ERRMSG                 VARCHAR2(4000); 
  ERROR                  EXCEPTION; 
  P_TIPO_ITEM          CHAR(1); 
  P_DATA                  DATE; 
  P_CODEMP              NUMBER; 
  P_TIPOACAO             CHAR(1); 
  P_NUCHAVE              NUMBER; 
  P_CODTIPOPER         NUMBER; 
  P_DHTIPOPER         DATE; 
  P_NOTA_LIBERADA   CHAR(1); 
  P_VERIFICAR_BLOQ  BOOLEAN; 
  P_IS_CALC_CUSTO CHAR(1); 
  P_TEM_CUSTO_EMP NUMBER;
  P_COUNT           NUMBER;

  P_MOVIMENTACAO_CUSTO_NOTA     CHAR(2) := '02';
  P_MOVIMENTACAO_CUSTO_PRODUTO  CHAR(2) := '03'; 
  P_MOVIMENTACAO_CUSTO_SERVICO  CHAR(2) := '10'; 
  
  P_ROTINA_RECALCULO_CUSTO                CHAR(1) := '9';

  P_TIPO_ACAO_INCLUSAO             CHAR(1) := 'I'; 
  P_TIPO_ACAO_ALTERACAO         CHAR(1) := 'A'; 
  P_TIPO_ACAO_DELECAO             CHAR(1) := 'D'; 
  P_TIPO_ACAO_ROTINA            CHAR(1) := 'R';
  P_ROTINACTB                   CHAR(1);
  P_TIPO_ACAO_MSG                VARCHAR(40);
BEGIN 

	IF NOT STP_GET_UTILIZAFECHACTB() THEN
      RETURN;
	END IF;

  IF DELETING THEN 
      P_TIPOACAO := P_TIPO_ACAO_DELECAO;
      P_CODEMP := :OLD.CODEMP;
      P_NUCHAVE := :OLD.NUNOTA;
      P_DATA := :OLD.DTATUAL;
      P_TIPO_ACAO_MSG := '(Deleção)';
  ELSE
      P_TIPOACAO := P_TIPO_ACAO_INCLUSAO;
      P_CODEMP := :NEW.CODEMP;
      P_NUCHAVE := :NEW.NUNOTA;
      P_DATA := :NEW.DTATUAL;
      P_TIPO_ACAO_MSG := '(Inserção)';
  END IF;

  SELECT COUNT(1) INTO P_TEM_CUSTO_EMP
  FROM TSIPAR 
  WHERE CHAVE = 'CUSTOPOREMP'
  AND LOGICO = 'S';
  
  IF TCBBFC_LOG_PKG.V_ROTINACTB IS NOT NULL  AND (TCBBFC_LOG_PKG.V_ROTINACTB = P_ROTINA_RECALCULO_CUSTO)THEN 
      P_ROTINACTB := TCBBFC_LOG_PKG.V_ROTINACTB;
      P_TIPOACAO := P_TIPO_ACAO_ROTINA;
      P_TIPO_ACAO_MSG := '(Rotina de Geração)';
    END IF;

--- Quando esse parâmetro estiver ligado CUSTOPOREMP consideramos o custo por empresa e analisamos se terá 
-- bloqueio ou não, quando estiver desligado iremos bloquear sempre 
-- pois, ao tentar alterar o custo não sabemos qual empresa estará realizando.

  IF P_TEM_CUSTO_EMP > 0 THEN 
    IF UPDATING THEN
        IF (:OLD.CODPROD <> :NEW.CODPROD
          OR :OLD.CODEMP <> :NEW.CODEMP
          OR :OLD.DTATUAL <> :NEW.DTATUAL
          OR :OLD.CODLOCAL <> :NEW.CODLOCAL
          OR :OLD.CONTROLE <> :NEW.CONTROLE
          OR :OLD.CUSMEDICM <> :NEW.CUSMEDICM
          OR :OLD.CUSSEMICM <> :NEW.CUSSEMICM
          OR :OLD.CUSREP <> :NEW.CUSREP
          OR :OLD.CUSVARIAVEL <> :NEW.CUSVARIAVEL
          OR :OLD.CUSGER <> :NEW.CUSGER
          OR :OLD.CUSMED <> :NEW.CUSMED
          OR NVL(:OLD.VLRVENDAFIXO, 0) <> NVL(:NEW.VLRVENDAFIXO, 0)
          OR NVL(:OLD.ENTRADACOMICMS, 0) <> NVL(:NEW.ENTRADACOMICMS, 0)
          OR NVL(:OLD.ENTRADASEMICMS, 0) <> NVL(:NEW.ENTRADASEMICMS, 0)
          OR NVL(:OLD.QTDNEG, 0) <> NVL(:NEW.QTDNEG, 0)
          OR :OLD.AUTOMATICO <> :NEW.AUTOMATICO
          OR NVL(:OLD.ALTPRECO, ' ') <> NVL(:NEW.ALTPRECO, ' ')
          OR :OLD.NUNOTA <> :NEW.NUNOTA
          OR :OLD.SEQUENCIA <> :NEW.SEQUENCIA
          OR NVL(:OLD.TOTALCOMICMS, 0) <> NVL(:NEW.TOTALCOMICMS, 0)
          OR NVL(:OLD.TOTALSEMICMS, 0) <> NVL(:NEW.TOTALSEMICMS, 0)
          OR NVL(:OLD.TOTALCOMICMSANT, 0) <> NVL(:NEW.TOTALCOMICMSANT, 0)
          OR NVL(:OLD.TOTALSEMICMSANT, 0) <> NVL(:NEW.TOTALSEMICMSANT, 0)
          OR :OLD.CUSMEDCALC <> :NEW.CUSMEDCALC
          OR :OLD.RECARGA <> :NEW.RECARGA
          OR NVL(:OLD.QTDNEGGER, 0) <> NVL(:NEW.QTDNEGGER, 0)
          OR NVL(:OLD.TIPO, ' ') <> NVL(:NEW.TIPO, ' ')
          OR NVL(:OLD.PROCESSO, ' ') <> NVL(:NEW.PROCESSO, ' ') ) THEN

            IF P_TIPO_ACAO_ROTINA <> P_TIPOACAO THEN 
                P_TIPOACAO := P_TIPO_ACAO_ALTERACAO;
            END IF;
            
            IF TCBBFC_LOG_PKG.V_ROTINACTB IS NOT NULL  AND (TCBBFC_LOG_PKG.V_ROTINACTB = P_ROTINA_RECALCULO_CUSTO) THEN 
                P_TIPO_ACAO_MSG := '(Rotina de Geração)';
            ELSE
                P_TIPO_ACAO_MSG := '(Alteração)';
            END IF;

            IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_NOTA, P_ROTINACTB, NULL, P_NUCHAVE) THEN
                P_NUCHAVE := :NEW.CODPROD;

                SELECT COUNT(1) INTO P_COUNT
                FROM TGFPRO
                WHERE CODPROD = P_NUCHAVE
                   AND NVL(USOPROD, '*') <> 'S';

                IF P_COUNT > 0 THEN 
                    IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_PRODUTO, P_ROTINACTB, NULL, P_NUCHAVE) THEN
                        RAISE ERROR;
                    END IF;
                ELSE
                    IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_SERVICO, P_ROTINACTB, NULL, P_NUCHAVE) THEN
                        RAISE ERROR;  
                    END IF;
                END IF;
            END IF;
        END IF;
    ELSE 
      IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_NOTA, P_ROTINACTB, NULL, P_NUCHAVE) THEN
            IF DELETING THEN
                P_NUCHAVE := :OLD.CODPROD;
            ELSE
                P_NUCHAVE := :NEW.CODPROD;

                IF TCBBFC_LOG_PKG.V_ROTINACTB IS NOT NULL  AND (TCBBFC_LOG_PKG.V_ROTINACTB = P_ROTINA_RECALCULO_CUSTO) THEN 
                    P_TIPO_ACAO_MSG := '(Rotina de Geração)';
                ELSE
                    P_TIPO_ACAO_MSG := '(Inclusão/Alteração)';
                END IF;
            END IF;

            SELECT COUNT(1) INTO P_COUNT
            FROM TGFPRO
            WHERE CODPROD = P_NUCHAVE
               AND NVL(USOPROD, '*') <> 'S';

            IF P_COUNT > 0 THEN
                IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_PRODUTO, P_ROTINACTB, NULL, P_NUCHAVE) THEN
                    RAISE ERROR;  
                END IF;
            ELSE 
                IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_SERVICO, P_ROTINACTB, NULL, P_NUCHAVE) THEN
                    RAISE ERROR;
                END IF;
            END IF;
        END IF;
    END IF;
  ELSE
    ERRMSG := ERRMSG || 'Não existe calculo de custo por empresa. Parâmetro ''CUSTOPOREMP'' está desligado. ';
    P_TIPO_ACAO_MSG := '(Inclusão/Alteração/Deleção)';

      IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, NULL, P_MOVIMENTACAO_CUSTO_PRODUTO, NULL, NULL, NULL) THEN
        RAISE ERROR; 
      END IF;
  END IF;
RETURN;

EXCEPTION WHEN ERROR THEN
  ERRMSG := SNK_FORMAT_MSG_BLOQ_FEC_CTB(ERRMSG || 'O mês ' || TO_CHAR(P_DATA,'MM/YYYY')  || ' está fechado. Não é possível realizar movimentação referente ao custo ' || CAST(NVL(P_NUCHAVE, '') AS VARCHAR) || ' em períodos fechados pela contabilidade sem uma liberação de ' || P_TIPO_ACAO_MSG || ' para empresa ' || CAST(NVL(P_CODEMP, '') AS VARCHAR) || '.');

  RAISE_APPLICATION_ERROR(-20101, ERRMSG);
  RETURN;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_DLT_TGFCUS_FEC_CTB" ENABLE;
