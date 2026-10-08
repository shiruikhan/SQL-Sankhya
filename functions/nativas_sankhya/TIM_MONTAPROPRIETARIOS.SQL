/*==============================================================================
  Nome do Script : TIM_MONTAPROPRIETARIOS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Lista os nomes dos proprietarios de um contrato de
                  administracao.
  Assinatura     : TIM_MONTAPROPRIETARIOS (NUCONTRATOADM IN NUMBER) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_MONTAPROPRIETARIOS', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_MONTAPROPRIETARIOS (NUCONTRATOADM IN NUMBER) RETURN VARCHAR2 IS
 RSP VARCHAR2(4000);
 PARTE VARCHAR2(1000);
 
 CURSOR RSLCD IS 
      SELECT NVL(RAZAOSOCIAL, NOMEPARC)  NOME 
      FROM TIMIMP IMP INNER JOIN TGFPAR PAR ON (IMP.IMPPROPRIETARIO = PAR.CODPARC)   
     WHERE IMP.IMPCONTRATO = NUCONTRATOADM  
     ORDER BY IMPPERCENTUAL, NVL(RAZAOSOCIAL, NOMEPARC);
 
 BEGIN
 
   RSP := '';
   FOR PES IN RSLCD LOOP
     IF LENGTH(RSP) > 1 THEN
       RSP := TRIM(RSP) || '; ';
     END IF;
     PARTE := PES.NOME;
     RSP := RSP || PARTE;                    
   END LOOP;
       
 RETURN RSP;

END;
