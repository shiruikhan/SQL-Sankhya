CREATE OR REPLACE TRIGGER TRG_INC_AD_TGSIXN_SPARK
BEFORE INSERT ON AD_TGSIXN
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_AD_TGSIXN_SPARK
  Tipo           : Trigger
  Descrição      : Preenche automaticamente os campos de identidade do
                   apontamento de conferência ao ser criado diretamente na
                   tela de AD_TGSIXN. Como TGFIXN não permite botão de ação,
                   o usuário passou a acessar a tela de AD_TGSIXN e criar o
                   apontamento informando apenas o NUARQUIVO (a nota a
                   conferir); esta trigger assume parte do papel que antes
                   era da STP_APONTACONFERENCIA_SPARK (agora inativa) para
                   gerar CODUSUINC, DTINI, NUMNOTA e DHEMISS. NUCONF não é
                   tratado aqui: o próprio Sankhya faz o auto incremento da
                   PK na tela, sem risco de concorrência.
  Tabela         : AD_TGSIXN
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSIXN -- registro alterado via :NEW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Criação
==============================================================================*/
DECLARE
    V_NUMNOTA TGFIXN.NUMNOTA%TYPE;
    V_DHEMISS TGFIXN.DHEMISS%TYPE;
BEGIN
    :NEW.CODUSUINC := STP_GET_CODUSULOGADO();
    :NEW.DTINI     := SYSDATE;
    :NEW.CODEMP    := 1;

    BEGIN
        SELECT IXN.NUMNOTA, IXN.DHEMISS
          INTO V_NUMNOTA, V_DHEMISS
          FROM TGFIXN IXN
         WHERE IXN.NUARQUIVO = :NEW.NUARQUIVO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_NUMNOTA := NULL;
            V_DHEMISS := NULL;
    END;

    :NEW.NUMNOTA := V_NUMNOTA;
    :NEW.DHEMISS := V_DHEMISS;

    -- Dia da criacao conta como dia util se cair de segunda a sexta
    :NEW.DURACAO_DIAS_UTEIS :=
        CASE WHEN TO_CHAR(:NEW.DTINI, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') NOT IN ('SAT', 'SUN')
             THEN 1 ELSE 0 END;
END;
