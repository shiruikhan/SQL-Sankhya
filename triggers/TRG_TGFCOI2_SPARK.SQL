create or replace TRIGGER TRG_TGFCOI2_SPARK
BEFORE INSERT OR UPDATE ON TGFCOI2 FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TGFCOI2_SPARK
  Tipo           : Trigger
  Descrição      : Valida duplicidade de série na conferência, verifica disponibilidade
                   em estoque e vinculação com pedidos em aberto
  Tabela         : TGFCOI2
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 08/03/2022
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: os 3 SELECTs de validação agora
                   são calculados e validados em sequência, um a um, na mesma
                   ordem de precedência de erro que já existia na avaliação dos
                   IFs (estoque -> duplicidade na conferência -> pedido em
                   aberto vinculado), evitando 1 ou 2 consultas desnecessárias
                   quando uma validação anterior já falha. Adicionado
                   "AND ROWNUM = 1" nos SELECT COUNT(*) de P_COUNT e P_COUNT3,
                   cujo resultado é usado apenas como checagem de existência
                   (>0/=0), sem alterar a lógica de comparação. O SELECT de
                   P_COUNT2 NÃO recebeu ROWNUM=1 porque a mesma consulta também
                   calcula MAX(S.NUNOTA) em P_NUNOTA2, valor real exibido na
                   mensagem de erro — limitar a 1 linha mudaria esse valor. A
                   PRAGMA AUTONOMOUS_TRANSACTION foi mantida (não removida):
                   embora não haja COMMIT/ROLLBACK/DML no corpo, o trigger
                   consulta a própria tabela TGFCOI2 (SELECT de P_COUNT) dentro
                   de BEFORE INSERT/UPDATE ON TGFCOI2, e é essa pragma que
                   evita o erro ORA-04091 (tabela mutante) nessa consulta.
                   Comportamento observável inalterado.
==============================================================================*/
DECLARE
 P_COUNT          INT;
 P_COUNT2         INT;
 P_NUNOTA2        NUMBER;
 P_COUNT3         INT;
 PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    ---------------------------------------------------------------------------
    -- 1. Verifica se a série possui estoque disponível
    ---------------------------------------------------------------------------
    SELECT COUNT(*) INTO P_COUNT3
       FROM VGFSER
         WHERE SERIE=:NEW.CODBARRA
           AND CODPROD = :NEW.CODPROD
            AND ATUALESTOQUE = 1
            AND ROWNUM = 1;-- VERIFICA SE TEM ESTOQUE DA SÉRIE

    IF P_COUNT3 = 0 THEN

        RAISE_APPLICATION_ERROR(-20101,'Este número de série:'|| :NEW.CODBARRA||' não possui estoque disponível');
    END IF;

    ---------------------------------------------------------------------------
    -- 2. Valida dentro da mesma conferência se o código de barras já foi conferido
    ---------------------------------------------------------------------------
    SELECT COUNT(*) INTO P_COUNT
      FROM TGFCOI2
    WHERE CODBARRA = :NEW.CODBARRA
    AND NUCONF = :NEW.NUCONF
    AND ROWNUM = 1; /* 08/03/22 - ACRESCENTADO REGRA PARA VALIDAR DENTRO DA MESMA CONFERENCIA, POIS OCORREU CASO DA MESMA SÉRIE SER CONFERIDA, FATURADA, DEVOLVIDA E  FEITO PEDIDO NOVAMENTE  DIONE/LUCAS*/

    IF P_COUNT >  0    THEN

    RAISE_APPLICATION_ERROR(-20101,'Este número de série:'|| :NEW.CODBARRA||' já foi conferido!');
    END IF;

    ---------------------------------------------------------------------------
    -- 3. Valida se existe pedido em aberto vinculado à série (diferente do
    --    pedido conferido)
    ---------------------------------------------------------------------------
    SELECT COUNT(*), MAX(S.NUNOTA) INTO P_COUNT2, P_NUNOTA2 FROM TGFSER S INNER JOIN TGFCAB C ON (S.NUNOTA = C.NUNOTA)
    WHERE C.TIPMOV='P'
     AND C.PENDENTE='S'
       AND S.ATUALESTOQUE=0
        AND S.SERIE = :NEW.CODBARRA
         AND NOT EXISTS (SELECT 1 FROM TGFCON2 CON WHERE CON.NUNOTAORIG = C.NUNOTA AND CON.NUCONF = :NEW.NUCONF) ;

    IF P_COUNT2 > 0  THEN

    RAISE_APPLICATION_ERROR(-20101,'Este número de série:'|| :NEW.CODBARRA||' já foi conferido!Nro Único: '|| P_NUNOTA2);

    END IF;

END TRG_TGFCOI2_SPARK;