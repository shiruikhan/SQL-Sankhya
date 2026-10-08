/*==============================================================================
  Nome do Script : GET_PROXIMO_DIA_UTIL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o proximo dia util a partir de uma data,
                  considerando fim de semana (conforme parametro) e feriados
                  da localidade do parceiro/usuario/cidade.
  Assinatura     : GET_PROXIMO_DIA_UTIL (P_DATA IN DATE, P_CODPAR IN NUMBER,
                  P_CODUSU IN NUMBER, P_CODCIDADE IN NUMBER) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_PROXIMO_DIA_UTIL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_PROXIMO_DIA_UTIL (P_DATA        IN DATE,
                                                 P_CODPAR      IN NUMBER,
                                                 P_CODUSU      IN NUMBER,
                                                 P_CODCIDADE   IN NUMBER)
   RETURN DATE
IS
   L_PAIS         INT;
   L_ESTADO       INT;
   L_CIDADE       INT;
   L_DIA_SEM      INT;
   L_DATAUTIL     DATE;
   L_FERIADO      INT;
   L_FERIADO2     INT;
   L_TRANSFVENC   CHAR;
BEGIN
   L_DATAUTIL := P_DATA;

   IF (P_CODPAR > -1)
   THEN                              -- Obtem a localidade atraves do parceiro
      SELECT UFS.CODUF, UFS.CODPAIS, CID.CODCID
        INTO L_ESTADO, L_PAIS, L_CIDADE
        FROM TSIUFS UFS, TSICID CID, TGFPAR PAR
       WHERE     PAR.CODPARC = P_CODPAR
             AND PAR.CODCID = CID.CODCID
             AND CID.UF = UFS.CODUF;
   ELSE
      IF (P_CODUSU > 0)
      THEN                            -- Obtem a localidade atraves do usuario
         SELECT UFS.CODUF, UFS.CODPAIS, CID.CODCID
           INTO L_ESTADO, L_PAIS, L_CIDADE
           FROM TSIUFS UFS,
                TSICID CID,
                TSIEMP EMP,
                TSIUSU USU
          WHERE     USU.CODUSU = P_CODUSU
                AND EMP.CODEMP = USU.CODEMP
                AND EMP.CODCID = CID.CODCID
                AND CID.UF = UFS.CODUF;
      ELSE
         IF (P_CODCIDADE > 0)
         THEN                          -- Obtem a localidade atraves da cidade
            SELECT UF.CODUF, UF.CODPAIS, CID.CODCID
              INTO L_ESTADO, L_PAIS, L_CIDADE
              FROM TSICID CID, TSIUFS UF
             WHERE CID.CODCID = P_CODCIDADE AND CID.UF = UF.CODUF;
         ELSE
            RAISE_APPLICATION_ERROR (
               -20101,
               'É necessário informar pelo menos 1 parâmetro válido');
         END IF;
      END IF;
   END IF;

   -- Busca o parametro que define se deve considerar finais de semana para titulo
   SELECT LOGICO
     INTO L_TRANSFVENC
     FROM TSIPAR
    WHERE CHAVE = 'TRANSFVENC';

   -- Enquanto não encontrar uma data util irá incrementar a data
   WHILE TRUE
   LOOP
      L_DIA_SEM := TO_CHAR (L_DATAUTIL, 'd');

      -- Valida se a data é sabado ou domingo e incrementa a data para a proxima segunda-feira
      IF (L_DIA_SEM = 1 OR L_DIA_SEM = 7 AND L_TRANSFVENC = 'S')
      THEN
         SELECT NEXT_DAY (L_DATAUTIL, 2) INTO L_DATAUTIL FROM DUAL;
      END IF;

      SELECT COUNT (1)                       -- Busca as datas não recorrentes
        INTO L_FERIADO
        FROM TSIFER
       WHERE     DTFERIADO = L_DATAUTIL
             AND RECORRENTE = 'N'
             AND (   CODPAIS = L_PAIS
                  OR CODUF = L_ESTADO
                  OR CODCID = L_CIDADE
                  OR NACIONAL = 'I');

      SELECT COUNT (1)                           -- Busca as datas recorrentes
        INTO L_FERIADO2
        FROM TSIFER
       WHERE     DTFERIADO LIKE CONCAT (TO_CHAR (L_DATAUTIL, 'dd/mm'), '/%')
             AND RECORRENTE = 'S';

      -- Valida se o feriado esta cadastrado na base de dados
      IF (L_FERIADO < 1 AND L_FERIADO2 < 1)
      THEN
         RETURN L_DATAUTIL;
      ELSE
         L_DATAUTIL := L_DATAUTIL + 1;
      END IF;
   END LOOP;

   RETURN L_DATAUTIL;
END;
