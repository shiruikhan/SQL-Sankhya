CREATE OR REPLACE TRIGGER TRG_INC_UPD_TGFPAR_UPPER_SPARK
BEFORE INSERT OR UPDATE OF NOMEPARC, RAZAOSOCIAL, NUMEND, COMPLEMENTO, CAIXAPOSTAL,
                           IDENTINSCESTAD, INSCESTADNAUF, INSCMUN, NOMEAGE,
                           OBSERVACOES, MOTBLOQ, COMOCONHECEU,
                           TIMPAI, TIMMAE, TIMREFERENCIA01, TIMREFERENCIA02, TIMORGAO,
                           AD_PROFISSAOLV
ON TGFPAR
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFPAR_UPPER_SPARK
  Tipo           : Trigger
  Descrição      : Padroniza o cadastro de parceiros forçando para MAIÚSCULO os
                   campos de texto livre (nome, razão social, endereço,
                   inscrições, observações etc.) na inclusão e na alteração.
                   E-mails ficam como digitados.
  Tabela         : TGFPAR
  Evento         : BEFORE INSERT OR UPDATE OF <campos de texto livre>
  Escopo         : FOR EACH ROW

  Tabelas        : TGFPAR -- cadastro de parceiros (alterado via :NEW)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 16/11/2026
  Última Revisão : Novembro/2026 — Criação

  Observações    : - Na inclusão converte todos os campos da lista. Na
                     alteração converte só os campos presentes no SET do
                     UPDATE (UPDATING('<campo>')): a tela do Sankhya grava só
                     os campos editados, então registros antigos em caixa mista
                     não são reescritos "de carona" quando outro campo é
                     editado — evita alteração fantasma de RAZAOSOCIAL,
                     NUMEND e COMPLEMENTO no histórico fiscal (TSIALT, gravado
                     pela nativa TRG_UPD_TGFPAR_LOG).
                   - O UPDATE OF da assinatura faz a trigger nem disparar em
                     alterações que não tocam nenhum campo da lista.
                   - Campos NÃO convertidos, de propósito:
                     * E-mails: EMAIL, EMAILNFE, EMAILNFSE, EMAILCTE,
                       EMAILNOTIFENTREGA (pedido do usuário).
                     * Sensíveis a caixa: HOMEPAGE (URL), CHAVEPIX,
                       AD_NOMEARQZEBRA (nome de arquivo), ASYNCCONSULTAID,
                       SENHAECONECT, TIMSENHASITE, TIMSENHADESC.
                     * Comparados com outros cadastros: GRUPOAUTOR (LIKE com
                       TGFTOP.GRUPOAUTOR nas nativas da TGFCAB), REDE (FK
                       para TSIRTEF), CONTACESSO.
                     * Preenchidos pela consulta cadastral: REGAPUR, CNAE.
                     * Lista de opções (TDDOPC): AD_RAMOATIVIDADE (5 opções
                       cadastradas; maiúsculo quebraria o valor da opção).
                     * Identificadores/códigos: AD_CODANTERIOR,
                       IDESTRANGEIRO, CODUNIMED, REGISTROANS, CODCTABCO,
                       CODAGE.
                     * Flags e domínios (VARCHAR2(1)/CHAR(1), códigos com
                       CHECK, opções AD_ de lista, campos *LV de controle da
                       loja virtual) e campos só numéricos (CEP, TELEFONE,
                       FAX, CGC_CPF, CPFPRODRURAL, CEI, INSCRCNO, LATITUDE,
                       LONGITUDE, TIMTELEFONE01/02, TIMOUTTELS).
                   - Não altera e-mail, então convive com TRG_INC_TGFPAR_SPARK
                     (que copia EMAIL para EMAILNFE) sem depender de ordem.
                   - Nome com 30 caracteres (limite da DDL_LOG.OBJETO).
                   - Colunas conferidas no banco em 16/11/2026 (ALL_TAB_COLUMNS
                     + TDDOPC): as 18 da lista existem e nenhuma é lista de
                     opções. O DDL versionado em nativo/tables/TGFPAR.SQL
                     (18/09/2026) está desatualizado — cita AD_INFCOMPLV,
                     que não existe mais no banco.
