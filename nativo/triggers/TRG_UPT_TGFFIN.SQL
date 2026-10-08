/*==============================================================================
  Nome do Script : TRG_UPT_TGFFIN
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 11/03/2026)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 11/03/2026, última alteração em 13/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPT_TGFFIN', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN" 
BEFORE UPDATE ON TGFFIN 
FOR EACH ROW
DECLARE
  P_COUNT            INT := 0;
  P_VLRBAIXAZERO     VARCHAR2 (1);
  P_VLRJURO          FLOAT;
  P_VLRMULTA         FLOAT;
  P_VLRISS           FLOAT;
  P_VLRIRF           FLOAT;
  P_VLRINSS          FLOAT;
  P_OUTROSIMPOSTOS   FLOAT;
  P_ORIGEM           VARCHAR2 (1);
  P_VLRMINAP         TGFTOP.VLRMINAP%TYPE;
  ERRMSG             VARCHAR2(4000);
  ERROR              EXCEPTION;
  P_VALIDAR          BOOLEAN;
  P_SUBSTHISTFIN     CHAR(1);
  P_ATIVO            CHAR(1);
  P_TPAGNFCE         VARCHAR(2);
  P_DESCRTPAGNFCE	 VARCHAR(60);
  P_APELIDO          TGFVEN.APELIDO%TYPE;       
  P_GERANDO_REMESSA  BOOLEAN;    
  P_VLRBASE          FLOAT;
  P_CONSIDERA_TIT_RENEG BOOLEAN;
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  P_GERANDO_REMESSA := VARIAVEIS_PKG.V_GERANDO_REMESSA;
  P_CONSIDERA_TIT_RENEG := VARIAVEIS_PKG.V_CONSIDERAR_TIT_RENEG;  

   /* 
   sincroniza¿¿o de dados
   */
   P_VALIDAR := Fpodevalidar('TGFFIN');

  IF :NEW.ORIGEM <> 'E' AND NVL(:NEW.NUNOTA, 0) <> 0 THEN
    ERRMSG := 'Só é permitido preencher o NUNOTA para financeiros com origem igual a ''E''. ';
    RAISE ERROR;
  END IF;

   IF :NEW.DHBAIXA IS NOT NULL THEN
     :NEW.DHBAIXA := TRUNC(:NEW.DHBAIXA);
   END IF;
   IF  NVL(:NEW.NURENEG, 0) <> NVL (:OLD.NURENEG, 0)  AND :NEW.NURENEG IS NULL AND :NEW.RECDESP = 0 THEN
     RAISE_APPLICATION_ERROR(-20101, 'Título originado a partir de renegociação não pode ter o Nro da Renegociação alterado para NULL. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.');
   END IF;
   
   SELECT COUNT(1) INTO P_COUNT
   FROM TSIPAR
   WHERE (CHAVE = 'SBPARCEIRO' OR CHAVE ='MGE-SUBST');
   
   IF (P_COUNT > 0) OR NOT Tgffin_Pkg.V_VALIDA_FINANCEIRO THEN
      RETURN;
   END IF; 
    
   IF ((:NEW.PROVISAO <> :OLD.PROVISAO)
      OR (:NEW.CODEMP <> :OLD.CODEMP)
      OR (:NEW.NUMNOTA <> :OLD.NUMNOTA)
      OR (:NEW.DTNEG <> :OLD.DTNEG)
      OR (NVL (:NEW.CODTIPOPER, 0) <> NVL (:OLD.CODTIPOPER, 0))
      OR (:NEW.CODPARC <> :OLD.CODPARC)
      OR (:NEW.CODNAT <> :OLD.CODNAT)
      OR (NVL (:NEW.CODCENCUS, 0) <> NVL (:OLD.CODCENCUS, 0))
      OR (NVL (:NEW.HISTORICO, ' ') <> NVL (:OLD.HISTORICO, ' '))
      OR (:NEW.ISSRETIDO <> :OLD.ISSRETIDO)
      OR (:NEW.RECDESP <> :OLD.RECDESP AND NVL(:NEW.NURENEG, 0) = NVL (:OLD.NURENEG, 0))
      OR ((:NEW.NUFIN <> Tgffin_Pkg.V_NUFINRECOMP) AND
          (   (NVL (:NEW.VLRINSS, 0) <> NVL (:OLD.VLRINSS, 0))
           OR (NVL (:NEW.VLRIRF, 0) <> NVL (:OLD.VLRIRF, 0))
           OR (NVL (:NEW.VLRISS, 0) <> NVL (:OLD.VLRISS, 0))
           OR (NVL (:NEW.VLRVENDOR, 0) <> NVL (:OLD.VLRVENDOR, 0)) 
           OR (:NEW.VLRDESDOB <> :OLD.VLRDESDOB)))
     OR (NVL(:NEW.DHBAIXA, :NEW.DTNEG - 100) <> NVL(:OLD.DHBAIXA, :NEW.DTNEG - 100))
     OR (:NEW.VLRBAIXA <> :OLD.VLRBAIXA AND :NEW.DHBAIXA IS NOT NULL)) 
   THEN
      BEGIN 
        SELECT NVL(LOGICO, 'N') INTO P_SUBSTHISTFIN FROM TSIPAR WHERE CHAVE = 'SUBSTHISTFIN';
      EXCEPTION WHEN NO_DATA_FOUND THEN 
        P_SUBSTHISTFIN := 'N';
      END;
    
      SELECT MIN (C.ORIGEM)
      INTO P_ORIGEM
      FROM TCBINT C
      WHERE :NEW.NUFIN = C.NUNICO
      AND C.ORIGEM IN ('F', 'B')    
      AND ((:NEW.PROVISAO <> :OLD.PROVISAO)
            OR (:NEW.CODEMP <> :OLD.CODEMP)
            OR (:NEW.NUMNOTA <> :OLD.NUMNOTA)
            OR (:NEW.DTNEG <> :OLD.DTNEG)
            OR (NVL (:NEW.CODTIPOPER, 0) <> NVL (:OLD.CODTIPOPER, 0))
            OR (:NEW.CODPARC <> :OLD.CODPARC)
            OR (:NEW.CODNAT <> :OLD.CODNAT)
            OR ( (NVL(:NEW.CODCENCUS, 0) <> NVL(:OLD.CODCENCUS, 0)) AND
           EXISTS (SELECT 1 
                 FROM TCBLAN L 
             WHERE L.CODEMP = C.CODEMP 
               AND L.NUMLOTE = C.NUMLOTE 
               AND L.NUMLANC = C.NUMLANC 
               AND L.TIPLANC = C.TIPLANC 
               AND L.REFERENCIA = C.REFERENCIA 
               AND L.CODCENCUS <> 0)
         )
            OR (NVL (:NEW.HISTORICO, ' ') <> NVL (:OLD.HISTORICO, ' ') AND P_SUBSTHISTFIN = 'N')
            OR (:NEW.ISSRETIDO <> :OLD.ISSRETIDO)
            OR (:NEW.RECDESP <> :OLD.RECDESP AND NVL (:NEW.NURENEG, 0) = NVL (:OLD.NURENEG, 0))
            OR ((NVL (:NEW.VLRINSS, 0) <> NVL (:OLD.VLRINSS, 0)) AND (C.ORIGEM = 'B' OR :NEW.DHBAIXA IS NULL))
            OR ((NVL (:NEW.VLRIRF, 0) <> NVL (:OLD.VLRIRF, 0)) AND (C.ORIGEM = 'B' OR :NEW.DHBAIXA IS NULL))
            OR ((NVL (:NEW.VLRISS, 0) <> NVL (:OLD.VLRISS, 0)) AND (C.ORIGEM = 'B' OR :NEW.DHBAIXA IS NULL))
            OR ((NVL (:NEW.VLRVENDOR, 0) <> NVL (:OLD.VLRVENDOR, 0)) AND (C.ORIGEM = 'B' OR :NEW.DHBAIXA IS NULL))
            OR ((:NEW.VLRDESDOB <> :OLD.VLRDESDOB) AND (C.ORIGEM = 'B' OR :NEW.DHBAIXA IS NULL)) 
            OR (C.ORIGEM = 'B' AND NVL(:NEW.DHBAIXA,:NEW.DTNEG-100) <> NVL(:OLD.DHBAIXA,:NEW.DTNEG-100)) 
            OR (C.ORIGEM = 'B' AND :NEW.VLRBAIXA <> :OLD.VLRBAIXA AND :NEW.DHBAIXA IS NOT NULL)
        );
            
      IF (P_ORIGEM = 'F') THEN
 
         SELECT COUNT(1) INTO P_COUNT
         FROM TGFFRE
         WHERE TIPACERTO IN ('C','F')  
         AND (NUFIN = :NEW.NUFIN OR NUFINORIG = :NEW.NUFIN);
         IF (P_COUNT = 0 AND COALESCE(:NEW.TIMCONTRATOLTV, 0) = 0 ) THEN
            ERRMSG := 'Financeiro (Provisão) já foi contabilizado, não pode ser alterado. VlrDesdob: ' || :NEW.VLRDESDOB ||' Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
            RAISE ERROR;
         END IF;
      ELSIF (P_ORIGEM = 'B') THEN
         ERRMSG := 'Baixa do financeiro já foi contabilizada, não pode ser alterada. (0). Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
         RAISE ERROR;
      END IF;
   END IF;
