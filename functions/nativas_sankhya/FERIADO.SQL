/*==============================================================================
  Nome do Script : FERIADO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna 1 se a data e feriado (recorrente ou nao) para a
                  localidade do usuario/parceiro/empresa, senao 0.
  Assinatura     : FERIADO (P_DATMOV IN DATE,P_CODUSU IN NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FERIADO', 'SPARKPRD') FROM dual;
                  - Acentos aparecem como ? no DDL exportado; nao foi verificado
                    se o caractere esta corrompido no proprio banco ou apenas
                    na exportacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION FERIADO (P_DATMOV IN DATE,P_CODUSU IN NUMBER)
RETURN NUMBER
IS
  L_PAIS   INT;
  L_ESTADO INT;
  L_CIDADE INT;
  L_CODEMP INT;
  L_FERIADO INT;
  L_DATAREC DATE;
  L_CODPARC INT;
BEGIN
  L_CODEMP := 1;
  L_CIDADE := -1;
  
  IF(P_CODUSU > 0) THEN
     SELECT NVL(CODPARC,-1) INTO L_CODPARC FROM TSIUSU WHERE CODUSU = P_CODUSU;
  
  IF (L_CODPARC > -1) THEN -- se o usuario tem parceiro usamos a cidade deste parceiro.
      SELECT UFS.CODUF,UFS.CODPAIS,CID.CODCID 
         INTO L_ESTADO,L_PAIS,L_CIDADE 
         FROM TSIUFS UFS, TSICID CID, TGFPAR PAR 
         WHERE PAR.CODPARC = L_CODPARC AND PAR.CODCID = CID.CODCID AND CID.UF = UFS.CODUF;
  ELSE --Busca a empresa do usuario.
       SELECT NVL(CODEMP,1) INTO L_CODEMP FROM TSIUSU WHERE CODUSU = P_CODUSU;
  END IF;
  END IF;
  
  IF (L_CIDADE = -1 ) THEN -- se a cidade ainda n?o foi resolvida, devemos buscar a cidade da empresa 
     SELECT UFS.CODUF,
           UFS.CODPAIS,
         CID.CODCID 
            INTO L_ESTADO,L_PAIS,L_CIDADE 
            FROM TSIUFS UFS,TSICID CID,TSIEMP EMP 
            WHERE EMP.CODEMP = L_CODEMP AND EMP.CODCID = CID.CODCID AND CID.UF = UFS.CODUF;
  END IF;  

  -- Checamos o feriado nao recorrente.
  SELECT COUNT(1) 
         INTO L_FERIADO 
         FROM TSIFER 
         WHERE DTFERIADO = P_DATMOV AND RECORRENTE = 'N' AND (CODPAIS = L_PAIS OR CODUF = L_ESTADO OR CODCID = L_CIDADE OR NACIONAL = 'I');
   
  IF (L_FERIADO > 0) THEN
      RETURN 1;
  ELSE
      L_DATAREC := TO_DATE('1900-'||TO_CHAR(P_DATMOV,'MM')||'-'||TO_CHAR(  (CASE WHEN (TO_NUMBER( TO_CHAR(P_DATMOV,'MM')) = 2 AND TO_NUMBER( TO_CHAR(P_DATMOV,'DD')) = 29 ) THEN P_DATMOV - 1 ELSE P_DATMOV END) ,'DD'), 'YYYY-MM-DD');
   
      -- Checamos o feriado recorrente.
      SELECT COUNT(1) 
            INTO L_FERIADO 
            FROM TSIFER 
            WHERE DTFERIADO = L_DATAREC AND RECORRENTE = 'S' AND (CODPAIS = L_PAIS OR CODUF = L_ESTADO OR CODCID = L_CIDADE OR NACIONAL = 'I');
      IF (L_FERIADO > 0) THEN
         RETURN 1;
      END IF;
  END IF;
  RETURN 0;
END;
