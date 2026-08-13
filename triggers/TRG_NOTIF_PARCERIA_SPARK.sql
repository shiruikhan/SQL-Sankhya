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
                   Campos de múltipla escolha são traduzidos do código bruto
                   para o texto da opção via TDDCAM/TDDOPC.
  Tabela         : AD_TGSTPP
  Evento         : AFTER INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSTPP -- solicitações de triagem de parceria (leitura via :NEW/:OLD)
                   TDDOPC    -- opções de campos multi-escolha (leitura, tradução código->texto)
                   TMDFMG    -- fila de e-mails (escrita via STP_GRAVA_FILA_BI2)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : STP_GRAVA_FILA_BI2

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 13/08/2026
  Última Revisão : Agosto/2026 — Criação
                   Agosto/2026 — Tradução dos campos multi-escolha via
                   TDDCAM/TDDOPC (função GET_OPCAO) e inclusão de OBSINTERNA
                   no e-mail de decisão comercial.

  Observações    : - AD_TGSTPP não possui coluna de status única; cada etapa é
                     identificada pelo preenchimento do respectivo bloco de
                     campos (parecer do SAC / decisão comercial).
                   - Os NUCAMPO abaixo foram obtidos em TDDCAM filtrando por
                     NOMETAB = 'AD_TGSTPP' e correspondem à instalação atual;
                     se os campos forem recriados no configurador, os códigos
                     podem mudar.
                   - Campos CLOB grandes (resumo da proposta, parecer, decisão,
                     observação interna) são truncados com DBMS_LOB.SUBSTR ao
                     montar o corpo do e-mail, para evitar estouro de buffer
                     VARCHAR2.
                   - Destinatários fixos: sac@spark.ind.br e comercial@spark.ind.br.
                   - Nome do objeto limitado a 30 caracteres (limite do gatilho
                     de auditoria de DDL do ambiente).
