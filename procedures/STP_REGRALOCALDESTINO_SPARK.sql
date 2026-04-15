create or replace PROCEDURE STP_REGRALOCALDESTINO_SPARK (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) AS
/*==============================================================================
  Nome do Script : STP_REGRALOCALDESTINO_SPARK
  Tipo           : Stored Procedure (Regra de Negócio)
  Descrição      : Procedure para aplicação de regra de local de destino.
                   Atualiza local de origem dos itens de nota conforme configuração.

  Parâmetros     : P_NUNOTA      — número único da nota fiscal
                   P_SUCESSO     — indicador de sucesso da regra (OUT)
                   P_MENSAGEM    — mensagem de retorno (OUT)
                   P_CODUSULIB   — código do usuário liberador (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
DECLARE
P_CODLOCAL  NUMBER;
 --AQUI SERIA A EXECUÇÃO DA ROTINA
BEGIN

BEGIN
SELECT NVL(AD_CODLOCALDEST,0) INTO P_CODLOCAL
FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
EXCEPTION WHEN NO_DATA_FOUND THEN
P_CODLOCAL:=0;
END;

 P_SUCESSO := 'S';

IF P_CODLOCAL > 0 THEN

 UPDATE TGFITE SET CODLOCALORIG=P_CODLOCAL
 WHERE NUNOTA = P_NUNOTA AND SEQUENCIA <0
 AND CODLOCALORIG <> P_CODLOCAL;
END IF;

 --P_MENSAGEM := 'A REGRA FALHOU DE PROPÓSITO, SÓ PARA TESTAR.';

 --SE FOR NECESSÁRIO DETERMINAR O LIBERADOR BASTA ATRIBUIR:

-- P_CODUSULIB := 10;
END;
END;