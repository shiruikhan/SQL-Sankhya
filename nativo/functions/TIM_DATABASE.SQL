/*==============================================================================
  Nome do Script : TIM_DATABASE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula a proxima data-base de reajuste contratual a partir
                  da data de inicio, periodo e duracao em meses.
  Assinatura     : TIM_DATABASE (DTINICIO IN DATE, PERIODO IN NUMBER, DURACAO
                  IN NUMBER default 12) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_DATABASE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_DATABASE (DTINICIO IN DATE, PERIODO IN NUMBER, DURACAO IN NUMBER default 12) RETURN DATE IS
 --AUTOR: BOSCO
 RSP DATE;
 
 BEGIN
   RSP := ADD_MONTHS(DtINicio, Periodo);
   WHILE rsp < TRUNC(SYSDATE) LOOP
     RSP := ADD_MONTHS(rsp, Periodo);
   END LOOP;
   if rsp > add_Months(DtInicio, Duracao) then
     rsp := add_Months(DtInicio, Duracao);
   end if;
   rsp := rsp - 1;
       
 RETURN RSP;

END;