==============================================================================*/
DECLARE
    -- NUCAMPO (TDDCAM) dos campos multi-escolha de AD_TGSTPP usados nos e-mails
    V_NC_SOLICITA_PRODUTOS     CONSTANT NUMBER := 9999994151;
    V_NC_SOLICITA_PATROCINIO   CONSTANT NUMBER := 9999994152;
    V_NC_SOLICITA_APOIO        CONSTANT NUMBER := 9999994153;
    V_NC_SOLICITA_DIVULGACAO   CONSTANT NUMBER := 9999994154;
    V_NC_SOLICITA_BENEFICENTE  CONSTANT NUMBER := 9999994183;
    V_NC_OFERECE_FEED          CONSTANT NUMBER := 9999994157;
    V_NC_OFERECE_REELS         CONSTANT NUMBER := 9999994158;
    V_NC_OFERECE_STORIES       CONSTANT NUMBER := 9999994159;
    V_NC_OFERECE_TIKTOK        CONSTANT NUMBER := 9999994160;
    V_NC_OFERECE_YOUTUBE       CONSTANT NUMBER := 9999994161;
    V_NC_OFERECE_VIDEOS_TEC    CONSTANT NUMBER := 9999994162;
    V_NC_OFERECE_EXPOSICAO     CONSTANT NUMBER := 9999994163;
    V_NC_OFERECE_LOGOTIPO      CONSTANT NUMBER := 9999994164;
    V_NC_OFERECE_USO_PRODUTOS  CONSTANT NUMBER := 9999994165;
    V_NC_OFERECE_PARTICIPACAO  CONSTANT NUMBER := 9999994166;
    V_NC_OFERECE_CONTEUDO_EXCL CONSTANT NUMBER := 9999994167;
    V_NC_ALCANCE_REDES         CONSTANT NUMBER := 9999994171;
    V_NC_PUBLICO_COMPATIVEL    CONSTANT NUMBER := 9999994172;
    V_NC_RELACAO_SEGMENTO      CONSTANT NUMBER := 9999994173;
    V_NC_PROPOSTA_PROFISSIONAL CONSTANT NUMBER := 9999994174;
    V_NC_PARECER_RECOMENDACAO  CONSTANT NUMBER := 9999994177;
    V_NC_DECISAO_COMERCIAL     CONSTANT NUMBER := 9999994178;

    V_TITULO       VARCHAR2(300);
    V_CONTEUDO     VARCHAR2(12000);
    V_CODFILA      NUMBER;
    V_OPERACAO     VARCHAR2(10);

    -- Traduz o código de um campo multi-escolha (TDDCAM/TDDOPC) para o texto
    -- da opção. Sem opção cadastrada, devolve o próprio código como fallback.
    FUNCTION GET_OPCAO(P_NUCAMPO NUMBER, P_VALOR TDDOPC.VALOR%TYPE) RETURN VARCHAR2 IS
        V_OPCAO TDDOPC.OPCAO%TYPE;
    BEGIN
        IF P_VALOR IS NULL THEN
            RETURN NULL;
        END IF;

        SELECT OPC.OPCAO
          INTO V_OPCAO
          FROM TDDOPC OPC
         WHERE OPC.NUCAMPO = P_NUCAMPO
           AND OPC.VALOR   = P_VALOR;

        RETURN V_OPCAO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN P_VALOR;
    END GET_OPCAO;

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
            <p><strong>Solicita:</strong><br/>
               Produtos: '              || NVL(GET_OPCAO(V_NC_SOLICITA_PRODUTOS,    :NEW.SOLICITA_PRODUTOS),    '-') || '<br/>
               Patrocínio Financeiro: ' || NVL(GET_OPCAO(V_NC_SOLICITA_PATROCINIO,   :NEW.SOLICITA_PATROCINIO_FINANCEIRO), '-') || '<br/>
               Apoio Institucional: '   || NVL(GET_OPCAO(V_NC_SOLICITA_APOIO,        :NEW.SOLICITA_APOIO_INSTITUCIONAL),   '-') || '<br/>
               Divulgação: '            || NVL(GET_OPCAO(V_NC_SOLICITA_DIVULGACAO,   :NEW.SOLICITA_DIVULGACAO),  '-') || '<br/>
               Eventos Beneficentes: '  || NVL(GET_OPCAO(V_NC_SOLICITA_BENEFICENTE,  :NEW.SOLICITA_BENEFICENTE), '-') || '
            </p>
            <p><strong>Outro Pedido:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.SOLICITA_OUTRO_TEXTO, 800, 1) || '</p>
            <p><strong>Oferece em Contrapartida:</strong><br/>
               Feed: '                     || NVL(GET_OPCAO(V_NC_OFERECE_FEED,          :NEW.OFERECE_FEED),          '-') || ' |
               Reels: '                    || NVL(GET_OPCAO(V_NC_OFERECE_REELS,         :NEW.OFERECE_REELS),         '-') || ' |
               Stories: '                  || NVL(GET_OPCAO(V_NC_OFERECE_STORIES,       :NEW.OFERECE_STORIES),       '-') || ' |
               TikTok: '                   || NVL(GET_OPCAO(V_NC_OFERECE_TIKTOK,        :NEW.OFERECE_TIKTOK),        '-') || ' |
               YouTube: '                  || NVL(GET_OPCAO(V_NC_OFERECE_YOUTUBE,       :NEW.OFERECE_YOUTUBE),       '-') || '<br/>
               Vídeos Técnicos: '          || NVL(GET_OPCAO(V_NC_OFERECE_VIDEOS_TEC,    :NEW.OFERECE_VIDEOS_TECNICOS), '-') || ' |
               Exposição da Marca: '       || NVL(GET_OPCAO(V_NC_OFERECE_EXPOSICAO,     :NEW.OFERECE_EXPOSICAO_MARCA), '-') || ' |
               Logotipo em Materiais: '    || NVL(GET_OPCAO(V_NC_OFERECE_LOGOTIPO,      :NEW.OFERECE_LOGOTIPO_MATERIAIS), '-') || '<br/>
               Uso dos Produtos Spark: '   || NVL(GET_OPCAO(V_NC_OFERECE_USO_PRODUTOS,  :NEW.OFERECE_USO_PRODUTOS),  '-') || ' |
               Participação em Eventos: '  || NVL(GET_OPCAO(V_NC_OFERECE_PARTICIPACAO,  :NEW.OFERECE_PARTICIPACAO_EVENTOS), '-') || ' |
               Conteúdo Exclusivo: '       || NVL(GET_OPCAO(V_NC_OFERECE_CONTEUDO_EXCL, :NEW.OFERECE_CONTEUDO_EXCLUSIVO), '-') || '
            </p>
            <p><strong>Frequência Prometida:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.QUANTIDADE_FREQUENCIA_PROMETIDA, 500, 1) || '</p>
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
            <p><strong>Checklist SAC:</strong><br/>
               Alcance nas Redes Sociais: '                                  || NVL(GET_OPCAO(V_NC_ALCANCE_REDES,         :NEW.ALCANCE_REDES_SOCIAIS), '-') || '<br/>
               Público Compatível com a Spark: '                             || NVL(GET_OPCAO(V_NC_PUBLICO_COMPATIVEL,    :NEW.PUBLICO_COMPATIVEL),    '-') || '<br/>
               Relação com o Segmento (automotivo/som/energia): '            || NVL(GET_OPCAO(V_NC_RELACAO_SEGMENTO,      :NEW.RELACAO_SEGMENTO),      '-') || '<br/>
               Proposta Demonstra Profissionalismo: '                        || NVL(GET_OPCAO(V_NC_PROPOSTA_PROFISSIONAL, :NEW.PROPOSTA_PROFISSIONAL), '-') || '
            </p>
            <p><strong>Pontos Positivos:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.PARECER_PONTOS_POSITIVOS, 1000, 1) || '</p>
            <p><strong>Pontos de Atenção:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.PARECER_PONTOS_ATENCAO, 1000, 1) || '</p>
            <p><strong>Recomendação do SAC:</strong> ' || NVL(GET_OPCAO(V_NC_PARECER_RECOMENDACAO, :NEW.PARECER_RECOMENDACAO), '-') || '</p>
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
            <p><strong>Decisão Comercial:</strong> ' || NVL(GET_OPCAO(V_NC_DECISAO_COMERCIAL, :NEW.DECISAO_COMERCIAL), '-') || '</p>
            <p><strong>Responsável pela Decisão:</strong> ' || :NEW.DECISAO_RESPONSAVEL || '</p>
            <p><strong>Data da Decisão:</strong> ' || TO_CHAR(:NEW.DECISAO_DATA, 'DD/MM/YYYY HH24:MI') || '</p>
            <p><strong>Observações da Decisão:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.DECISAO_OBSERVACOES, 1500, 1) || '</p>
            <p><strong>Observação Interna:</strong><br/>' || DBMS_LOB.SUBSTR(:NEW.OBSINTERNA, 1500, 1) || '</p>
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
