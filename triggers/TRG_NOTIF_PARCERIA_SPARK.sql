CREATE OR REPLACE TRIGGER TRG_NOTIF_PARCERIA_SPARK
AFTER INSERT OR UPDATE ON AD_TGSTPP
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_NOTIF_PARCERIA_SPARK
  Tipo           : Trigger
  Descrição      : Dispara notificações por e-mail no fluxo de triagem de
                   parceria (influenciadores/patrocínio):
                   1) Chegada de nova solicitação -> avisa o SAC.
                   2) SAC finaliza a varredura (1º preenchimento de
                      PARECER_RECOMENDACAO) -> avisa o Comercial.
                   3) Comercial registra a decisão (1º preenchimento de
                      DECISAO_COMERCIAL) -> avisa o SAC do resultado.
  Tabela         : AD_TGSTPP
  Evento         : AFTER INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSTPP -- solicitações de triagem de parceria (leitura via :NEW/:OLD)
                   TMDFMG    -- fila de e-mails (escrita via STP_GRAVA_FILA_BI2)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : STP_GRAVA_FILA_BI2

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 13/08/2026
  Última Revisão : Agosto/2026 — Criação

  Observações    : - AD_TGSTPP não possui coluna de status única; cada etapa é
                     identificada pelo preenchimento do respectivo bloco de
                     campos (parecer do SAC / decisão comercial).
                   - Campos CLOB grandes (resumo da proposta, parecer, decisão)
                     são truncados com DBMS_LOB.SUBSTR ao montar o corpo do
                     e-mail, para evitar estouro de buffer VARCHAR2.
                   - Destinatários fixos: sac@spark.ind.br e comercial@spark.ind.br.
                   - Nome do objeto limitado a 30 caracteres (limite do gatilho
                     de auditoria de DDL do ambiente).
