create or replace NONEDITIONABLE PROCEDURE "EVP_TGFIXN_EMAIL_SPARK" (
       P_TIPOEVENTO INT,    -- Identifica o tipo de evento
       P_IDSESSAO VARCHAR2, -- Identificador da execução. Serve para buscar informações dos campos da execução.
       P_CODUSU INT         -- Código do usuário logado
) AS
/*==============================================================================
  Nome do Script : EVP_TGFIXN_EMAIL_SPARK
  Tipo           : Procedure de Visão Externa (Evento de Tela)
  Descrição      : Envia notificações por e-mail automáticas quando notas de devolução
                   (CFOP 5201, 5202, 6201, 6202, 5410, 6410) são inseridas, informando
                   áreas de fiscal e controladoria com detalhes da operação.

  Parâmetros     : P_TIPOEVENTO — tipo do evento (0=BEFORE_INSERT, 1=AFTER_INSERT, etc.)
                   P_IDSESSAO   — identificador da execução
                   P_CODUSU     — código do usuário logado

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
       BEFORE_INSERT INT;
       AFTER_INSERT  INT;
       BEFORE_DELETE INT;
       AFTER_DELETE  INT;
       BEFORE_UPDATE INT;
       AFTER_UPDATE  INT;
       BEFORE_COMMIT INT;
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;

       IF P_TIPOEVENTO = AFTER_INSERT THEN
           DECLARE
               V_TITULO       VARCHAR2(300);
               V_CONTEUDO     VARCHAR2(4000);
               V_CODFILA      NUMBER;
               
               -- Variáveis dos campos da TGFIXN
               V_CFOPXML      VARCHAR2(4000);
               V_NUMNOTA      NUMBER;
               V_NUNOTA       NUMBER;
               V_CHAVEACESSO  VARCHAR2(4000);
               V_XNOMEEMIT    VARCHAR2(4000);
               V_DHEMISS      DATE;
               
               -- Procedure de Log de Erro (Interna)
               PROCEDURE LOG_ERRO(P_OPERACAO VARCHAR2, P_ERR_CODE NUMBER, P_ERR_MSG VARCHAR2, P_ERR_BACKTRACE VARCHAR2, P_CALL_STACK VARCHAR2) IS
                   PRAGMA AUTONOMOUS_TRANSACTION;
                   V_IDLOG NUMBER;
               BEGIN
                   SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
                   INSERT INTO AD_LOG_ERROS (IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA, NUMNOTA, CFOPXML, CHAVEACESSO, XNOMEEMIT, ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK)
                   VALUES (V_IDLOG, 'EVP_TGFIXN_EMAIL_SPARK', P_OPERACAO, V_NUNOTA, V_NUMNOTA, V_CFOPXML, V_CHAVEACESSO, V_XNOMEEMIT, P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK);
                   COMMIT;
               EXCEPTION
                   WHEN OTHERS THEN
                       NULL;
               END;

           BEGIN
               -- Recuperando valores dos campos
               V_NUNOTA      := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
               V_NUMNOTA     := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUMNOTA');
               V_CFOPXML     := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'CFOPXML');
               V_CHAVEACESSO := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'CHAVEACESSO');
               V_XNOMEEMIT   := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'XNOMEEMIT');
               V_DHEMISS     := EVP_GET_CAMPO_DTA(P_IDSESSAO, 'DHEMISS');

               IF V_CFOPXML IS NOT NULL AND (
                    V_CFOPXML LIKE '%5201%' OR
                    V_CFOPXML LIKE '%5202%' OR
                    V_CFOPXML LIKE '%6201%' OR
                    V_CFOPXML LIKE '%6202%' OR
                    V_CFOPXML LIKE '%5410%' OR
                    V_CFOPXML LIKE '%6410%'
                  ) THEN
                   SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;
                   
                   V_TITULO := 'Nova Nota de Devolução Emitida - NF ' || V_NUMNOTA;
                   
                   V_CONTEUDO := '
                       <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
                       <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
                       <p><strong>Emitente:</strong> ' || V_XNOMEEMIT || '</p>
                       <p><strong>CFOP:</strong> ' || V_CFOPXML || '</p>
                       <p><strong>Número da Nota:</strong> ' || V_NUMNOTA || '</p>
                       <p><strong>Chave de Acesso:</strong> ' || V_CHAVEACESSO || '</p>
                       <p><strong>Data de Emissão:</strong> ' || TO_CHAR(V_DHEMISS, 'DD/MM/YYYY HH24:MI') || '</p>
                       <p>Foi detectada a emissão de uma nova nota de devolução.</p>
                       <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
                       <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
                       </div>';
                       
                   STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'fiscal@spark.ind.br', NULL);
                   STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, 'controladoria@spark.ind.br', NULL);
               END IF;

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   LOG_ERRO('INSERT', SQLCODE, SQLERRM, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, DBMS_UTILITY.FORMAT_CALL_STACK);
                   RAISE_APPLICATION_ERROR(-20022, 'Dados não encontrados para envio de e-mail (CFOPXML).');
               WHEN OTHERS THEN
                   LOG_ERRO('INSERT', SQLCODE, SQLERRM, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, DBMS_UTILITY.FORMAT_CALL_STACK);
                   RAISE_APPLICATION_ERROR(-20097, 'Erro na procedure EVP_TGFIXN_EMAIL_SPARK: ' || SQLERRM);
           END;
       END IF;
END;
