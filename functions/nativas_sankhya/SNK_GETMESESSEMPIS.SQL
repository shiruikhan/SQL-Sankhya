/*==============================================================================
  Nome do Script : SNK_GETMESESSEMPIS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula quantos meses um bem do imobilizado ficou sem apropriacao de
                  credito de PIS/COFINS, considerando baixas e retornos.
  Assinatura     : SNK_GETMESESSEMPIS (P_CODPROD INT, P_CODBEM VARCHAR, P_REFERENCIA DATE)
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETMESESSEMPIS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETMESESSEMPIS (P_CODPROD INT, P_CODBEM VARCHAR, P_REFERENCIA DATE) RETURN INT
IS
   P_MESES INT;
BEGIN
/*
Função que retorna o número de meses que não foi apropriado o crédito de PIS/COFINS em função da baixa do imobilizado e seu retorno 
*/
SELECT SUM(TO_NUMBER(TO_CHAR(CAB.DTENTSAI, 'yyyy')) * 12 + TO_NUMBER(TO_CHAR(CAB.DTENTSAI, 'mm')) - CAB1.DTRESULT - 1) INTO P_MESES
   FROM TGFCAB CAB
      , TCIIBE IBE 
      , (SELECT MAX(TO_NUMBER(TO_CHAR(DTENTSAI, 'yyyy')) * 12 + TO_NUMBER(TO_CHAR(DTENTSAI, 'mm'))) AS DTRESULT
                , CAB1.DTENTSAI
                , IBE1.CODPROD
                , IBE1.CODBEM
         FROM TGFCAB CAB1
              , TCIIBE IBE1
         WHERE IBE1.NUNOTA = CAB1.NUNOTA 
           AND IBE1.ATUALBEM = 'B' AND CAB1.STATUSNOTA = 'L'
         GROUP BY CAB1.DTENTSAI, IBE1.CODPROD, IBE1.CODBEM) CAB1
   WHERE IBE.NUNOTA = CAB.NUNOTA 
   AND IBE.ATUALBEM = 'E' AND CAB.STATUSNOTA = 'L'
   AND TO_CHAR(CAB.DTENTSAI, 'yyyy/mm') <= TO_CHAR(P_REFERENCIA, 'yyyy/mm')
   AND IBE.CODPROD = P_CODPROD AND IBE.CODBEM = P_CODBEM
   AND CAB1.CODPROD = IBE.CODPROD AND CAB1.CODBEM = IBE.CODBEM
   AND TO_CHAR(CAB1.DTENTSAI, 'yyyy/mm') < TO_CHAR(CAB.DTENTSAI, 'yyyy/mm') 
   AND (TO_NUMBER(TO_CHAR(CAB.DTENTSAI, 'yyyy')) * 12 + TO_NUMBER(TO_CHAR(CAB.DTENTSAI, 'mm')) - CAB1.DTRESULT -1) > 0;
   P_MESES := NVL(P_MESES, 0);
   RETURN P_MESES;
END;
