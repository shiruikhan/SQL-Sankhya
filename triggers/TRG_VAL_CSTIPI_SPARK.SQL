/* TRIGGER OBSOLETA / INATIVADA EM PRODUÇÃO (28/09/2026)
   Estava desativada (ALTER TRIGGER ... DISABLE) em produção antes da rodada de
   otimização de performance de Setembro/2026. O CREATE OR REPLACE TRIGGER
   feito durante a refatoração reativou-a silenciosamente — Oracle sempre
   recria uma trigger em estado ENABLED, independente do estado anterior — o
   que voltou a disparar a validação de CST IPI em processos legados (ex.:
   UPDATE de QTDENTREGUE/QTDFIXADA via TRG_INC_TGFVAR nativa) sobre itens
   antigos com CST IPI nulo/zero, bloqueando uma devolução de compra em
   produção (ORA-20101).
   Mantida aqui só como referência histórica. NÃO reativar (nem via
   CREATE OR REPLACE) sem antes confirmar com quem a desativou originalmente
   e sem tratar a causa raiz (itens legados sem CST IPI preenchido).

create or replace TRIGGER TRG_VAL_CSTIPI_SPARK
BEFORE INSERT OR UPDATE ON TGFITE
FOR EACH ROW
==============================================================================
  Nome do Script : TRG_VAL_CSTIPI_SPARK
  Tipo           : Trigger
  Descrição      : Valida obrigatoriedade de CST IPI para empresa 1 em
                   operações de compra
  Tabela         : TGFITE
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Março/2026
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — trigger marcada OBSOLETA/INATIVADA (ver nota
                   no topo do arquivo); nenhuma otimização de performance foi
                   mantida.
==============================================================================
DECLARE
    P_CODEMP INT;
    P_TIPMOV VARCHAR2(1);
BEGIN
    -- Valida se o campo CSTIPI é 0 ou nulo
    IF :NEW.CSTIPI IS NULL OR :NEW.CSTIPI = 0 THEN
        BEGIN
            -- Busca CODEMP e TIPMOV na tabela pai TGFCAB
            SELECT CODEMP, TIPMOV
            INTO P_CODEMP, P_TIPMOV
            FROM TGFCAB
            WHERE NUNOTA = :NEW.NUNOTA;

            -- Verifica se é Empresa 1 e Tipo de Movimento 'C'
            IF P_CODEMP = 1 AND P_TIPMOV = 'C' THEN
                RAISE_APPLICATION_ERROR(-20101, 'O campo CST IPI não pode ser 0 ou nulo para esta operação (Empresa 1, Tipo Movimento C).');
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Caso não encontre a nota (ex: carga de dados inconsistente), não valida
                NULL;
        END;
    END IF;
END;
*/
