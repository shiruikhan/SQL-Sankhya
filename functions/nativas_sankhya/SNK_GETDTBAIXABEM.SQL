/*==============================================================================
  Nome do Script : SNK_GETDTBAIXABEM
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a data de baixa de um bem do imobilizado, desconsiderando retornos
                  ocorridos no mesmo mes.
  Assinatura     : SNK_GETDTBAIXABEM (P_CODPROD INT, P_CODBEM VARCHAR, P_REFERENCIA DATE)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETDTBAIXABEM', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETDTBAIXABEM (P_CODPROD INT, P_CODBEM VARCHAR, P_REFERENCIA DATE) RETURN DATE
IS
   P_DHBAIXA DATE;
BEGIN
/*
Func?o que retorna a data da baixa do bem considerando baixas e retornos, sendo que se o bem retornou no proprio mes ele n?o sera considerado baixado 
*/
   SELECT MAX(CAB.DTENTSAI) INTO P_DHBAIXA
   FROM TGFCAB CAB, TCIIBE IBE 
   WHERE IBE.NUNOTA = CAB.NUNOTA 
   AND IBE.ATUALBEM IN('1','B') AND CAB.STATUSNOTA = 'L'
   AND IBE.CODPROD = P_CODPROD AND IBE.CODBEM = P_CODBEM
   AND TO_CHAR(CAB.DTENTSAI, 'yyyy/mm') <= TO_CHAR(P_REFERENCIA, 'yyyy/mm')
   AND NOT EXISTS (
   SELECT 1
   FROM TGFCAB CAB1, TCIIBE IBE1
   WHERE IBE1.NUNOTA = CAB1.NUNOTA 
   AND IBE1.ATUALBEM IN('E') AND CAB1.STATUSNOTA = 'L'
   AND (IBE1.CODPROD = IBE.CODPROD AND IBE1.CODBEM = IBE.CODBEM)
   AND CAB1.DTENTSAI > CAB.DTENTSAI AND TO_CHAR(CAB1.DTENTSAI, 'yyyy/mm') <= TO_CHAR(P_REFERENCIA, 'yyyy/mm') 
   );
   RETURN P_DHBAIXA;
END;

 
 
