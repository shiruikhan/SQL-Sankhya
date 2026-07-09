create or replace TRIGGER TRG_INC_UPD_TGFITE_SPARK
BEFORE UPDATE ON TGFITE
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE_SPARK
  Tipo           : Trigger
  Descrição      : Atualiza local origem em transferências e insere séries de
                   produtos em faturamentos de produção (primeiro preenchimento
                   da nota a partir da conferência mais recente da OP).
  Tabela         : TGFITE
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT
  Tabelas        : TGFCAB, TPRIATV, TPRCONF, AD_TPRCOI (leitura)
                   TGFSER (escrita)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Julho/2026 — Inserção de séries passa a ocorrer somente no
                   primeiro preenchimento (nota ainda sem séries do item) e com
                   guarda antiduplicidade. Antes, qualquer UPDATE no item de
                   uma nota de produção reinseria as séries da conferência
                   MAX(NUCONF) da OP sem verificação, causando ORA-00001 em
                   PK_TGFSER e misturando séries de conferências diferentes na
                   mesma nota (conflito com a STP_CORRIGENOTAPROD_SPARK, que
                   mantém uma nota por conferência).
==============================================================================*/
DECLARE
    P_CODLOCAL NUMBER;
    P_TIPMOV   TGFCAB.TIPMOV%TYPE;
    P_NUCONF   TPRCONF.NUCONF%TYPE;
    P_COUNTSER NUMBER;

BEGIN
    BEGIN
        SELECT  NVL(AD_CODLOCALDEST, 0)
               ,TIPMOV
        INTO    P_CODLOCAL
               ,P_TIPMOV
        FROM    TGFCAB
        WHERE   NUNOTA = :NEW.NUNOTA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODLOCAL := 0;
    END;

    IF P_TIPMOV = 'T' AND P_CODLOCAL > 0 AND :NEW.CODLOCALORIG <> P_CODLOCAL AND :NEW.SEQUENCIA < 0 THEN
        :NEW.CODLOCALORIG := P_CODLOCAL;
    END IF;

    IF P_TIPMOV = 'F' AND :NEW.ATUALESTOQUE = 1 AND :NEW.RESERVA = 'N' THEN

        -- Injeta séries somente no primeiro preenchimento: se a nota já tem
        -- qualquer série deste item, o preenchimento é gerenciado por quem
        -- lançou (serviço nativo ou STP_CORRIGENOTAPROD_SPARK) e um novo
        -- UPDATE no item não deve reinserir nem misturar conferências
        SELECT  COUNT(*)
        INTO    P_COUNTSER
        FROM    TGFSER
        WHERE   NUNOTA  = :NEW.NUNOTA
        AND     CODPROD = :NEW.CODPROD;

        IF P_COUNTSER = 0 THEN
            BEGIN
                SELECT  MAX(CON.NUCONF)
                INTO    P_NUCONF
                FROM    TGFCAB CAB
                        INNER JOIN TPRIATV ATV ON CAB.IDIPROC = ATV.IDIPROC
                        INNER JOIN TPRCONF CON ON ATV.IDIATV  = CON.IDIATV
                WHERE   CAB.NUNOTA = :NEW.NUNOTA;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    P_NUCONF := 0;
            END;

            INSERT INTO TGFSER (
                NUNOTA, CODPROD, SEQUENCIA, SERIE,
                ATUALESTOQUE, CODUSU, DTALTER
            )
            SELECT  :NEW.NUNOTA
                   ,:NEW.CODPROD
                   ,:NEW.SEQUENCIA
                   ,COI.CODBARRA
                   ,1
                   ,STP_GET_CODUSULOGADO()
                   ,SYSDATE
            FROM    AD_TPRCOI COI
            WHERE   COI.NUCONF = P_NUCONF
            AND     NOT EXISTS (
                        SELECT  1
                        FROM    TGFSER SER
                        WHERE   SER.NUNOTA = :NEW.NUNOTA
                        AND     SER.SERIE  = COI.CODBARRA
                    );
        END IF;
    END IF;
END;