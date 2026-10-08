/*==============================================================================
  Nome do Script : FSP_DATA_DIA_UTIL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula a quantidade de dias uteis (descontando fins de
                  semana e feriados TSIFER) para a data, na localidade do
                  usuario.
  Assinatura     : FSP_DATA_DIA_UTIL (datainicial IN DATE, pcodusu IN NUMBER)
                  RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FSP_DATA_DIA_UTIL', 'SPARKPRD') FROM dual;
                  - Acentos aparecem como ? no DDL exportado; nao foi verificado
                    se o caractere esta corrompido no proprio banco ou apenas
                    na exportacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION FSP_DATA_DIA_UTIL (datainicial IN DATE,  pcodusu IN NUMBER)
   RETURN INT
IS
   presult         INT;
   ppais           INT;
   pestado         INT;
   pcidade         INT;
   pcodemp         INT;
   pdatarec        DATE;
   pcodparc        INT;
   pqtd            INT;
   pdata           DATE;
   pdiasnaouteis   INT;
   pdataini        DATE;
   pdatafim        DATE;
   pdia            INT;
   pmes            INT;
   pdatai          DATE;
   pdataf          DATE;
BEGIN
   IF datainicial IS NULL  THEN
      RETURN 0;
   END IF;

   pdataini := TRUNC (datainicial);
   pdatafim := TRUNC (datainicial);

   IF pdataini > pdatafim THEN
      RETURN 0;
   END IF;

   pdiasnaouteis := 0;
   pqtd := 0;
   --CALCULANDO OS SABADOS E DOMINGOS
   pdata := pdataini;

   WHILE pdata <= pdatafim
   LOOP
      -- 1-DOMINGO  7-SABADO
      IF TO_NUMBER (TO_CHAR (pdata, 'D')) IN (1, 7) THEN
         pqtd := pqtd + 1;
      END IF;

      pdata := pdata + 1;
   END LOOP;

   pdiasnaouteis := pqtd;
   pcodemp := 1;
   pcidade := -1;

   IF (pcodusu > 0) THEN
      SELECT NVL (codparc, -1)
        INTO pcodparc
        FROM TSIUSU
       WHERE codusu = pcodusu;

      IF (pcodparc > -1) THEN   -- se o usuario tem parceiro usamos a cidade deste parceiro.
         SELECT ufs.coduf, ufs.codpais, cid.codcid
           INTO pestado, ppais, pcidade
           FROM TSIUFS ufs, TSICID cid, TGFPAR par
          WHERE par.codparc = pcodparc AND par.codcid = cid.codcid AND cid.uf = ufs.coduf;
      ELSE   --Busca a empresa do usuario.
         SELECT NVL (codemp, 1)
           INTO pcodemp
           FROM TSIUSU
          WHERE codusu = pcodusu;
      END IF;
   END IF;

   IF (pcidade = -1) THEN   -- se a cidade ainda n?o foi resolvida, devemos buscar a cidade da empresa
      SELECT ufs.coduf, ufs.codpais, cid.codcid
        INTO pestado, ppais, pcidade
        FROM TSIUFS ufs, TSICID cid, TSIEMP emp
       WHERE emp.codemp = pcodemp AND emp.codcid = cid.codcid AND cid.uf = ufs.coduf;
   END IF;

   --CONTANDO OS FERIADOS NAO RECORRENTES.
   SELECT COUNT (1)
     INTO pqtd
     FROM TSIFER
    WHERE dtferiado BETWEEN pdataini AND pdatafim
      AND recorrente = 'N'
      AND (codpais = ppais OR coduf = pestado OR codcid = pcidade OR nacional = 'I')
      AND NOT TO_NUMBER (TO_CHAR (dtferiado, 'D')) IN (1, 7);   -- 1-DOMINGO  7-SABADO

   pdiasnaouteis := pdiasnaouteis + pqtd;

   --OBTENDO DATA INICIAL ( RETIRANDO 29/02 )
   pdatai := pdataini;

   pdia := TO_NUMBER (TO_CHAR (pdataini, 'DD'));
   pmes := TO_NUMBER (TO_CHAR (pdataini, 'MM'));

   IF pmes = 2 AND pdia = 29 THEN
      pdia := 01;
    pmes := 03;
   END IF;
   pdataini := TO_DATE ('1900' || '-' || TO_CHAR (pmes) || '-' || TO_CHAR (pdia), 'YYYY-MM-DD');

   --OBTENDO DATA FINAL  ( RETIRANDO 29/02 )
   pdataf := pdatafim;

   pdia := TO_NUMBER (TO_CHAR (pdatafim, 'DD'));
   pmes := TO_NUMBER (TO_CHAR (pdatafim, 'MM'));

   --pdataf := TO_DATE (TO_CHAR (pdatafim, 'YYYY') || '-' || TO_CHAR (pmes) || '-' || TO_CHAR (pdia), 'YYYY-MM-DD');
   IF pmes = 2 AND pdia = 29 THEN
      pdia := 01;
    pmes := 03;
   END IF;
   pdatafim := TO_DATE ('1900' || '-' || TO_CHAR (pmes) || '-' || TO_CHAR (pdia), 'YYYY-MM-DD');

   --CONTANDO OS FERIADOS RECORRENTES.
   SELECT COUNT (1)
     INTO pqtd
     FROM TSIFER
    WHERE (   (pdataini <= pdatafim AND dtferiado BETWEEN pdataini AND pdatafim)
           OR (    pdataini > pdatafim
               AND (   dtferiado BETWEEN pdataini AND TO_DATE ('1900-12-31', 'YYYY-MM-DD')
                    OR dtferiado BETWEEN TO_DATE ('1900-01-01', 'YYYY-MM-DD') AND pdatafim
                   )
              )
          )
      AND recorrente = 'S'
      AND (codpais = ppais OR coduf = pestado OR codcid = pcidade OR nacional = 'I')
      AND NOT TO_NUMBER (TO_CHAR (TO_DATE (TO_CHAR (SYSDATE, 'YYYY') || '-' || TO_CHAR (dtferiado, 'MM') || '-' || TO_CHAR (dtferiado, 'DD'),
                                           'YYYY-MM-DD'
                                          ),
                                  'D'
                                 )
                        ) IN (1, 7);   -- 1-DOMINGO  7-SABADO

   pdiasnaouteis := pdiasnaouteis + pqtd;
   presult := pdataf - pdatai - pdiasnaouteis + 1;

   IF presult < 0 THEN
      presult := 0;
   END IF;

   RETURN presult;
END;
