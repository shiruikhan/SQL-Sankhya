create or replace TRIGGER TRG_INC_TGFSER_SPARK
BEFORE INSERT OR UPDATE ON TGFSER
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TGFSER_SPARK
  Tipo           : Trigger
  Descrição      : Gerencia código de barras em ajustes de estoque/produção e limpa códigos em conferências
  Tabela         : TGFSER
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: a checagem de existência em
                   TGFBAR (SELECT COUNT(*), agora com ROWNUM = 1) e a busca de
                   CODVOL em TGFPRO só são úteis quando P_CODTIPOPER está no
                   conjunto {212,213,511,800} — nenhuma das duas ações do
                   corpo roda fora dele (o INSERT em TGFBAR exige esse
                   conjunto; o UPDATE em TGFEST exige o subconjunto
                   {212,213,800}, já contido nele). Ambas foram movidas para
                   dentro de um único IF P_CODTIPOPER IN (212,213,511,800),
                   evitando 2 consultas em toda inclusão/alteração de série
                   fora desses tipos de operação. Também corrigido END sem
                   rótulo válido (END TRG_INC_TGFSER_SPARK; num bloco interno
                   não rotulado) para END;. Comportamento observável
                   inalterado.
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
    WHERE CAB.NUNOTA = NVL(:NEW.NUNOTA,:OLD.NUNOTA);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    P_CODTIPOPER := 0;
  END;

  IF P_CODTIPOPER IN (212,213,511,800) THEN

    SELECT COUNT(*) INTO P_COUNT FROM TGFBAR WHERE CODPROD = :NEW.CODPROD AND CODBARRA = :NEW.SERIE AND ROWNUM = 1;

    BEGIN
      SELECT CODVOL INTO P_CODVOL
      FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
      EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN;
    END;

    /* VERIFICA SE FOI IMPUTADO SERIE NAS TOPS DE AJUSTE DE ESTOQUE /PRODUÇÃO PA PARA INCLUIR */
    IF P_CODTIPOPER IN ( 212,213,800,511) AND P_COUNT = 0 THEN
    INSERT INTO TGFBAR (CODBARRA,CODPROD,DHALTER,CODUSU,CODVOL) VALUES
     (:NEW.SERIE, :NEW.CODPROD,SYSDATE,0, P_CODVOL);


     END IF;

     IF P_CODTIPOPER IN ( 212,213,800) THEN
        /* LIMPAR O CÓDIGO DE BARRAS DA TABELA DE ESTOQUE APÓS A CONFERÊNCIA LIBERADA DA PRODUÇÃO, POIS ESTAVA IMPACTANDO NA CONFERÊNCIA DO PEDIDO NA EXPEDIÇÃO */
      UPDATE TGFEST SET CODBARRA=NULL
           WHERE CODPROD = :NEW.CODPROD
             AND CODBARRA = :NEW.SERIE
               AND CODLOCAL = 108;

    END IF;

  END IF;

END;
