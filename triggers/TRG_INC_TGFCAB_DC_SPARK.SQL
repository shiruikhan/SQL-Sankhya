create or replace TRIGGER TRG_INC_TGFCAB_DC_SPARK
BEFORE INSERT ON TGFCAB
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TGFCAB_DC_SPARK
  Tipo           : Trigger
  Descrição      : Popula datas de negociação e entrada/saída a partir da data de produção do processo
  Tabela         : TGFCAB
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: eliminada a checagem de
                   existência (SELECT COUNT(*)) que só servia para decidir se
                   rodava um segundo SELECT idêntico em TPRIPROC — agora é um
                   único SELECT protegido por NO_DATA_FOUND. O IF interno
                   (P_DTPRODUCAO IS NOT NULL) também foi removido: como
                   P_DTPRODUCAO vem de NVL(AD_DTPRODUCAO, SYSDATE), nunca é
                   NULL quando o SELECT encontra a linha, então o IF já era
                   sempre verdadeiro nesse ponto. Comportamento observável
                   inalterado.
==============================================================================*/
DECLARE

P_DTPRODUCAO   DATE;

BEGIN

    BEGIN
        SELECT NVL(OP.AD_DTPRODUCAO, SYSDATE) INTO P_DTPRODUCAO
        FROM TPRIPROC OP
        WHERE OP.IDIPROC = :NEW.IDIPROC;

        :NEW.DTNEG := P_DTPRODUCAO;
        :NEW.DTENTSAI := P_DTPRODUCAO;
        :NEW.HRENTSAI := P_DTPRODUCAO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
END TRG_INC_TGFCAB_DC_SPARK;
