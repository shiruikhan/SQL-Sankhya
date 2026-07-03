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

  Observações    : - NUCONF não é gerado aqui: o Sankhya já auto-incrementa a
                     PK da tela, sem necessidade (ou risco de concorrência)
                     de cálculo manual via MAX+1.
                   - CODUSUINC vem de STP_GET_CODUSULOGADO(), padrão já usado
                     em outras triggers do projeto para capturar o usuário
                     logado fora do contexto de botão de ação.
                   - CODEMP é fixado em 1 (única empresa neste cenário);
                     existe apenas para viabilizar a FK composta
                     FK_AD_TGSIXN_CODFUNC contra a PK composta de TFPFUN
                     (CODEMP, CODFUNC). Setado aqui, não confiando só no
                     DEFAULT da coluna, caso a tela envie NULL explícito.
                   - NUMNOTA e DHEMISS vêm de TGFIXN, localizados pelo
                     NUARQUIVO selecionado na tela (mesma busca, um único
                     SELECT); se não encontrar (arquivo inválido ou ainda
                     sem nota vinculada), ambos ficam NULL em vez de
                     interromper o INSERT.
                   - DURACAO_DIAS_UTEIS começa com o valor do dia de criação
                     (0 ou 1, conforme hoje seja fim de semana ou dia útil).
                     A partir daí, quem mantém o valor atualizado enquanto o
                     apontamento estiver aberto é STP_ATUALIZADTFIM_TGSIXN_SPARK
                     (job agendado) — não há trigger de UPDATE recalculando
                     isso, já que nada mais toca a linha até o job rodar.
                   - DTFIM e STATUS não são tratados aqui: continuam a cargo
                     de TRG_INC_UPD_TGSIXN_DTFIM_SPARK e
                     TRG_INC_UPD_AD_TGSIXN_SPARK, já em produção.
                   - Sobrescreve CODUSUINC/DTINI/CODEMP/NUMNOTA/DHEMISS/
                     DURACAO_DIAS_UTEIS mesmo que informados na tela,
                     garantindo que o apontamento sempre reflita quem e
                     quando realmente o criou.
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
