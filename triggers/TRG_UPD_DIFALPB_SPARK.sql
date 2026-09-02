CREATE OR REPLACE TRIGGER TRG_UPD_DIFALPB_SPARK
AFTER UPDATE OF STATUSNFE ON TGFCAB
FOR EACH ROW
WHEN (NEW.STATUSNFE = 'A' AND (OLD.STATUSNFE IS NULL OR OLD.STATUSNFE <> 'A'))
/*==============================================================================
  Nome do Script : TRG_UPD_DIFALPB_SPARK
  Tipo           : Trigger
  Descricao      : Recalcula a base (BASEDIFAL) e o valor (VLRDIFALDEST) do
                   DIFAL destino apos a aprovacao da NF-e, porque a SEFAZ nao
                   aceita o valor calculado originalmente e a guia de apuracao
                   sai com valor superior ao correto.

                   Regras de negocio:
                   - Executa apenas na transicao de STATUSNFE para 'A'
                     (nota aprovada).
                   - Restringe as notas cujo parceiro destinatario esta na UF
                     configurada em V_CODUF_PB.
                   - Recalcula somente quando o parceiro e classificado como
                     CONSUMO final (TGFPAR.CLASSIFICMS = 'C'). Parceiros de
                     REVENDA (CLASSIFICMS = 'R') nao geram DIFAL e sao
                     ignorados.
                   - Atua apenas na linha de ICMS (TGFDIN.CODIMP = 1) com base
                     reduzida e ICMS proprio preenchidos.

                   Formula:
                     Nova base = (BASERED - VALOR) / (1 - aliquota interna)
                     DIFAL     = Nova base * aliquota do DIFAL

  Tabela         : TGFCAB
  Evento         : AFTER UPDATE OF STATUSNFE
  Tabelas        : TGFCAB  (leitura via :NEW)
                   TGFPAR  (leitura - classificacao ICMS do parceiro)
                   TSICID  (leitura - UF da cidade do parceiro)
                   TGFDIN  (escrita - BASEDIFAL, VLRDIFALDEST)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : STP_GET_ATUALIZANDO (funcao BOOLEAN de controle de
                   reentrancia; retorna TRUE durante processos internos de
                   atualizacao)
  Uso            : Disparada automaticamente pelo ERP na aprovacao da NF-e.

  Autor          : Lucas Gabriel
  Empresa        : Spark Eletronica
  Data de Criacao: 06/08/2026
  Ultima Revisao : 09/2026 - Silvio Vieira - Adicionado filtro
                   TGFPAR.CLASSIFICMS = 'C' para nao calcular DIFAL em notas
                   de revenda; disparo restrito a transicao de STATUSNFE para
                   'A'; adicionado handler EXCEPTION com log em AD_LOG_ERROS;
                   removido join redundante com TSIUFS; padronizacao de
                   cabecalho e nomenclatura.

  Observacoes    : - V_CODUF_PB = 17: codigo da UF de destino (PB) conforme
                     cadastro de TSICID.UF nesta base. Confirmar o codigo
                     antes de replicar para outros ambientes.
                   - Aliquotas fixas (interna 20%, DIFAL 13% = 20% - 7%). Se
                     a operacao usar aliquotas diferentes, o valor sai
                     incorreto.
                   - O criterio de consumo/revenda e por cadastro do parceiro
                     (TGFPAR.CLASSIFICMS). Se o mesmo parceiro operar nas duas
                     modalidades, avaliar criterio por CFOP/CODTIPOPER.
                   - Em caso de falha o erro e registrado e relancado,
                     bloqueando a aprovacao, para nao gerar guia divergente
                     de forma silenciosa.
==============================================================================*/
DECLARE

    V_COUNT NUMBER;

    -- Parametros utilizados no calculo:
    --   Aliquota interna do destino : 20%
    --   Aliquota interestadual      :  7%
    --   DIFAL                       : 13%
    V_ALIQ_INTERNA CONSTANT NUMBER := 0.20;
    V_ALIQ_DIFAL   CONSTANT NUMBER := 0.13;
    V_CODUF_PB     CONSTANT NUMBER := 17;

    ---------------------------------------------------------------------------
    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    ---------------------------------------------------------------------------
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2
       ,P_NUNOTA        NUMBER
       ,P_ERR_CODE      NUMBER
       ,P_ERR_MSG       VARCHAR2
       ,P_ERR_BACKTRACE VARCHAR2
       ,P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;

        INSERT INTO AD_LOG_ERROS (
             IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA
            ,ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
             V_IDLOG, 'TRG_UPD_DIFALPB_SPARK', P_OPERACAO, P_NUNOTA
            ,P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN

    ---------------------------------------------------------------------------
    -- 1. Evita reentrancia durante processos internos de atualizacao
    ---------------------------------------------------------------------------
    IF STP_GET_ATUALIZANDO THEN
        RETURN;
    END IF;

    ---------------------------------------------------------------------------
    -- 2. So prossegue se o parceiro destinatario for da UF configurada e
    --    estiver classificado como CONSUMO final (CLASSIFICMS = 'C').
    --    Parceiros de REVENDA (CLASSIFICMS = 'R') nao geram DIFAL.
    ---------------------------------------------------------------------------
    SELECT COUNT(0)
      INTO V_COUNT
      FROM TGFPAR PAR
     INNER JOIN TSICID CID
             ON CID.CODCID = PAR.CODCID
     WHERE PAR.CODPARC     = :NEW.CODPARC
       AND CID.UF          = V_CODUF_PB
       AND PAR.CLASSIFICMS = 'C';

    IF V_COUNT = 0 THEN
        RETURN;
    END IF;

    ---------------------------------------------------------------------------
    -- 3. Recalcula a base e o valor do DIFAL na linha de ICMS da nota
    --
    --    Nova base = (BASERED - VALOR) / (1 - aliquota interna)
    --    DIFAL     = Nova base * aliquota do DIFAL
    ---------------------------------------------------------------------------
    UPDATE TGFDIN
       SET BASEDIFAL    = ROUND((BASERED - VALOR) / (1 - V_ALIQ_INTERNA), 2)
          ,VLRDIFALDEST = ROUND(
                              ROUND((BASERED - VALOR) / (1 - V_ALIQ_INTERNA), 2)
                              * V_ALIQ_DIFAL
                          , 2)
     WHERE NUNOTA  = :NEW.NUNOTA
       AND CODIMP  = 1
       AND BASERED IS NOT NULL
       AND VALOR   IS NOT NULL;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO(
             'AFTER UPDATE STATUSNFE'
            ,:NEW.NUNOTA
            ,SQLCODE
            ,SQLERRM
            ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,DBMS_UTILITY.FORMAT_CALL_STACK
        );

        RAISE_APPLICATION_ERROR(
             -20051
            ,'TRG_UPD_DIFALPB_SPARK: falha ao recalcular DIFAL da nota '
             || :NEW.NUNOTA || ' - ' || SQLERRM
        );
END;
