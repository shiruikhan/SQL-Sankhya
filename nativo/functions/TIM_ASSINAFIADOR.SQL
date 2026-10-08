/*==============================================================================
  Nome do Script : TIM_ASSINAFIADOR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta os blocos de assinatura dos fiadores de uma locacao.
  Assinatura     : TIM_ASSINAFIADOR (CODLOCACAO IN NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_ASSINAFIADOR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_ASSINAFIADOR (CODLOCACAO IN NUMBER) RETURN VARCHAR2 IS
 --AUTOR: BOSCO
 RSP VARCHAR2(4000);
 PARTE VARCHAR2(1000);
 QB VARCHAR2(2); -- Quebra de linha
 TR VARCHAR2(60); -- Traço
 
 CURSOR RSLCD IS 
      SELECT PAR.CODPARC, RAZAOSOCIAL, TIPPESSOA, TIMESTADOCIVIL, PAR.CGC_CPF, CTC.NOMECONTATO CONJUGE, CTC.CPF CPFCONJUGE, CTR.NOMECONTATO RESPONSAVEL, CTR.CPF CPFRESP 
      FROM TIMLCF LCF INNER JOIN TGFPAR PAR ON LCF.LCFFIADOR = PAR.CODPARC  
           LEFT JOIN TGFCTT CTC ON PAR.CODPARC = CTC.CODPARC AND CTC.CARGO = 'CONJUGE'    
           LEFT JOIN TGFCTT CTR ON PAR.CODPARC = CTR.CODPARC AND CTC.CARGO = 'RESPONSÁVEL'  
     WHERE LCF.LCFLOCACAO = CODLOCACAO  
     ORDER BY RAZAOSOCIAL;
 
 BEGIN
   TR := LPAD('_', 60, '_');
   QB := CHR(13) || CHR(10);
   RSP := '';
   FOR PES IN RSLCD LOOP
     IF LENGTH(RSP) > 10 THEN
       RSP := TRIM(RSP) || QB || QB || QB || QB;
     END IF;
     PARTE := TR || QB || PES.RAZAOSOCIAL || QB;
     IF PES.TIPPESSOA = 'F' THEN
       PARTE := PARTE || 'CPF : ' || Tim_Formatacpfcnpj(PES.CGC_CPF, PES.TIPPESSOA);
     ELSE
       PARTE := PARTE || 'CNPJ : ' || Tim_Formatacpfcnpj(PES.CGC_CPF, PES.TIPPESSOA);
     END IF; 
     IF PES.TIMESTADOCIVIL = 'CA' THEN
       PARTE := PARTE || QB || QB || QB || QB;
       PARTE := PARTE || TR || QB || PES.CONJUGE || QB || 'CPF: ' || Tim_Formatacpfcnpj(PES.CPFCONJUGE, 'F');
     END IF; 
     IF PES.RESPONSAVEL IS NOT NULL THEN
      RSP := PARTE || QB || QB || QB || QB;
       PARTE := PARTE || TR || QB || PES.RESPONSAVEL || QB || 'CPF: ' || Tim_Formatacpfcnpj(PES.CPFRESP, 'F');
     END IF; 

     RSP := RSP || PARTE;                    
   END LOOP;
 RETURN RSP;
END;
