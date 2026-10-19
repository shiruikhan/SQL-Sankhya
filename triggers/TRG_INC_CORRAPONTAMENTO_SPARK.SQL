CREATE OR REPLACE TRIGGER TRG_INC_CORRAPONTAMENTO_SPARK
AFTER INSERT ON AD_CORRAPONTAMENTO
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_CORRAPONTAMENTO_SPARK
  Tipo           : Trigger
  Descrição      : Envia um alerta por e-mail a cada novo registro de auditoria
                   gravado em AD_CORRAPONTAMENTO (correções de apontamento
                   feitas pela STP_CORRIGEAPONTAMENTO_SPARK), com todos os
                   campos do registro e a descrição do produto acabado.
  Tabela         : AD_CORRAPONTAMENTO
  Evento         : AFTER INSERT
  Escopo         : FOR EACH ROW

  Tabelas        : AD_CORRAPONTAMENTO -- auditoria das correções (leitura via :NEW)
                   TGFPRO             -- cadastro de produtos (leitura, DESCRPROD)
                   TMDFMG             -- fila de e-mails (escrita via STP_GRAVA_FILA_BI2)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : STP_GRAVA_FILA_BI2

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 19/10/2026
  Última Revisão : Outubro/2026 — Criação

  Observações    : - Destinatário fixo: vieira.silvio@spark.ind.br.
                   - Falha no envio NÃO é relançada: o erro é gravado em
                     AD_LOG_ERROS e o INSERT segue, para que o alerta nunca
                     desfaça a correção de apontamento já feita na transação.
                   - O e-mail entra na fila (TMDFMG) na mesma transação do
                     INSERT; se a procedure fizer ROLLBACK da correção, o
                     e-mail também é descartado.
==============================================================================*/
DECLARE
    V_EMAIL_DEST CONSTANT VARCHAR2(100) := 'vieira.silvio@spark.ind.br';

    V_DESCRPROD  TGFPRO.DESCRPROD%TYPE;
    V_TITULO     VARCHAR2(256);
    V_CONTEUDO   VARCHAR2(8000);
    V_CODFILA    TMDFMG.CODFILA%TYPE;

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(P_OPERACAO VARCHAR2, P_ERR_CODE NUMBER, P_ERR_MSG VARCHAR2, P_ERR_BACKTRACE VARCHAR2, P_CALL_STACK VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA, ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK)
        VALUES (V_IDLOG, 'TRG_INC_CORRAPONTAMENTO_SPARK', SUBSTR(P_OPERACAO, 1, 10), :NEW.NUAPO, P_ERR_CODE,
                SUBSTR('NUCORR ' || :NEW.NUCORR || ' - ' || P_ERR_MSG, 1, 4000),
                SUBSTR(P_ERR_BACKTRACE, 1, 4000), SUBSTR(P_CALL_STACK, 1, 4000));
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END LOG_ERRO;
BEGIN
    ---------------------------------------------------------------------------
    -- 1. Busca a descrição do produto acabado
    ---------------------------------------------------------------------------
    BEGIN
        SELECT PRO.DESCRPROD
          INTO V_DESCRPROD
          FROM TGFPRO PRO
         WHERE PRO.CODPROD = :NEW.CODPRODPA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_DESCRPROD := '-';
    END;

    ---------------------------------------------------------------------------
    -- 2. Monta o e-mail com todos os campos do novo registro
    ---------------------------------------------------------------------------
    V_TITULO := 'Correção de Apontamento ' || :NEW.TIPOCORR || ' - OP ' || :NEW.IDIPROC || ' / NUAPO ' || :NEW.NUAPO;
    V_CONTEUDO := '
        <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
        <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
        <p><strong>Nº da Correção (NUCORR):</strong> ' || :NEW.NUCORR || '</p>
        <p><strong>Tipo da Correção:</strong> ' || :NEW.TIPOCORR || '</p>
        <p><strong>Data/Hora:</strong> ' || TO_CHAR(:NEW.DHCORR, 'DD/MM/YYYY HH24:MI:SS') || '</p>
        <p><strong>Conferência (NUCONF):</strong> ' || :NEW.NUCONF || '</p>
        <p><strong>Ordem de Produção (IDIPROC):</strong> ' || :NEW.IDIPROC || '</p>
        <p><strong>Apontamento (NUAPO / SEQAPA):</strong> ' || :NEW.NUAPO || ' / ' || :NEW.SEQAPA || '</p>
        <p><strong>Produto Acabado:</strong> ' || :NEW.CODPRODPA || ' - ' || V_DESCRPROD || '</p>
        <p><strong>Séries Conferidas (valor correto):</strong> ' || :NEW.QTDSERIES || '</p>
        <p><strong>Qtd. Apontada Anterior:</strong> ' || :NEW.QTDAPO_ANT || '</p>
        <p><strong>Qtd. Faturada Anterior:</strong> ' || :NEW.QTDFAT_ANT || '</p>
        <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
        <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
        </div>';

    ---------------------------------------------------------------------------
    -- 3. Grava na fila de e-mails
    ---------------------------------------------------------------------------
    SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;
    STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, V_EMAIL_DEST, NULL);

EXCEPTION
    WHEN OTHERS THEN
        -- Não relança: o alerta não pode desfazer a correção de apontamento
        LOG_ERRO('INSERT', SQLCODE, SQLERRM, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, DBMS_UTILITY.FORMAT_CALL_STACK);
END TRG_INC_CORRAPONTAMENTO_SPARK;