-- ********
 /*
    O titulo original com essas caracteristicas n¿o pode mais sofrer altera¿¿es
    No financeiro ele n¿o aparece, mais nas centrais pode acontecer no caso do frete.
  */
  IF (NOT P_GERANDO_REMESSA) AND ((:NEW.NURENEG IS NOT NULL) AND (:NEW.NURENEG<>0)) AND (:NEW.RECDESP=0 AND :OLD.RECDESP=0) AND (NOT P_CONSIDERA_TIT_RENEG) THEN
    ERRMSG := 'Título foi renegociado, não deve ser alterado. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
  END IF;

  IF UPDATING ('NUMCONTRATO') THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TCSCON
     WHERE NUMCONTRATO = :NEW.NUMCONTRATO
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Contrato: '|| :NEW.NUMCONTRATO ||' não esta ativo. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODPROJ')
     AND :NEW.CODPROJ IS NOT NULL THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TCSPRJ
     WHERE CODPROJ = :NEW.CODPROJ
       AND ATIVO = 'S'
       AND ANALITICO = 'S';

    IF (P_COUNT = 0) THEN
            ERRMSG := 'Projeto '||:NEW.CODPROJ||' não está ativo ou não é analático. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
            RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODCTABCOINT')
     AND :NEW.CODCTABCOINT IS NOT NULL THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TSICTA
     WHERE CODCTABCOINT = :NEW.CODCTABCOINT
       AND ATIVA = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Conta bancária '||:NEW.CODCTABCOINT||' não está ativa. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODEMP') THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFEMP
     WHERE CODEMP = :NEW.CODEMP
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Empresa '||:NEW.CODEMP||' não está ativa. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODEMPBAIXA') AND (:NEW.CODEMP <> :NEW.CODEMPBAIXA) THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFEMP
     WHERE CODEMP = :NEW.CODEMPBAIXA
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Empresa '||:NEW.CODEMPBAIXA||' da baixa não está ativa. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODVEICULO') AND :NEW.CODVEICULO IS NOT NULL AND (:NEW.DHBAIXA IS NULL OR :NEW.CODVEICULO <> :OLD.CODVEICULO) THEN
    Stp_Valida_Veiculo (:NEW.CODVEICULO);
  END IF;

  IF UPDATING ('CODPARC') THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFPAR
     WHERE CODPARC = :NEW.CODPARC
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Parceiro: '|| :NEW.CODPARC ||' não esta ativo. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF (UPDATING ('CODTIPOPER') OR UPDATING ('DHTIPOPER')) THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFTOP
     WHERE CODTIPOPER = :NEW.CODTIPOPER
       AND DHALTER = :NEW.DHTIPOPER
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Tipo de operação não está ativo. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF (UPDATING ('CODTIPOPERBAIXA') OR UPDATING ('DHTIPOPERBAIXA')) THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFTOP T
     WHERE CODTIPOPER = :NEW.CODTIPOPERBAIXA
       AND DHALTER = :NEW.DHTIPOPERBAIXA
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
    ERRMSG := 'Tipo de operação de baixa não está ativo. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODNAT') THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFNAT
     WHERE CODNAT = :NEW.CODNAT
       AND ATIVA = 'S'
       AND ANALITICA = 'S';

    IF (P_COUNT = 0) THEN
            ERRMSG := 'Natureza '||:NEW.CODNAT||' não está ativa ou não é analítico. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
            RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODCENCUS') THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TSICUS
     WHERE CODCENCUS = :NEW.CODCENCUS
       AND ATIVO = 'S'
       AND ANALITICO = 'S';

    IF (P_COUNT = 0) THEN
            ERRMSG := 'Centro de Resultado '||:NEW.CODCENCUS||' não está ativa ou não é analítico. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
            RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODVEND') THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFVEN
     WHERE CODVEND = :NEW.CODVEND
       AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
       SELECT APELIDO INTO P_APELIDO FROM TGFVEN WHERE CODVEND = :NEW.CODVEND;
       ERRMSG := Erros_Pkg.ERRO_VENDEDOR_NAOATIVO || 'Vendedor: '|| :NEW.CODVEND || ' - ' || P_APELIDO || ', Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
       RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING ('CODTIPTIT') THEN
     SELECT ATIVO, TPAGNFCE, DESCRTPAGNFCE
     INTO P_ATIVO, P_TPAGNFCE, P_DESCRTPAGNFCE
     FROM TGFTIT
     WHERE CODTIPTIT = :NEW.CODTIPTIT;
     IF  (P_ATIVO <> 'S') THEN
       ERRMSG := 'Tipo de Título não está ativo. ';
       RAISE ERROR;
     END IF;
     :NEW.TPAGNFCE := P_TPAGNFCE;
	 :NEW.DESCRTPAGNFCE := P_DESCRTPAGNFCE;
  END IF;  
  
  IF (:NEW.NUBCO IS NOT NULL) AND (:NEW.PROVISAO = 'S') THEN
      ERRMSG := 'Provisão não pode atualizar Movimentação Bancária. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
  END IF;

  IF (:NEW.NUBCO IS NOT NULL) AND UPDATING ('NUBCO') THEN
     SELECT COUNT (1)

       INTO P_COUNT
       FROM TGFMBC
      WHERE NUBCO = :NEW.NUBCO;

    IF (P_COUNT = 0) THEN --
      ERRMSG := 'Movimentação  Bancária não encontrada. NUBCO: ' || :NEW.NUBCO ||' Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;
  END IF;

  IF UPDATING('VLRBAIXA') OR UPDATING('CODTIPOPERBAIXA') OR UPDATING('DHBAIXA') OR UPDATING('PROVISAO') THEN
    IF (:NEW.PROVISAO = 'N') AND (:NEW.CODTIPOPERBAIXA = 0) AND ((:NEW.VLRBAIXA <> 0) OR (:NEW.DHBAIXA IS NOT NULL)) THEN
      ERRMSG := 'A TOP da Baixa deve ser informada. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;

    IF (:NEW.CODTIPOPERBAIXA <> 0) AND (:NEW.DHBAIXA IS NULL) THEN
      ERRMSG := 'A TOP da Baixa não pode ser informada. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;

    IF (:NEW.DHBAIXA IS NOT NULL) AND (:NEW.VLRBAIXA = 0) THEN
      SELECT COUNT (1), MIN (LOGICO)
        INTO P_COUNT, P_VLRBAIXAZERO
        FROM TSIPAR
       WHERE CHAVE = 'VLRBAIXAZERO';

      IF (P_COUNT = 0) OR (P_VLRBAIXAZERO <> 'S') THEN
        ERRMSG := 'O Valor da Baixa deve ser informado. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
        RAISE ERROR;
      END IF;
    END IF;
  END IF;

  /* TESTA SE O ANO DIGITADO ¿ V¿LIDO */
  IF UPDATING ('DTVENC')
     OR UPDATING ('DHBAIXA') THEN
    SELECT NVL (INTEIRO, 0)
      INTO P_COUNT
      FROM TSIPAR
     WHERE CHAVE = 'LIMSUPANO';
     
    IF P_COUNT > 100 THEN
      P_COUNT := 100;
    END IF;    
    
    IF (P_COUNT <> 0)
              AND ( ( ( :NEW.DTVENC <> NULL )
              AND ( :NEW.DTVENC > ADD_MONTHS(SYSDATE, 12 * P_COUNT) ) ) )
              OR  ( :NEW.DTNEG > ADD_MONTHS(SYSDATE, 12 * P_COUNT) )
              OR  ( :NEW.DHMOV > ADD_MONTHS(SYSDATE, 12 * P_COUNT) )
              OR  ( ( :NEW.DHBAIXA <> NULL )
              AND ( :NEW.DHBAIXA > ADD_MONTHS(SYSDATE, 12 * P_COUNT) ) 
      ) THEN
      ERRMSG := 'Ano superior ao limite permitido, veja o parâmetro de Limite Superior para Ano. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;

    SELECT NVL (INTEIRO, 0)
      INTO P_COUNT
      FROM TSIPAR
     WHERE CHAVE = 'LIMINFANO';
    
    IF P_COUNT > 100 THEN
      P_COUNT := 100;
    END IF; 

    IF (P_COUNT <> 0)
              AND ( ( ( :NEW.DTVENC <> NULL )
              AND ( :NEW.DTVENC < ADD_MONTHS(SYSDATE, 12 * -P_COUNT) ) ) )
              OR  ( :NEW.DTNEG < ADD_MONTHS(SYSDATE, 12 * -P_COUNT) )
              OR  ( :NEW.DHMOV < ADD_MONTHS(SYSDATE, 12 * -P_COUNT) )
              OR  ( ( :NEW.DHBAIXA <> NULL )
              AND ( :NEW.DHBAIXA < ADD_MONTHS(SYSDATE, 12 * -P_COUNT) ) 
      ) THEN
      ERRMSG := 'Ano inferior ao limite permitido, veja o parâmetro de Limite Inferior para Ano. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;
  END IF;

  /* O NUNOTA DEVE EXISTIR NA CAB, N¿O ¿ FEITO VIA CHAVE ESTRANGEIRA PORQUE A DELE¿¿O ¿ CASCADE */
  IF :NEW.NUNOTA IS NOT NULL AND (NVL(:OLD.NUNOTA,0) <> NVL(:NEW.NUNOTA,0)) THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TGFCAB
    WHERE NUNOTA = :NEW.NUNOTA;
    IF (P_COUNT = 0 ) THEN
      ERRMSG := 'Número da Nota não cadastrado na tabela de notas. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
      RAISE ERROR;
    END IF;
  END IF;

 /* NESTE LUGAR NO SQL TEM UMA VALIDA¿¿O PARA VER SE PARA AQULE PARCEIRO OS TITULOS N¿O
    BAIXADOS COM MARCA¿¿O DE CHEQUE IGUAL A B SOMAM MAIS QUE 0. NO ORACLE ISTO EST¿ IMPLEMENTADO NA
    TRIGGER DE AFTER_UPD */
  IF ((:NEW.TIPMARCCHEQ <> :OLD.TIPMARCCHEQ) OR (:OLD.CODPARC <> :NEW.CODPARC)) AND
     (((:OLD.TIPMARCCHEQ = 'B') AND (:OLD.RECDESP = -1)) OR
      ((:NEW.TIPMARCCHEQ = 'B') AND (:NEW.RECDESP = 1))) THEN
    INSERT INTO TGFFIN_UPD (CODPARC, TIPMARCCHEQ, TIPMARCCHEQ_D, RECDESP_D, RECDESP)
              VALUES (:NEW.CODPARC, :OLD.TIPMARCCHEQ, :NEW.TIPMARCCHEQ, :OLD.RECDESP, :NEW.RECDESP);
  END IF;

  IF (:NEW.RECDESP <> :OLD.RECDESP) AND (:NEW.DHBAIXA IS NOT NULL) THEN
    ERRMSG := 'Esta nota já foi baixada não pode ser alterada de receita para despesa ou vice-versa. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
  END IF;

  IF (:NEW.TIPJURO = '1') THEN
    P_VLRJURO := NVL (:NEW.VLRJURO, 0);
  ELSE
    P_VLRJURO := 0;
  END IF;

  IF (:NEW.TIPMULTA = '1') THEN
    P_VLRMULTA := NVL (:NEW.VLRMULTA, 0);
  ELSE
    P_VLRMULTA := 0;
  END IF;

  IF (:NEW.ISSRETIDO = 'S') THEN
    P_VLRISS := NVL (:NEW.VLRISS, 0);
  ELSE
    P_VLRISS := 0;
  END IF;

  IF (:NEW.IRFRETIDO = 'S') THEN
    P_VLRIRF := NVL (:NEW.VLRIRF, 0);
  ELSE
    P_VLRIRF := 0;
  END IF;

  IF (:NEW.INSSRETIDO = 'S') THEN
    P_VLRINSS := NVL (:NEW.VLRINSS, 0);
  ELSE
    P_VLRINSS := 0;
  END IF;

  BEGIN
    SELECT NVL (SUM (VALOR * TIPIMP), 0)
      INTO P_OUTROSIMPOSTOS
      FROM TGFIMF
     WHERE NUFIN = :NEW.NUFIN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_OUTROSIMPOSTOS := 0;
  END;

    IF (UPDATING ('DHBAIXA')
      OR UPDATING ('VLRBAIXA'))
      AND (:NEW.DHBAIXA IS NOT NULL)
      AND (:NEW.PROVISAO = 'N') THEN
    
    P_VLRBASE := 
    :NEW.VLRDESDOB
    + :NEW.VLRVENDOR
    + :NEW.DESPCART
    + NVL (:NEW.VLRVARCAMBIAL, 0)
    - :NEW.VLRDESC
    - P_VLRIRF
    - P_VLRINSS
    - :NEW.CARTAODESC
    + P_VLRJURO
    + P_VLRMULTA
    - P_VLRISS
    + P_OUTROSIMPOSTOS
    + NVL(:NEW.VLRMULTANEGOC,0) 
    + NVL(:NEW.VLRJURONEGOC,0) 
    - NVL(:NEW.VLRMULTALIB,0) 
    - NVL(:NEW.VLRJUROLIB,0);
    IF P_VLRBASE <> :NEW.VLRBAIXA THEN
    ERRMSG :=
    'Valor da baixa '||TO_CHAR(:NEW.VLRBAIXA, 'FM999,999,999,999,999,990.00')||
    ' diferente do valor calculado '||TO_CHAR(P_VLRBASE,'FM999,999,999,999,999,990.00')||
    ' (VLRDESDOB'||
    CASE WHEN :NEW.VLRVENDOR <> 0 THEN ' + VLRVENDOR' END ||
    CASE WHEN P_VLRJURO <> 0 THEN ' + VLRJURO' END ||
    CASE WHEN P_VLRMULTA <> 0 THEN ' + VLRMULTA' END ||
    CASE WHEN :NEW.DESPCART <> 0 THEN ' + DESPCART' END ||
    CASE WHEN NVL (:NEW.VLRVARCAMBIAL, 0) <> 0 THEN ' + VLRVARCAMBIAL' END ||
    CASE WHEN :NEW.VLRDESC <> 0 THEN ' - VLRDESC' END ||
    CASE WHEN P_VLRISS <> 0 THEN ' - VLRISS' END ||
    CASE WHEN P_VLRIRF <> 0 THEN ' - VLRIRRF' END ||
    CASE WHEN P_VLRINSS <> 0 THEN ' - VLRINSS' END ||
    CASE WHEN :NEW.CARTAODESC <> 0 THEN ' - CARTAODESC' END ||
    CASE WHEN NVL(:NEW.VLRMULTANEGOC,0) <> 0 THEN ' + VLRMULTANEGOC' END ||
    CASE WHEN NVL(:NEW.VLRJURONEGOC,0) <> 0 THEN ' + VLRJURONEGOC' END ||
    CASE WHEN NVL(:NEW.VLRMULTALIB,0) <> 0 THEN ' - VLRMULTALIB' END ||
    CASE WHEN NVL(:NEW.VLRJUROLIB,0) <> 0 THEN ' - VLRJUROLIB' END ||
    CASE WHEN P_OUTROSIMPOSTOS <> 0 THEN ' + OUTROS IMPOSTOS' END ||
    '). Financeiro de Nro único: ' || :NEW.NUFIN;
    RAISE ERROR;
    END IF;
    
    END IF;

  IF :NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL THEN
     DELETE FROM TGFREC WHERE NUFIN = :NEW.NUFIN;
  END IF;

  /*NAO PERMITIR BAIXA DE DESPESA DE VALOR SUPERIOR AO DEFINIDO NO PARAMETRO SE NAO EXISTIR LIBERACAO DO EVENTO 24 NA TGFLIB.*/
  IF (:NEW.RECDESP = -1 AND :NEW.PROVISAO = 'N' AND :OLD.DHBAIXA IS NULL AND :NEW.DHBAIXA IS NOT NULL) THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TGFTOP
     WHERE CODTIPOPER = :NEW.CODTIPOPERBAIXA
       AND DHALTER = :NEW.DHTIPOPERBAIXA
       AND VLRMINAP IS NOT NULL
       AND VLRMINAP > 0
       AND VLRMINAP < :NEW.VLRBAIXA;

    IF P_COUNT <> 0 THEN
      SELECT COUNT (1)
        INTO P_COUNT
        FROM TSILIB
       WHERE TABELA = 'TGFFIN'
         AND VLRLIBERADO >= :NEW.VLRBAIXA
         AND NUCHAVE = :NEW.NUFIN
         AND EVENTO = 24;

      IF P_COUNT = 0 THEN
        ERRMSG := 'Não pode ser baixada por não existir uma liberação ou o valor do desdobramento é superior ao definido na TOP. Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
        RAISE ERROR;
      END IF;
    END IF;
  END IF;


 /*TRATAMENTO PARA ALTERA¿¿O DE T¿TULOS COM SOLICITA¿¿O DE LIBERA¿¿O*/
  IF UPDATING ('VLRDESDOB')  AND :NEW.RECDESP = -1 AND :NEW.PROVISAO = 'N' THEN
    SELECT COUNT (1)
      INTO P_COUNT
      FROM TSILIB
     WHERE NUCHAVE = :NEW.NUFIN
       AND TABELA = 'TGFFIN'
       AND EVENTO = 24;

    IF P_COUNT <> 0 THEN
      UPDATE TSILIB
         SET VLRANTERIOR = VLRATUAL,
             VLRATUAL = :NEW.VLRDESDOB
       WHERE NUCHAVE = :NEW.NUFIN
         AND TABELA = 'TGFFIN'
         AND EVENTO = 24;
    END IF;
  END IF;  

  
  /*VERIFICA SE N¿O EXISTE LIBERA¿¿O PARA TITULOS DIFERENTES DE DESPESA LAN¿ADO NO EVENTO 24.*/
  IF (UPDATING ('RECDESP') OR UPDATING ('PROVISAO')) AND 
     (:NEW.RECDESP = 1 OR :NEW.PROVISAO = 'S') THEN
    DELETE FROM TSILIB
          WHERE TABELA = 'TGFFIN'
            AND NUCHAVE = :NEW.NUFIN
            AND EVENTO = 24;
  END IF;
  
  IF :NEW.DHBAIXA IS NOT NULL AND :NEW.NUCCR IS NOT NULL THEN
    ERRMSG := 'Título de autorização de venda de cartão de crédito não pode ser baixado! Financeiro de Nro único: '|| TO_CHAR(:NEW.NUFIN) ||'.';
    RAISE ERROR;
  END IF;

  RETURN;
   
EXCEPTION
  WHEN OTHERS THEN
    /* 
    Sincroniza¿¿o de dados n¿o faz valida¿¿es
    */
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN" ENABLE;
