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
==============================================================================*/
DECLARE 

P_COUNT         INT;
P_DTPRODUCAO   DATE;

BEGIN

    SELECT COUNT(*) INTO P_COUNT FROM TPRIPROC OP WHERE OP.IDIPROC = :NEW.IDIPROC;

    IF P_COUNT > 0 THEN

			SELECT NVL(OP.AD_DTPRODUCAO, SYSDATE) INTO P_DTPRODUCAO
			FROM TPRIPROC OP 
			WHERE OP.IDIPROC = :NEW.IDIPROC;

			IF P_DTPRODUCAO IS NOT NULL
				THEN

                :NEW.DTNEG := P_DTPRODUCAO;
                :NEW.DTENTSAI := P_DTPRODUCAO;
                :NEW.HRENTSAI := P_DTPRODUCAO;

                       --    RAISE_APPLICATION_ERROR(-20191,'RESULT: ' || :NEW.NUNOTA);
            END IF;					
     END IF;
END TRG_INC_TGFCAB_DC_SPARK;