==============================================================================*/
BEGIN
    ---------------------------------------------------------------------------
    -- 1. Identificação e endereço
    ---------------------------------------------------------------------------
    IF INSERTING OR UPDATING('NOMEPARC')         THEN :NEW.NOMEPARC         := UPPER(:NEW.NOMEPARC);         END IF;
    IF INSERTING OR UPDATING('RAZAOSOCIAL')      THEN :NEW.RAZAOSOCIAL      := UPPER(:NEW.RAZAOSOCIAL);      END IF;
    IF INSERTING OR UPDATING('NUMEND')           THEN :NEW.NUMEND           := UPPER(:NEW.NUMEND);           END IF;
    IF INSERTING OR UPDATING('COMPLEMENTO')      THEN :NEW.COMPLEMENTO      := UPPER(:NEW.COMPLEMENTO);      END IF;
    IF INSERTING OR UPDATING('CAIXAPOSTAL')      THEN :NEW.CAIXAPOSTAL      := UPPER(:NEW.CAIXAPOSTAL);      END IF;

    ---------------------------------------------------------------------------
    -- 2. Inscrições (ex.: "isento" -> "ISENTO") e dados bancários descritivos
    ---------------------------------------------------------------------------
    IF INSERTING OR UPDATING('IDENTINSCESTAD')   THEN :NEW.IDENTINSCESTAD   := UPPER(:NEW.IDENTINSCESTAD);   END IF;
    IF INSERTING OR UPDATING('INSCESTADNAUF')    THEN :NEW.INSCESTADNAUF    := UPPER(:NEW.INSCESTADNAUF);    END IF;
    IF INSERTING OR UPDATING('INSCMUN')          THEN :NEW.INSCMUN          := UPPER(:NEW.INSCMUN);          END IF;
    IF INSERTING OR UPDATING('NOMEAGE')          THEN :NEW.NOMEAGE          := UPPER(:NEW.NOMEAGE);          END IF;

    ---------------------------------------------------------------------------
    -- 3. Textos livres
    ---------------------------------------------------------------------------
    IF INSERTING OR UPDATING('OBSERVACOES')      THEN :NEW.OBSERVACOES      := UPPER(:NEW.OBSERVACOES);      END IF;
    IF INSERTING OR UPDATING('MOTBLOQ')          THEN :NEW.MOTBLOQ          := UPPER(:NEW.MOTBLOQ);          END IF;
    IF INSERTING OR UPDATING('COMOCONHECEU')     THEN :NEW.COMOCONHECEU     := UPPER(:NEW.COMOCONHECEU);     END IF;

    ---------------------------------------------------------------------------
    -- 4. Filiação, referências e órgão emissor (campos TIM*)
    ---------------------------------------------------------------------------
    IF INSERTING OR UPDATING('TIMPAI')           THEN :NEW.TIMPAI           := UPPER(:NEW.TIMPAI);           END IF;
    IF INSERTING OR UPDATING('TIMMAE')           THEN :NEW.TIMMAE           := UPPER(:NEW.TIMMAE);           END IF;
    IF INSERTING OR UPDATING('TIMREFERENCIA01')  THEN :NEW.TIMREFERENCIA01  := UPPER(:NEW.TIMREFERENCIA01);  END IF;
    IF INSERTING OR UPDATING('TIMREFERENCIA02')  THEN :NEW.TIMREFERENCIA02  := UPPER(:NEW.TIMREFERENCIA02);  END IF;
    IF INSERTING OR UPDATING('TIMORGAO')         THEN :NEW.TIMORGAO         := UPPER(:NEW.TIMORGAO);         END IF;

    ---------------------------------------------------------------------------
    -- 5. Campos adicionais (AD_) de texto livre
    ---------------------------------------------------------------------------
    IF INSERTING OR UPDATING('AD_PROFISSAOLV')   THEN :NEW.AD_PROFISSAOLV   := UPPER(:NEW.AD_PROFISSAOLV);   END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,
            'TRG_INC_UPD_TGFPAR_UPPER_SPARK: Erro ao converter campos para maiúsculo. ' ||
            'CODPARC=' || :NEW.CODPARC || ' — ' || SQLERRM);
END;
/
