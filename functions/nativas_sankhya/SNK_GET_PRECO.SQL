/*==============================================================================
  Nome do Script : SNK_GET_PRECO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Engine nativo de precificacao: resolve o preco de um produto numa tabela
                  (NUTAB), navegando exceções e tabelas de origem recursivamente ate
                  encontrar o preco vigente.
  Assinatura     : SNK_GET_PRECO (P_NUTAB INT, P_CODPROD INT, P_DTVIGOR DATE)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PRECO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PRECO (P_NUTAB INT, P_CODPROD INT, P_DTVIGOR DATE)
RETURN FLOAT
IS
   TROCA              INT;
   P_CODTAB           TGFTAB.CODTAB%TYPE;
   P_CODTABORIG       TGFTAB.CODTAB%TYPE;
   P_DECVLR           TGFPRO.DECVLR%TYPE;
   P_CODGRUPOPROD     TGFPRO.CODGRUPOPROD%TYPE;
   P_COMVEND          TGFPRO.COMVEND%TYPE;
   P_COMGER           TGFPRO.COMGER%TYPE;
   P_MARGLUCRO        TGFPRO.MARGLUCRO%TYPE;
   P_ESTMAX           TGFPRO.ESTMAX%TYPE;
   P_COUNT            INT;
   P_TIPO             CHAR;
   P_VALOR            FLOAT;
   P_PERCEN           FLOAT;
   P_MULTIP           FLOAT;
   P_CUSFIX           FLOAT;
   P_PERCGRUPO        FLOAT;
   P_DTVIGORAUX       DATE;
   P_SEMPRE           CHAR;
   P_ATIVO            CHAR (1);
   P_UTILZADECCUSTO   CHAR (1);
   P_CUSTODEC         NUMBER (10);
   P_PRECO            FLOAT;
BEGIN
   -- QDO BUSCAR UM NUTAB P/UM CODTAB QUE NAO TIVER EXCECAO DE PRECO POR ELE BUSCAR A TABELA DE ORIGEM E NAO O NUTAB ANTERIOR DA MESMA TABELA.
    /*
     MARCELO    : 11/12/2002
     OBSERVACAO : TEM PERSONALIZACOES PARA O COCAL, QUANDO FOR MEXER NESSA PROCEDURE LEMBRAR
                  DE ELIMINAR O COMENTARIO PARA A COCAL. E JUNCO
    */
    P_PRECO := 0;
    P_VALOR := 0;
    P_CUSTODEC := GET_TSIPAR_INTEIRO('CUSTODEC');

    BEGIN
      SELECT NTA.ATIVO, NVL(TAB.CODTABORIG, TAB.CODTAB), TAB.CODTAB
        INTO P_ATIVO, P_CODTABORIG, P_CODTAB
        FROM TGFTAB TAB, TGFNTA NTA
       WHERE TAB.NUTAB = P_NUTAB
         AND TAB.CODTAB = NTA.CODTAB;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN P_PRECO;
    END;


    IF (P_ATIVO = 'N') THEN
      RETURN P_PRECO;
    END IF;

    BEGIN
      SELECT NVL (DECVLR, 2),
             COMVEND,
             COMGER,
             MARGLUCRO,
             ESTMAX,
             CODGRUPOPROD
        INTO P_DECVLR,
             P_COMVEND,
             P_COMGER,
             P_MARGLUCRO,
             P_ESTMAX,
             P_CODGRUPOPROD
        FROM TGFPRO
        WHERE CODPROD = P_CODPROD AND
              CODPROD <> 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN P_PRECO;
    END;

    P_DTVIGORAUX := P_DTVIGOR;

    IF (P_DTVIGOR IS NULL) THEN
      P_DTVIGORAUX := SYSDATE ();
    END IF;

    P_SEMPRE := 'S';
    P_MULTIP := 0;
    TROCA := P_NUTAB;

   -- COM ESTE TECHO, NAO PODE EXCLUIR PRODUTO, TEM QUE INCLUIR PRECO ZERO. SE APAGAR UM PRECO, O PRECO ANTERIOR VOLTA.
   -- SEM ISTO, TODOS OS PRODUTOS DE TABORIG=TAB TEM QUE SER COPIADOS PARA A NOVA TABELA. ISTO PERMITE EXCLUIR PRODUTOS, JA QUE O ULTIMO NAO SERA APRESENTADO.
   /* IF P_CODTABORIG = P_CODTAB AND P_CODTAB <> 0 THEN
      SELECT COUNT (1)
        INTO P_COUNT
        FROM TGFEXC E
       WHERE E.NUTAB = TROCA
         AND E.CODPROD = P_CODPROD;
      IF P_COUNT = 0 THEN
        SELECT NVL(MAX (M.NUTAB), -999999)
        INTO TROCA
        FROM TGFTAB M, TGFEXC E
        WHERE M.DTVIGOR <= P_DTVIGORAUX
        AND M.CODTAB = P_CODTAB
        AND E.CODPROD = P_CODPROD
        AND E.NUTAB = M.NUTAB;
      END IF;
    END IF; */

    WHILE (P_SEMPRE = 'S')
    LOOP
      BEGIN
         SELECT NVL (PERCENTUAL, 0),
                NVL (CODTABORIG, CODTAB),
                CODTAB,
                UTILIZADECCUSTO
           INTO P_PERCEN,
                P_CODTABORIG,
                P_CODTAB,
                P_UTILZADECCUSTO
        FROM TGFTAB
        WHERE NUTAB   = TROCA;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          TROCA := TROCA;
      END;

      IF P_UTILZADECCUSTO = 'S' THEN
            IF P_CUSTODEC <> 0 THEN
                P_DECVLR := P_CUSTODEC;
            ELSE
                P_DECVLR := 2;
            END IF;
      END IF;

      /* INICIO DESCOMENTAR QUANDO MANDAR PARA O COCAL
      SELECT
       NVL(COUNT(1),0)
      INTO
       P_COUNT
      FROM
       TGFTBG
      WHERE CODTAB = P_CODTAB AND CODGRUPOPROD = P_CODGRUPOPROD;
      IF ((P_COUNT<>0) AND (P_CODTAB <> 0) AND (P_CODGRUPOPROD <> 0)) THEN
          BEGIN
            SELECT
             NVL(PERCENTUAL, -999999)
            INTO
             P_PERCGRUPO
            FROM
             TGFTBG
            WHERE CODTAB = P_CODTAB AND CODGRUPOPROD = P_CODGRUPOPROD;
            P_PERCEN := P_PERCGRUPO;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            P_PERCEN := 0;
          END;
         P_CODGRUPOPROD := 0;
      END IF;
      FIM */
      SELECT COUNT (1)
        INTO P_COUNT
        FROM TGFEXC E
       WHERE E.NUTAB = TROCA
         AND E.CODPROD = P_CODPROD;


      IF (P_COUNT > 0) THEN           /* SE A TABELA TEM EXCEC?O */
        SELECT MAX (E.TIPO), MAX (E.VLRVENDA)
          INTO P_TIPO, P_VALOR
          FROM TGFEXC E
         WHERE E.NUTAB = TROCA
           AND E.CODPROD = P_CODPROD;

        IF (P_TIPO = 'P') AND (P_CODTABORIG <> P_CODTAB) THEN        /* SE A EXC. E POR PERC. E  A TAB. TEM ORIGEM */
          P_MULTIP := P_MULTIP + (P_VALOR / 100.0000);

          SELECT NVL (MAX (M.NUTAB), -999999)
            INTO TROCA
            FROM TGFTAB M, TGFEXC E
           WHERE E.NUTAB = M.NUTAB
             AND M.CODTAB = P_CODTABORIG
             AND E.CODPROD = P_CODPROD
             AND M.DTVIGOR = (  SELECT MAX(M2.DTVIGOR)
                                 FROM TGFTAB M2, TGFEXC E2
                                 WHERE M2.DTVIGOR <= P_DTVIGORAUX 
                                 AND M2.CODTAB = P_CODTABORIG
                                 AND E2.CODPROD = P_CODPROD
                                 AND E2.NUTAB = M2.NUTAB
                             );
                                          
          IF (TROCA = -999999) THEN
            /*MARCELO PARA FICAR IGUAL AO SQL*/
            SELECT NVL (MAX (M.NUTAB), -999999)
              INTO TROCA
              FROM TGFTAB M
             WHERE M.DTVIGOR <= P_DTVIGORAUX
               AND M.CODTAB = P_CODTABORIG;

            IF (TROCA = -999999) THEN
              P_PRECO := 0;
              P_SEMPRE := 'N';
            /* PRINT 'SAIU NO P' */
            END IF;
          END IF;
        ELSE                        /* SENAO A EXECECAO E POR VALOR */
          IF (P_MULTIP <> 0) THEN
            P_PRECO := ROUND (P_VALOR + (P_VALOR * P_MULTIP), P_DECVLR);
          ELSE
            P_PRECO := ROUND (P_VALOR, P_DECVLR);
          END IF;

          P_SEMPRE := 'N';
        /* PRINT 'SAIU NO ACHOU' */
        END IF;
      ELSIF (P_CODTAB = 0) THEN
        /* PRINT 'TAB 0' */
        SELECT NVL (MAX (M.NUTAB), -999999)
            INTO TROCA
            FROM TGFTAB M, TGFEXC E
           WHERE E.NUTAB = M.NUTAB
             AND M.CODTAB = 0
             AND E.CODPROD = P_CODPROD
             AND M.DTVIGOR = (  SELECT MAX(M2.DTVIGOR)
                                 FROM TGFTAB M2, TGFEXC E2
                                 WHERE M2.DTVIGOR <= P_DTVIGORAUX 
                                 AND M2.CODTAB = 0
                                 AND E2.CODPROD = P_CODPROD
                                 AND E2.NUTAB = M2.NUTAB
                             );
        IF (TROCA = -999999) THEN
          P_PRECO := 0;
          P_SEMPRE := 'N';
        END IF;
      ELSIF (P_CODTABORIG = P_CODTAB) THEN
       /* CHEGOU NO ULT. NIVEL E NAO ACHOU EXCECAO */
        P_PRECO := 0;
        P_SEMPRE := 'N';
      /* PRINT 'TAB IGUAIS' */
      ELSE
        P_MULTIP := P_MULTIP + (P_PERCEN / 100.0000);

