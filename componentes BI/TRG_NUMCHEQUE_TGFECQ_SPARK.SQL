/*==============================================================================
  Nome do Script : TRG_NUMCHEQUE_TGFECQ_SPARK
  Tipo           : Trigger — arquivo mal categorizado (deveria estar em triggers/)
  Dashboard      : Gestão de Cheques e Financeiro
  Descrição      : Trigger que sincroniza número de cheque para os registros de
                   movimentação bancária (TGFMBC) quando insere/atualiza evento em TGFECQ.

  Parâmetros     : Sem parâmetros

  Tabelas        : TGFECQ, TGFCHQ, TGFMBC, TGFTRC (principais)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

CREATE OR REPLACE TRIGGER "SPARKTST"."TRG_NUMCHEQUE_TGFECQ_SPARK" 
AFTER INSERT OR UPDATE ON TGFECQ
FOR EACH ROW
DECLARE
    V_NUMCHEQUE   TGFCHQ.NUMCHEQUE%TYPE;
    V_NUBCO       NUMBER;
    V_NUMTRANSF   NUMBER;
BEGIN
    -- 1. Captura o NUMCHEQUE da tabela vinculada
	
    SELECT NUMCHEQUE 
		INTO V_NUMCHEQUE
    FROM TGFCHQ
    WHERE NUCHQ = :NEW.NUCHQ;

    -- 2. Extrai os parâmetros do campo JSON (DETALHE)
	
    V_NUBCO     := TO_NUMBER(JSON_VALUE(:NEW.DETALHE, '$.evento.financeiro.NUBCO'));
	
   --- V_NUMTRANSF := TO_NUMBER(JSON_VALUE(:NEW.DETALHE, '$.evento.financeiro.NUMTRANSF'));

    -- 3. Update pelo NUBCO (Movimentação direta)
    IF V_NUBCO IS NOT NULL
	THEN
        UPDATE TGFMBC
        SET NUMDOC  = V_NUMCHEQUE
        WHERE NUBCO = V_NUBCO;
		
    END IF;
	-- 4. Update pelo NUMTRANSF (Movimentação de transferência/origem)	
	BEGIN 
	
		UPDATE TGFMBC MBC
		SET NUMDOC = (
				SELECT CHQ.NUMCHEQUE
				FROM TGFCHQ CHQ
				JOIN TGFTRC TRC 
					ON TRC.NUFIN = CHQ.NUFIN
				WHERE CHQ.NUCHQ = :NEW.NUCHQ
				AND TRC.NUMTRANSF = MBC.NUMTRANSF
		)
		WHERE EXISTS (
				SELECT 1
				FROM TGFCHQ CHQ
				JOIN TGFTRC TRC 
					ON TRC.NUFIN = CHQ.NUFIN
				WHERE CHQ.NUCHQ = :NEW.NUCHQ
				AND TRC.NUMTRANSF = MBC.NUMTRANSF
		);
	
	END;
	

EXCEPTION
    WHEN NO_DATA_FOUND 
	THEN
        NULL; -- Evita erro se o cheque não for encontrado
    WHEN OTHERS THEN
        NULL; -- Evita que falhas no log travem a operação principal
END;
