create or replace PROCEDURE "STP_APONTACONFERENCIA_SPARK" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_APONTACONFERENCIA_SPARK
  Tipo           : Procedure (ação de botão)
  Descrição      : Acionada pelo botão de ação sobre os registros de conferência
                   de arquivo (TGFIXN). Para cada registro selecionado, grava em
                   AD_TGSIXN o apontamento de conferência: gera um novo NUCONF
                   (sequencial calculado a partir do último lançamento) e associa
                   o usuário logado e o arquivo conferido. O apontamento é único
                   por arquivo — se já existir um registro para o NUARQUIVO
                   selecionado, a linha é ignorada (nenhum novo apontamento é
                   criado nem o existente é alterado).
  Parâmetros     : P_CODUSU    — código do usuário logado, gravado em CODUSUINC
                   P_IDSESSAO  — identificador da execução (sessão do botão)
                   P_QTDLINHAS — quantidade de registros selecionados
                   P_MENSAGEM  — mensagem de retorno exibida ao usuário
  Tabelas        : AD_TGSIXN — gravação do apontamento (NUCONF, CODUSUINC, NUARQUIVO)
                   TGFIXN    — origem do campo NUARQUIVO selecionado na tela

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Bloqueio de apontamento duplicado por NUARQUIVO
                   (checagem prévia + UNIQUE em banco como rede de segurança)

  Observações    : - NUCONF é calculado como MAX(NUCONF) + 1 dentro da própria
                     transação, sem uso de sequence; execuções concorrentes do
                     botão podem colidir e devem ser evitadas.
                   - DTINI, DTFIM, OBSERVACAO e STATUS não são preenchidos por
                     este botão.
                   - Apontamento é único e imutável (ver UQ_AD_TGSIXN_NUARQUIVO
                     em tables/AD_TGSIXN.SQL e TRG_UPD_AD_TGSIXN_SPARK): registro
                     já existente para o arquivo nunca é sobrescrito por aqui.
==============================================================================*/
       FIELD_NUARQUIVO  NUMBER;
       V_NUCONF         AD_TGSIXN.NUCONF%TYPE;
       V_JA_EXISTE      NUMBER;
       V_QTD_GRAVADOS   NUMBER := 0;
       V_QTD_DUPLICADOS NUMBER := 0;
BEGIN

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
           FIELD_NUARQUIVO := ACT_INT_FIELD(P_IDSESSAO, I, 'NUARQUIVO');

           ---------------------------------------------------------------------------
           -- 1. Verifica se o arquivo ja possui apontamento (unico, nao editavel)
           ---------------------------------------------------------------------------
           SELECT COUNT(*)
             INTO V_JA_EXISTE
             FROM AD_TGSIXN
            WHERE NUARQUIVO = FIELD_NUARQUIVO;

           IF V_JA_EXISTE > 0 THEN
               V_QTD_DUPLICADOS := V_QTD_DUPLICADOS + 1;
           ELSE
               ---------------------------------------------------------------------
               -- 2. Calcula o proximo NUCONF a partir do ultimo lancamento
               ---------------------------------------------------------------------
               SELECT NVL(MAX(NUCONF), 0) + 1
                 INTO V_NUCONF
                 FROM AD_TGSIXN;

               ---------------------------------------------------------------------
               -- 3. Grava o apontamento de conferencia
               ---------------------------------------------------------------------
               BEGIN
                   INSERT INTO AD_TGSIXN (
                       NUCONF,
                       CODUSUINC,
                       NUARQUIVO,
                       DTINI
                   ) VALUES (
                       V_NUCONF,
                       P_CODUSU,
                       FIELD_NUARQUIVO,
                       SYSDATE
                   );
                   V_QTD_GRAVADOS := V_QTD_GRAVADOS + 1;
               EXCEPTION
                   -- Rede de seguranca contra corrida entre duas sessoes que
                   -- passaram na checagem do item 1 antes de qualquer uma commitar
                   WHEN DUP_VAL_ON_INDEX THEN
                       V_QTD_DUPLICADOS := V_QTD_DUPLICADOS + 1;
               END;
           END IF;

       END LOOP;

       COMMIT;

       P_MENSAGEM := V_QTD_GRAVADOS || ' apontamento(s) gravado(s) com sucesso.';
       IF V_QTD_DUPLICADOS > 0 THEN
           P_MENSAGEM := P_MENSAGEM || ' ' || V_QTD_DUPLICADOS || ' arquivo(s) já possuíam apontamento e foram ignorados.';
       END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_MENSAGEM := 'Erro ao gravar apontamento de conferência: ' || SQLERRM;
END;