/*      SELECT NVL (MAX (M.NUTAB), -999999)
          INTO TROCA
          FROM TGFTAB M, TGFEXC E
         WHERE M.DTVIGOR <= P_DTVIGORAUX
           AND M.CODTAB = P_CODTAB
           AND E.CODPROD = P_CODPROD
           AND E.NUTAB = M.NUTAB;

        IF TROCA = -999999 THEN
*/
          SELECT NVL(MAX (M.NUTAB), -999999)
            INTO TROCA
            FROM TGFTAB M
           WHERE M.DTVIGOR <= P_DTVIGORAUX
             AND M.CODTAB = P_CODTABORIG;

          IF (TROCA = -999999) THEN
            P_PRECO := 0;
            P_SEMPRE := 'N';
          ELSE
            SELECT NVL(CODTABORIG, CODTAB), CODTAB
            INTO P_CODTABORIG, P_CODTAB
            FROM TGFTAB
            WHERE NUTAB = TROCA;
            IF (P_CODTABORIG = P_CODTAB) THEN
              
             SELECT NVL (MAX (M.NUTAB), -999999)
                INTO TROCA
                FROM TGFTAB M, TGFEXC E
               WHERE E.NUTAB = M.NUTAB
                 AND M.CODTAB = P_CODTAB
                 AND E.CODPROD = P_CODPROD
                 AND M.DTVIGOR = (  SELECT MAX(M2.DTVIGOR)
                                     FROM TGFTAB M2, TGFEXC E2
                                     WHERE M2.DTVIGOR <= P_DTVIGORAUX 
                                     AND M2.CODTAB = P_CODTAB
                                     AND E2.CODPROD = P_CODPROD
                                     AND E2.NUTAB = M2.NUTAB
                                 );    
              
              IF (TROCA = -999999) THEN
                P_PRECO := 0;
                P_SEMPRE := 'N';
              END IF;
            END IF;
          END IF;
        --OS 792484
        --PRECISA ZERAR O MULTIPLICADOR QUANDO ENCONTRA PRECO EM UMA EXCECAO DO MESMO CODTAB
/*      ELSE
          P_MULTIP := 0;
        END IF;
*/
      END IF;
    END LOOP;

   RETURN P_PRECO;
END;
