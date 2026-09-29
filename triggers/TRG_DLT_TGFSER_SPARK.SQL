create or replace TRIGGER TRG_DLT_TGFSER_SPARK
BEFORE DELETE ON TGFSER
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_DLT_TGFSER_SPARK
  Tipo           : Trigger
  Descrição      : Gerencia códigos de barras ao deletar série (TOP de produção 800).
                  Remove de TGFBAR ou reinsere em TGFEST conforme contexto de exclusão.
  Tabela         : TGFSER
  Evento         : BEFORE DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: a checagem de existência em
                   TGFBAR (SELECT COUNT(*)) e a validação de CODPROD em
                   TGFPRO só são úteis quando P_CODTIPOPER = 800 — nenhuma das
                   duas ações do corpo (DELETE em TGFBAR, UPDATE em TGFEST)
                   roda fora desse caso. Ambas foram movidas para dentro do
                   IF P_CODTIPOPER = 800, evitando 2 consultas em toda
                   exclusão de série que não vem de TOP de produção 800
                   (a maioria). Também corrigido END sem rótulo válido
                   (END TRG_DLT_TGFSER_SPARK; num bloco interno não rotulado)
                   para END;. Comportamento observável inalterado.
==============================================================================*/
DECLARE
  P_CODTIPOPER  TGFCAB.CODTIPOPER%TYPE;
  P_CODVOL         TGFPRO.CODVOL%TYPE;
  P_COUNT        NUMBER;
BEGIN

  IF NOT FPODEVALIDAR('TGFSER') THEN
    RETURN;
  END IF;

  BEGIN
    SELECT
      CAB.CODTIPOPER
    INTO
      P_CODTIPOPER
    FROM
      TGFCAB CAB
    WHERE CAB.NUNOTA = :OLD.NUNOTA;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    P_CODTIPOPER := 0;
  END;

  /* VERIFICA SE FOI IMPUTADO SERIE NAS TOPS DE PRODUÇÃO PA PARA EXCLUIR  DESTA FORMA NÃO FICARÁ DISPONÍVEL PARA CONFERENCIA EXPEDIÇÃO*/
  IF P_CODTIPOPER = 800 THEN

    SELECT COUNT(*) INTO P_COUNT FROM TGFBAR WHERE CODPROD = :OLD.CODPROD AND CODBARRA = :OLD.SERIE AND ROWNUM = 1;

    BEGIN
      SELECT CODVOL INTO P_CODVOL
      FROM TGFPRO WHERE CODPROD = :OLD.CODPROD;
      EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN;
    END;

    IF P_COUNT = 0 THEN
      DELETE FROM TGFBAR WHERE CODPROD = :OLD.CODPROD AND CODBARRA = :OLD.SERIE;
    END IF;

    /* AO EXCLUIR O APONTAMENTO PRODUÇÃO INSERIR NOVAMENTE O CÓDIGO DE BARRAS NA TABELA ESTOQUE PARA A CONFERENCIA DA PRODUÇÃO PODER LER*/
    UPDATE TGFEST SET CODBARRA=:OLD.SERIE
         WHERE CODPROD = :OLD.CODPROD
           AND CODBARRA IS NULL
            AND CONTROLE = :OLD.SERIE
             AND CODLOCAL = 108;

  END IF;

END;
