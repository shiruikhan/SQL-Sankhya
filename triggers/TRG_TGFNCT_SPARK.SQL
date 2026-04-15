create or replace TRIGGER TRG_TGFNCT_SPARK 
BEFORE INSERT OR UPDATE ON TGFNCT
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TGFNCT_SPARK
  Tipo           : Trigger
  Descrição      : Altera CST de frete para 90 conforme tipo de operação
                   de origem da nota fiscal
  Tabela         : TGFNCT
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 01/02/2022
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
P_CODTIPOPER  TGFTOP.CODTIPOPER%TYPE;
BEGIN

       
       

    BEGIN
    SELECT CAB.CODTIPOPER INTO P_CODTIPOPER
       FROM TGFCAB CAB WHERE CAB.CHAVENFE = :NEW.CHAVENFE;
     EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN;    
    END TRG_TGFNCT_SPARK;    

/*
AUTOR: DIONE/DANILO SK / LUCAS SPARK
DATA: 01/02/2022 
TRATA REGRA PARA MUDAR O CST DA NOTA DE FRETE EM FUNÇÃO DA ORIGEM DA NOTA COMPRA, 
 CASO SEJA CONSUMO NÃO APROVEITA O ICMS FRETE QUE SERÁ TRATADO PELO CST DO ITEM DE FRETE
 */
IF P_CODTIPOPER IN (201, 221, 209, 231, 228, 267) THEN
UPDATE TGFITE SET CODTRIB = 90 WHERE NUNOTA = :NEW.NUNOTA;

END IF;

END;