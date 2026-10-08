/*==============================================================================
  Nome do Script : EH_DIA_UTIL_EMP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna 1 se a data e dia util para a empresa (nao e
                  sabado/domingo nem feriado da cidade/UF/pais da empresa),
                  senao 0.
  Assinatura     : EH_DIA_UTIL_EMP (datainicial IN DATE, pCodEmp IN NUMBER)
                  RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EH_DIA_UTIL_EMP', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EH_DIA_UTIL_EMP (datainicial IN DATE,  pCodEmp IN NUMBER)
   RETURN INT
IS
   ppais           INT;
   pestado         INT;
   pcidade         INT;
   pcodparc        INT;
   pCount          INT;
   pdataini        DATE;
   pdia            INT;
   pmes            INT;
BEGIN
   IF datainicial IS NULL  THEN
      RETURN 0;
   END IF;
   IF TO_NUMBER (TO_CHAR (datainicial, 'D')) IN (1, 7) THEN -- sabado e domingo
      RETURN 0;
   END IF;
   pdataini := TRUNC (datainicial);
   SELECT ufs.coduf, ufs.codpais, cid.codcid
   INTO pestado, ppais, pcidade
   FROM TSIUFS ufs, TSICID cid, TSIEMP emp
   WHERE emp.codemp = pcodemp AND emp.codcid = cid.codcid AND cid.uf = ufs.coduf;
   --CONTANDO OS FERIADOS NAO RECORRENTES.
   SELECT COUNT (1)
   INTO pCount
   FROM TSIFER
   WHERE dtferiado = pdataini 
   AND recorrente = 'N'
   AND (codpais = ppais OR coduf = pestado OR codcid = pcidade OR nacional = 'I');
   IF pCount > 0 THEN
     RETURN 0;
   END IF;
      --FERIADO RECORRENTE
   pdia := TO_NUMBER (TO_CHAR (pdataini, 'DD'));
   pmes := TO_NUMBER (TO_CHAR (pdataini, 'MM'));
   IF pmes = 2 AND pdia = 29 THEN
     pdataini := TO_DATE ('1900-03-01', 'YYYY-MM-DD');
   ELSE
     pdataini := TO_DATE ('1900-' || TO_CHAR (pmes) || '-' || TO_CHAR (pdia), 'YYYY-MM-DD');
   END IF;
   SELECT COUNT (1)
   INTO pCount
   FROM TSIFER
   WHERE dtferiado = pdataini
   AND recorrente = 'S'
   AND (codpais = ppais OR coduf = pestado OR codcid = pcidade OR nacional = 'I');
   IF pCount > 0 THEN
      RETURN 0;
   END IF;
   RETURN 1;
END;