==============================================================================*/
DECLARE
    V_TITULO       VARCHAR2(300);
    V_CONTEUDO     VARCHAR2(8000);
    V_CODFILA      NUMBER;
    V_OPERACAO     VARCHAR2(10);

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(P_OPERACAO VARCHAR2, P_ERR_CODE NUMBER, P_ERR_MSG VARCHAR2, P_ERR_BACKTRACE VARCHAR2, P_CALL_STACK VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (IDLOG, TRIGGER_NAME, OPERACAO, ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK)
        VALUES (V_IDLOG, 'TRG_NOTIF_PARCERIA_SPARK', P_OPERACAO, P_ERR_CODE,
                'Protocolo ' || :NEW.PROTOCOLO || ' - ' || P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END LOG_ERRO;
BEGIN
    ---------------------------------------------------------------------------
    -- 1. Chegada de nova solicitação de triagem -> notifica o SAC
    ---------------------------------------------------------------------------
    IF INSERTING THEN
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        V_TITULO := 'Nova Solicitação de Parceria - Protocolo ' || :NEW.PROTOCOLO;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Protocolo:</strong> ' || :NEW.PROTOCOLO || '</p>
            <p><strong>Proponente:</strong> ' || :NEW.NOME_PROPONENTE || '</p>
            <p><strong>Empresa/Projeto:</strong> ' || :NEW.EMPRESA_PROJETO || '</p>
            <p><strong>Cidade/UF:</strong> ' || :NEW.CIDADE_ESTADO || '</p>
            <p><strong>Telefone:</strong> ' || :NEW.TELEFONE || '</p>
            <p><strong>E-mail:</strong> ' || :NEW.EMAIL || '</p>
            <p><strong>Nicho de Conteúdo:</strong> ' || :NEW.NICHO_CONTEUDO || '</p>
            <p><strong>Redes Sociais:</strong><br/>
               Instagram: ' || NVL(:NEW.PERFIL_INSTAGRAM, '-') || ' (' || NVL(TO_CHAR(:NEW.SEGUIDORES_INSTAGRAM), '0') || ' seguidores)<br/>
               TikTok: '    || NVL(:NEW.PERFIL_TIKTOK, '-')    || ' (' || NVL(TO_CHAR(:NEW.SEGUIDORES_TIKTOK), '0')    || ' seguidores)<br/>
               YouTube: '   || NVL(:NEW.PERFIL_YOUTUBE, '-')   || ' (' || NVL(TO_CHAR(:NEW.SEGUIDORES_YOUTUBE), '0')   || ' seguidores)<br/>
               Facebook: '  || NVL(:NEW.PERFIL_FACEBOOK, '-')  || ' (' || NVL(TO_CHAR(:NEW.SEGUIDORES_FACEBOOK), '0')  || ' seguidores)
            </p>
            <p><strong>Solicita:</strong>
               Produtos: '             || NVL(:NEW.SOLICITA_PRODUTOS, 'N')              || ' |
               Patrocínio Financeiro: '|| NVL(:NEW.SOLICITA_PATROCINIO_FINANCEIRO, 'N')  || ' |
               Apoio Institucional: '  || NVL(:NEW.SOLICITA_APOIO_INSTITUCIONAL, 'N')    || ' |
               Divulgação: '           || NVL(:NEW.SOLICITA_DIVULGACAO, 'N')             || ' |
               Beneficente: '          || NVL(:NEW.SOLICITA_BENEFICENTE, 'N') || '
            </p>
            <p><strong>Resumo da Proposta:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.RESUMO_PROPOSTA, 1500, 1) || '</p>
            <p><strong>Data de Envio:</strong> ' || TO_CHAR(:NEW.DATA_ENVIO, 'DD/MM/YYYY HH24:MI') || '</p>
            <p>Uma nova solicitação de parceria aguarda a triagem do SAC.</p>
            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';

        STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'sac@spark.ind.br', NULL);
    END IF;

    ---------------------------------------------------------------------------
    -- 2. SAC finaliza a varredura (1º preenchimento de PARECER_RECOMENDACAO)
    --    -> notifica o Comercial
    ---------------------------------------------------------------------------
    IF UPDATING AND :OLD.PARECER_RECOMENDACAO IS NULL AND :NEW.PARECER_RECOMENDACAO IS NOT NULL THEN
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        V_TITULO := 'Triagem SAC Concluída - Protocolo ' || :NEW.PROTOCOLO;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Protocolo:</strong> ' || :NEW.PROTOCOLO || '</p>
            <p><strong>Proponente:</strong> ' || :NEW.NOME_PROPONENTE || '</p>
            <p><strong>Empresa/Projeto:</strong> ' || :NEW.EMPRESA_PROJETO || '</p>
            <p><strong>Responsável SAC:</strong> ' || :NEW.RESPONSAVEL_SAC || '</p>
            <p><strong>Checklist SAC:</strong>
               Alcance de Redes Sociais: ' || NVL(:NEW.ALCANCE_REDES_SOCIAIS, 'N') || ' |
               Público Compatível: '       || NVL(:NEW.PUBLICO_COMPATIVEL, 'N')    || ' |
               Relação com Segmento: '     || NVL(:NEW.RELACAO_SEGMENTO, 'N')      || ' |
               Proposta Profissional: '    || NVL(:NEW.PROPOSTA_PROFISSIONAL, 'N') || '
            </p>
            <p><strong>Pontos Positivos:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.PARECER_PONTOS_POSITIVOS, 1000, 1) || '</p>
            <p><strong>Pontos de Atenção:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.PARECER_PONTOS_ATENCAO, 1000, 1) || '</p>
            <p><strong>Recomendação do SAC:</strong> ' || :NEW.PARECER_RECOMENDACAO || '</p>
            <p>O SAC concluiu a varredura do pretenso parceiro. Aguarda decisão comercial.</p>
            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';

        STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'comercial@spark.ind.br', NULL);
    END IF;

    ---------------------------------------------------------------------------
    -- 3. Comercial registra a decisão (1º preenchimento de DECISAO_COMERCIAL)
    --    -> notifica o SAC
    ---------------------------------------------------------------------------
    IF UPDATING AND :OLD.DECISAO_COMERCIAL IS NULL AND :NEW.DECISAO_COMERCIAL IS NOT NULL THEN
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        V_TITULO := 'Decisão Comercial Registrada - Protocolo ' || :NEW.PROTOCOLO;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Protocolo:</strong> ' || :NEW.PROTOCOLO || '</p>
            <p><strong>Proponente:</strong> ' || :NEW.NOME_PROPONENTE || '</p>
            <p><strong>Empresa/Projeto:</strong> ' || :NEW.EMPRESA_PROJETO || '</p>
            <p><strong>Decisão Comercial:</strong> ' || :NEW.DECISAO_COMERCIAL || '</p>
            <p><strong>Responsável pela Decisão:</strong> ' || :NEW.DECISAO_RESPONSAVEL || '</p>
            <p><strong>Data da Decisão:</strong> ' || TO_CHAR(:NEW.DECISAO_DATA, 'DD/MM/YYYY HH24:MI') || '</p>
            <p><strong>Observações:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.DECISAO_OBSERVACOES, 1500, 1) || '</p>
            <p>A decisão comercial foi registrada para esta solicitação de parceria.</p>
            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';

        STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'sac@spark.ind.br', NULL);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF INSERTING THEN
            V_OPERACAO := 'INSERT';
        ELSIF UPDATING THEN
            V_OPERACAO := 'UPDATE';
        ELSE
            V_OPERACAO := NULL;
        END IF;
        LOG_ERRO(V_OPERACAO, SQLCODE, SQLERRM, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20098, 'Erro na trigger TRG_NOTIF_PARCERIA_SPARK: ' || SQLERRM);
END TRG_NOTIF_PARCERIA_SPARK;
