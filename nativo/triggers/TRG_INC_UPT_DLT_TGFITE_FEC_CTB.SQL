/*==============================================================================
  Nome do Script : TRG_INC_UPT_DLT_TGFITE_FEC_CTB
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 21/09/2026 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE OR DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 21/09/2026, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_INC_UPT_DLT_TGFITE_FEC_CTB', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_DLT_TGFITE_FEC_CTB" 
BEFORE INSERT OR UPDATE OR DELETE ON TGFITE
FOR EACH ROW 
DECLARE 
  ERRMSG                 VARCHAR2(4000); 
  ERROR                  EXCEPTION; 
  P_TIPO_ITEM              CHAR(1); 
  P_DATA                  DATE; 
  P_CODEMP                  NUMBER; 
  P_TIPOACAO             CHAR(1); 
  P_NUCHAVE              NUMBER; 
  P_STATUS_NOTA         CHAR(1);
  P_NOTA_LIBERADA       BOOLEAN; 

  P_STATUS_NOTA_LIBERADA CHAR(1) := 'L'; 
  P_MOVIMENTACAO_ESTOQUE CHAR(2) := '01'; 
  P_MOVIMENTACAO_CUSTO_NOTA CHAR(2) := '02'; 

  P_IS_CALC_CUSTO CHAR(1);
  P_TIPO_ITEM_ESTOQUE_ENTRADA CHAR(1) := 'E'; 
  P_TIPO_ITEM_ESTOQUE_SAIDA CHAR(1) := 'S'; 
  P_TIPO_ITEM_ESTOQUE_SEM_TIPO CHAR(1) := 'N'; 

  P_TIPO_ACAO_INCLUSAO CHAR(1) := 'I'; 
  P_TIPO_ACAO_ALTERACAO CHAR(1) := 'A'; 
  P_TIPO_ACAO_DELECAO CHAR(1) := 'D'; 
  P_TIPO_ACAO_MSG              VARCHAR(40);
  
  P_COUNT   NUMBER(5);
BEGIN 

	IF NOT STP_GET_UTILIZAFECHACTB() THEN
      RETURN;
	END IF;
   
   /* QDO SUBSTITUINDO PRODUTO, N¿O VALIDAR ESTOQUE */
   IF (VARIAVEIS_PKG.V_SBPRODUTO) THEN
     RETURN;
   END IF;
   
   SELECT COUNT( 1 )
   INTO   P_COUNT
   FROM   TSIPAR
   WHERE  CHAVE = 'SBPRODUTO';

   IF ( P_COUNT <> 0 ) THEN
      RETURN;
   END IF;
/**
 * Campos que n¿o ser¿o bloqueados
 * OBSERVACAO,COMPLDESC,QTDCONFERIDA,QTDENTREGUE,QTDFIXADA,QTDFORMULA,QTDPECA,QTDVOL,QTDWMS,PENDENTE,RESERVA, DTALTER, CODUSU
 * Campos Adicionais 'AD_' 
 *  
 */
 
  IF DELETING THEN
    P_TIPOACAO := P_TIPO_ACAO_DELECAO;
    P_NUCHAVE := :OLD.NUNOTA;
    P_TIPO_ACAO_MSG := '(Dele¿¿o)';
  ELSE
    P_NUCHAVE := :NEW.NUNOTA;
    P_TIPOACAO := P_TIPO_ACAO_INCLUSAO;
    P_TIPO_ACAO_MSG := '(Inser¿¿o)';
  END IF;

  BEGIN
    SELECT 
      C.STATUSNOTA,
      C.CODEMP,
      CASE 
        WHEN (TPO.ATUALFIN = -1         -- Financeiro = Despesa
			  OR (TPO.ATUALFIN = 0 AND (TPO.TIPMOV = 'L' OR TPO.ATUALEST = 'E' OR TPO.ATUALESTMP = 1)))     -- Devolu¿¿o de Requisi¿¿o
            AND (TPO.TIPATUALFIN = 'I'     -- Atualiza¿¿o do Financeiro = Incluir
              OR TPO.ATUALEST = 'E'         -- Atualiza¿¿o do Estoque = Entrar 
              OR TPO.ATUALESTMP = 1        -- Atualiza¿¿o do Estoque MP = Entrar
              OR TPO.ATUALBEM <> 'N'        -- Atualiza¿¿o do Bem <> N¿o atualiza
              OR TPO.ATUALCOM <> 'N'        -- Comiss¿o <> N¿o atualiza
              OR TPO.ATUALCTB = 'S'        -- Atualiza Contabilidade = 'Sim'
              OR TPO.ATUALLIVFIS IN ('E', 'A')     -- Atualiza¿¿o de Livro ICMS  = Livro de Entrada
              OR TPO.ATUALLIVISS = 'E'    -- Atualiza¿¿o livros de ISS = Aquisi¿¿o
              OR TPO.ATUALESTTERC <> 'N') THEN P_TIPO_ITEM_ESTOQUE_ENTRADA 
         WHEN (TPO.ATUALFIN = 1        -- Financeiro = Receita
			  OR (TPO.ATUALFIN = 0 AND (TPO.TIPMOV = 'Q' OR TPO.ATUALEST = 'B' OR TPO.ATUALESTMP = -1)))    -- Requisi¿¿o
              AND (TPO.TIPATUALFIN = 'I'     -- Atualiza¿¿o do Financeiro = Incluir
              OR TPO.ATUALEST = 'B'         -- Atualiza¿¿o do Estoque = Baixar 
              OR TPO.ATUALESTMP = -1        -- Atualiza¿¿o do Estoque MP = Baixar
              OR TPO.ATUALBEM <> 'N'        -- Atualiza¿¿o do Bem <> N¿o atualiza
              OR TPO.ATUALCOM <> 'N'        -- Comiss¿o <> N¿o atualiza
              OR TPO.ATUALCTB = 'S'        -- Atualiza Contabilidade = 'Sim'
              OR TPO.ATUALLIVFIS IN ('S', 'A')     -- Atualiza¿¿o de Livro ICMS  = Livro de Sa¿da
              OR TPO.ATUALLIVISS = 'S'    -- Atualiza¿¿o livros de ISS = Presta¿¿o
              OR TPO.ATUALESTTERC <> 'N'    -- Estoque com/de Terceiros <> N¿o controla
              OR TPO.NFE = 'N'            -- NFE = Normal
              OR TPO.NFSE = 'N') THEN P_TIPO_ITEM_ESTOQUE_SAIDA
         ELSE 'N' 
      END,
      CASE 
        WHEN TPO.PRECIFICA <> 'N' THEN 'S'
        ELSE 'N' 
      END AS IS_CALC_CUSTO,
      CASE 
        WHEN (TPO.ATUALFIN = -1         -- Financeiro = Despesa
			  OR (TPO.ATUALFIN = 0 AND (TPO.TIPMOV = 'L' OR TPO.ATUALEST = 'E' OR TPO.ATUALESTMP = 1)))     -- Devolu¿¿o de Requisi¿¿o
            AND (TPO.TIPATUALFIN = 'I'     -- Atualiza¿¿o do Financeiro = Incluir
              OR TPO.ATUALEST = 'E'         -- Atualiza¿¿o do Estoque = Entrar 
              OR TPO.ATUALESTMP = 1        -- Atualiza¿¿o do Estoque MP = Entrar
              OR TPO.ATUALBEM <> 'N'        -- Atualiza¿¿o do Bem <> N¿o atualiza
              OR TPO.ATUALCOM <> 'N'        -- Comiss¿o <> N¿o atualiza
              OR TPO.ATUALCTB = 'S'        -- Atualiza Contabilidade = 'Sim'
              OR TPO.ATUALLIVFIS IN ('E', 'A')     -- Atualiza¿¿o de Livro ICMS  = Livro de Entrada
              OR TPO.ATUALLIVISS = 'E'    -- Atualiza¿¿o livros de ISS = Aquisi¿¿o
              OR TPO.ATUALESTTERC <> 'N') THEN NVL(C.DTENTSAIINFO, NVL(C.DTENTSAI, C.DTNEG))
         WHEN (TPO.ATUALFIN = 1        -- Financeiro = Receita
			  OR (TPO.ATUALFIN = 0 AND (TPO.TIPMOV = 'Q' OR TPO.ATUALEST = 'B' OR TPO.ATUALESTMP = -1)))    -- Requisi¿¿o
              AND (TPO.TIPATUALFIN = 'I'     -- Atualiza¿¿o do Financeiro = Incluir
              OR TPO.ATUALEST = 'B'         -- Atualiza¿¿o do Estoque = Baixar 
              OR TPO.ATUALESTMP = -1        -- Atualiza¿¿o do Estoque MP = Baixar
              OR TPO.ATUALBEM <> 'N'        -- Atualiza¿¿o do Bem <> N¿o atualiza
              OR TPO.ATUALCOM <> 'N'        -- Comiss¿o <> N¿o atualiza
              OR TPO.ATUALCTB = 'S'        -- Atualiza Contabilidade = 'Sim'
              OR TPO.ATUALLIVFIS IN ('S', 'A')     -- Atualiza¿¿o de Livro ICMS  = Livro de Sa¿da
              OR TPO.ATUALLIVISS = 'S'    -- Atualiza¿¿o livros de ISS = Presta¿¿o
              OR TPO.ATUALESTTERC <> 'N'    -- Estoque com/de Terceiros <> N¿o controla
              OR TPO.NFE = 'N'            -- NFE = Normal
              OR TPO.NFSE = 'N') THEN NVL(C.DTENTSAIINFO, C.DTNEG)
         ELSE SYSDATE 
      END
    INTO P_STATUS_NOTA, P_CODEMP,  P_TIPO_ITEM, P_IS_CALC_CUSTO, P_DATA 
    FROM TGFCAB C INNER JOIN TGFTOP TPO ON (C.CODTIPOPER = TPO.CODTIPOPER AND C.DHTIPOPER = TPO.DHALTER)
    WHERE C.NUNOTA = P_NUCHAVE
    AND C.STATUSNOTA = P_STATUS_NOTA_LIBERADA;
  EXCEPTION WHEN NO_DATA_FOUND THEN
      P_STATUS_NOTA := 'P';
  END;

  IF P_STATUS_NOTA = P_STATUS_NOTA_LIBERADA THEN     
 
    IF P_TIPO_ITEM <> P_TIPO_ITEM_ESTOQUE_SEM_TIPO THEN 

        IF UPDATING THEN
            IF ( NVL(:OLD.NUTAB, 0) <> NVL(:NEW.NUTAB, 0)
            OR :OLD.NUNOTA <> :NEW.NUNOTA
            OR :OLD.SEQUENCIA <> :NEW.SEQUENCIA
            OR :OLD.CODEMP <> :NEW.CODEMP
            OR :OLD.CODPROD <> :NEW.CODPROD
            OR :OLD.CODLOCALORIG <> :NEW.CODLOCALORIG
            OR :OLD.CONTROLE <> :NEW.CONTROLE
            OR :OLD.USOPROD <> :NEW.USOPROD
            OR :OLD.CODCFO <> :NEW.CODCFO
            OR :OLD.QTDNEG <> :NEW.QTDNEG
            OR :OLD.VLRUNIT <> :NEW.VLRUNIT
            OR :OLD.VLRTOT <> :NEW.VLRTOT
            OR :OLD.VLRCUS <> :NEW.VLRCUS
            OR :OLD.BASEIPI <> :NEW.BASEIPI
            OR :OLD.VLRIPI <> :NEW.VLRIPI
            OR :OLD.BASEICMS <> :NEW.BASEICMS
            OR :OLD.VLRICMS <> :NEW.VLRICMS
            OR :OLD.VLRDESC <> :NEW.VLRDESC
            OR :OLD.BASESUBSTIT <> :NEW.BASESUBSTIT
            OR :OLD.VLRSUBST <> :NEW.VLRSUBST
            OR NVL(:OLD.ALIQICMS, 0) <> NVL(:NEW.ALIQICMS, 0)
            OR NVL(:OLD.ALIQIPI, 0) <> NVL(:NEW.ALIQIPI, 0)
            OR :OLD.CODVOL <> :NEW.CODVOL
            OR NVL(:OLD.CODTRIB, 0) <> NVL(:NEW.CODTRIB, 0)
            OR :OLD.ATUALESTOQUE <> :NEW.ATUALESTOQUE
            OR :OLD.STATUSNOTA <> :NEW.STATUSNOTA
            OR NVL(:OLD.CODOBSPADRAO, 0) <> NVL(:NEW.CODOBSPADRAO, 0)
            OR :OLD.CODVEND <> :NEW.CODVEND
            OR :OLD.CODEXEC <> :NEW.CODEXEC
            OR :OLD.FATURAR <> :NEW.FATURAR
            OR :OLD.VLRREPRED <> :NEW.VLRREPRED
            OR :OLD.VLRDESCBONIF <> :NEW.VLRDESCBONIF
            OR :OLD.PERCDESC <> :NEW.PERCDESC
            OR NVL(:OLD.M3, 0) <> NVL(:NEW.M3, 0)
            OR NVL(:OLD.ALIQICMSRED, 0) <> NVL(:NEW.ALIQICMSRED, 0)
            OR NVL(:OLD.CODPARCEXEC, 0) <> NVL(:NEW.CODPARCEXEC, 0)
            OR NVL(:OLD.CUSTO, 0) <> NVL(:NEW.CUSTO, 0)
            OR NVL(:OLD.BASESUBSTSEMRED, 0) <> NVL(:NEW.BASESUBSTSEMRED, 0)
            OR NVL(:OLD.SOLCOMPRA, ' ') <> NVL(:NEW.SOLCOMPRA, ' ')
            OR NVL(:OLD.CODTRIBISS, 0) <> NVL(:NEW.CODTRIBISS, 0)
            OR NVL(:OLD.CODCFPS, 0) <> NVL(:NEW.CODCFPS, 0)
            OR NVL(:OLD.ALIQISS, 0) <> NVL(:NEW.ALIQISS, 0)
            OR NVL(:OLD.ATUALESTTERC, ' ') <> NVL(:NEW.ATUALESTTERC, ' ')
            OR NVL(:OLD.PERCDESCBONIF, 0) <> NVL(:NEW.PERCDESCBONIF, 0)
            OR NVL(:OLD.TERCEIROS, ' ') <> NVL(:NEW.TERCEIROS, ' ')
            OR NVL(:OLD.ENDIMAGEM, ' ') <> NVL(:NEW.ENDIMAGEM, ' ')
            OR NVL(:OLD.ALTURA, 0) <> NVL(:NEW.ALTURA, 0)
            OR NVL(:OLD.LARGURA, 0) <> NVL(:NEW.LARGURA, 0)
            OR NVL(:OLD.ESPESSURA, 0) <> NVL(:NEW.ESPESSURA, 0)
            OR NVL(:OLD.CODCAV, 0) <> NVL(:NEW.CODCAV, 0)
            OR NVL(:OLD.CODPROC, 0) <> NVL(:NEW.CODPROC, 0)
            OR NVL(:OLD.PRECOBASE, 0) <> NVL(:NEW.PRECOBASE, 0)
            OR NVL(:OLD.VLRACRESCDESC, 0) <> NVL(:NEW.VLRACRESCDESC, 0)
            OR NVL(:OLD.VLRRETENCAO, 0) <> NVL(:NEW.VLRRETENCAO, 0)
            OR NVL(:OLD.CSTIPI, 0) <> NVL(:NEW.CSTIPI, 0)
            OR NVL(:OLD.PERCCOM, 0) <> NVL(:NEW.PERCCOM, 0)
            OR NVL(:OLD.VLRCOM, 0) <> NVL(:NEW.VLRCOM, 0)
            OR NVL(:OLD.ALTPRECO, ' ') <> NVL(:NEW.ALTPRECO, ' ')
            OR NVL(:OLD.PERCCOMGER, 0) <> NVL(:NEW.PERCCOMGER, 0)
            OR NVL(:OLD.VLRCOMGER, 0) <> NVL(:NEW.VLRCOMGER, 0)
            OR NVL(:OLD.BASICMMOD, 0) <> NVL(:NEW.BASICMMOD, 0)
            OR NVL(:OLD.BASICMSTMOD, 0) <> NVL(:NEW.BASICMSTMOD, 0)
            OR NVL(:OLD.QTDFAT, 0) <> NVL(:NEW.QTDFAT, 0)
            OR NVL(:OLD.BASESTUFDEST, 0) <> NVL(:NEW.BASESTUFDEST, 0)
            OR NVL(:OLD.VLRICMSUFDEST, 0) <> NVL(:NEW.VLRICMSUFDEST, 0)
            OR NVL(:OLD.BASESTANT, 0) <> NVL(:NEW.BASESTANT, 0)
            OR NVL(:OLD.GRUPOTRANSG, 0) <> NVL(:NEW.GRUPOTRANSG, 0)
            OR NVL(:OLD.PRODUTONFE, ' ') <> NVL(:NEW.PRODUTONFE, ' ')
            OR NVL(:OLD.GTINNFE, ' ') <> NVL(:NEW.GTINNFE, ' ')
            OR NVL(:OLD.GTINTRIBNFE, ' ') <> NVL(:NEW.GTINTRIBNFE, ' ')
            OR NVL(:OLD.CODPROMO, 0) <> NVL(:NEW.CODPROMO, 0)
            OR NVL(:OLD.VLRPROMO, 0) <> NVL(:NEW.VLRPROMO, 0)
            OR NVL(:OLD.VLRLIQPROM, 0) <> NVL(:NEW.VLRLIQPROM, 0)
            OR NVL(:OLD.PRECOBASEQTD, 0) <> NVL(:NEW.PRECOBASEQTD, 0)
            OR NVL(:OLD.RETDATACRITICA, ' ') <> NVL(:NEW.RETDATACRITICA, ' ')
            OR NVL(:OLD.PERCPUREZA, 0) <> NVL(:NEW.PERCPUREZA, 0)
            OR NVL(:OLD.PERCGERMIN, 0) <> NVL(:NEW.PERCGERMIN, 0)
            OR NVL(:OLD.NUPROMOCAO, 0) <> NVL(:NEW.NUPROMOCAO, 0)
            OR NVL(:OLD.PERCDESCPROM, 0) <> NVL(:NEW.PERCDESCPROM, 0)
            OR NVL(:OLD.VLRPTOPUREZA, 0) <> NVL(:NEW.VLRPTOPUREZA, 0)
            OR NVL(:OLD.CODANTECIPST, ' ') <> NVL(:NEW.CODANTECIPST, ' ')
            OR NVL(:OLD.NUMPEDIDO, 0) <> NVL(:NEW.NUMPEDIDO, 0)
            OR NVL(:OLD.SEQPEDIDO, 0) <> NVL(:NEW.SEQPEDIDO, 0)
            OR NVL(:OLD.CSOSN, 0) <> NVL(:NEW.CSOSN, 0)
            OR NVL(:OLD.STATUSLOTE, ' ') <> NVL(:NEW.STATUSLOTE, ' ')
            OR NVL(:OLD.SERIEINICIAL, ' ') <> NVL(:NEW.SERIEINICIAL, ' ')
            OR NVL(:OLD.SERIEFINAL, ' ') <> NVL(:NEW.SERIEFINAL, ' ')
            OR NVL(:OLD.DTINICIO, SYSDATE) <> NVL(:NEW.DTINICIO, SYSDATE)
            OR NVL(:OLD.HRINICIO, 0) <> NVL(:NEW.HRINICIO, 0)
            OR NVL(:OLD.HRFIM, 0) <> NVL(:NEW.HRFIM, 0)
            OR NVL(:OLD.VLRUNITDOLAR, 0) <> NVL(:NEW.VLRUNITDOLAR, 0)
            OR NVL(:OLD.PESO, 0) <> NVL(:NEW.PESO, 0)
            OR NVL(:OLD.MD5PAF, ' ') <> NVL(:NEW.MD5PAF, ' ')
            OR NVL(:OLD.BASEISS, 0) <> NVL(:NEW.BASEISS, 0)
            OR NVL(:OLD.VLRISS, 0) <> NVL(:NEW.VLRISS, 0)
            OR NVL(:OLD.CODTPA, 0) <> NVL(:NEW.CODTPA, 0)
            OR NVL(:OLD.NUMPEDIDO2, ' ') <> NVL(:NEW.NUMPEDIDO2, ' ')
            OR NVL(:OLD.SEQPEDIDO2, ' ') <> NVL(:NEW.SEQPEDIDO2, ' ')
            OR NVL(:OLD.VLRTROCA, 0) <> NVL(:NEW.VLRTROCA, 0)
            OR NVL(:OLD.VARIACAOFCP, 0) <> NVL(:NEW.VARIACAOFCP, 0)
            OR NVL(:OLD.DTFIM, SYSDATE) <> NVL(:NEW.DTFIM, SYSDATE)
            OR NVL(:OLD.TEMPOGASTO, 0) <> NVL(:NEW.TEMPOGASTO, 0)
            OR NVL(:OLD.DESVIOPADRAO, 0) <> NVL(:NEW.DESVIOPADRAO, 0)
            OR NVL(:OLD.PERCTROCA, 0) <> NVL(:NEW.PERCTROCA, 0)
            OR NVL(:OLD.PERCDESCDIGITADO, 0) <> NVL(:NEW.PERCDESCDIGITADO, 0)
            OR NVL(:OLD.PERCDESCTGFDES, 0) <> NVL(:NEW.PERCDESCTGFDES, 0)
            OR NVL(:OLD.SEQUENCIAFISCAL, 0) <> NVL(:NEW.SEQUENCIAFISCAL, 0)
            OR NVL(:OLD.VLRDESCDIGITADO, 0) <> NVL(:NEW.VLRDESCDIGITADO, 0)
            OR NVL(:OLD.PERCVC, 0) <> NVL(:NEW.PERCVC, 0)
            OR NVL(:OLD.CODMOTDESONERAICMS, 0) <> NVL(:NEW.CODMOTDESONERAICMS, 0)
            OR NVL(:OLD.CODMOTDESONERAST, 0) <> NVL(:NEW.CODMOTDESONERAST, 0)
            OR NVL(:OLD.CODETAPA, 0) <> NVL(:NEW.CODETAPA, 0)
            OR NVL(:OLD.VARIACAO, 0) <> NVL(:NEW.VARIACAO, 0)
            OR NVL(:OLD.ATUALESTINDIVIDUAL, ' ') <> NVL(:NEW.ATUALESTINDIVIDUAL, ' ')
            OR NVL(:OLD.VLRSTEXTRANOTA, 0) <> NVL(:NEW.VLRSTEXTRANOTA, 0)
            OR NVL(:OLD.ULOCETPAESTIND, ' ') <> NVL(:NEW.ULOCETPAESTIND, ' ')
            OR NVL(:OLD.CODLOCALTERC, 0) <> NVL(:NEW.CODLOCALTERC, 0)
            OR NVL(:OLD.ORIGPROD, ' ') <> NVL(:NEW.ORIGPROD, ' ')
            OR NVL(:OLD.PERCDESCBASE, 0) <> NVL(:NEW.PERCDESCBASE, 0)
            OR NVL(:OLD.NRSERIERESERVA, ' ') <> NVL(:NEW.NRSERIERESERVA, ' ')
            OR NVL(:OLD.VLRUNITLOC, 0) <> NVL(:NEW.VLRUNITLOC, 0)
            OR NVL(:OLD.VLRICMSANT, 0) <> NVL(:NEW.VLRICMSANT, 0)
            OR NVL(:OLD.BASESUBSTITANT, 0) <> NVL(:NEW.BASESUBSTITANT, 0)
            OR NVL(:OLD.VLRSUBSTANT, 0) <> NVL(:NEW.VLRSUBSTANT, 0)
            OR NVL(:OLD.NUMEROOS, 0) <> NVL(:NEW.NUMEROOS, 0)
            OR NVL(:OLD.CANCELADO, ' ') <> NVL(:NEW.CANCELADO, ' ')
            OR NVL(:OLD.GRUPOFAT, 0) <> NVL(:NEW.GRUPOFAT, 0)
            OR NVL(:OLD.NUMCONTRATO, 0) <> NVL(:NEW.NUMCONTRATO, 0)
            OR NVL(:OLD.IDALIQICMS, 0) <> NVL(:NEW.IDALIQICMS, 0)
            OR :OLD.VLRUNITMOE <> :NEW.VLRUNITMOE
            OR :OLD.VLRDESCMOE <> :NEW.VLRDESCMOE
            OR :OLD.VLRTOTMOE <> :NEW.VLRTOTMOE
            OR NVL(:OLD.CODVOLPARC, ' ') <> NVL(:NEW.CODVOLPARC, ' ')
            OR NVL(:OLD.CODENQIPI, 0) <> NVL(:NEW.CODENQIPI, 0)
            OR NVL(:OLD.CODESPECST, 0) <> NVL(:NEW.CODESPECST, 0)
            OR NVL(:OLD.VLRDESCRAT, 0) <> NVL(:NEW.VLRDESCRAT, 0)
            OR NVL(:OLD.NUFOP, 0) <> NVL(:NEW.NUFOP, 0)
            OR :OLD.BASESUBSTITUNITORIG <> :NEW.BASESUBSTITUNITORIG
            OR :OLD.VLRSUBSTUNITORIG <> :NEW.VLRSUBSTUNITORIG
            OR NVL(:OLD.CODAGREGACAO, ' ') <> NVL(:NEW.CODAGREGACAO, ' ')
            OR :OLD.INDESCALA <> :NEW.INDESCALA
            OR NVL(:OLD.CNPJFABRICANTE, ' ') <> NVL(:NEW.CNPJFABRICANTE, ' ')
            OR NVL(:OLD.CODBENEFNAUF, ' ') <> NVL(:NEW.CODBENEFNAUF, ' ')
            OR NVL(:OLD.BASESTFCPINTANT, 0) <> NVL(:NEW.BASESTFCPINTANT, 0)
            OR NVL(:OLD.PERCSTFCPINTANT, 0) <> NVL(:NEW.PERCSTFCPINTANT, 0)
            OR NVL(:OLD.VLRSTFCPINTANT, 0) <> NVL(:NEW.VLRSTFCPINTANT, 0)
            OR NVL(:OLD.GERAPRODUCAO, ' ') <> NVL(:NEW.GERAPRODUCAO, ' ')
            OR NVL(:OLD.PERCDESCFORNECEDOR, 0) <> NVL(:NEW.PERCDESCFORNECEDOR, 0)
            OR NVL(:OLD.ORIGEMBUSCA, ' ') <> NVL(:NEW.ORIGEMBUSCA, ' ')
            OR NVL(:OLD.PRODUTOPESQUISADO, 0) <> NVL(:NEW.PRODUTOPESQUISADO, 0)
            OR NVL(:OLD.ALIQSTEXTRANOTA, 0) <> NVL(:NEW.ALIQSTEXTRANOTA, 0)
            OR NVL(:OLD.BASESTEXTRANOTA, 0) <> NVL(:NEW.BASESTEXTRANOTA, 0)
            OR NVL(:OLD.QTDTRIBEXPORT, 0) <> NVL(:NEW.QTDTRIBEXPORT, 0)
            ) THEN 
                P_TIPOACAO := P_TIPO_ACAO_ALTERACAO;
                P_TIPO_ACAO_MSG := '(Altera¿¿o)';
          
                 IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO,P_MOVIMENTACAO_ESTOQUE, NULL, P_TIPO_ITEM, P_NUCHAVE) THEN
                    ERRMSG := ERRMSG || ' para movimenta¿¿o de estoque.';
                    RAISE ERROR;
                 END IF;

                 IF P_IS_CALC_CUSTO = 'S' AND SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_NOTA, NULL, P_TIPO_ITEM, P_NUCHAVE) THEN             
                    ERRMSG := ERRMSG || ' para movimenta¿¿o de c¿lculo de custo.';
                    RAISE ERROR;
                  END IF;
            END IF;
        ELSE 
            P_TIPO_ACAO_MSG := '(Inclus¿o/Altera¿¿o)';
            IF SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO,P_MOVIMENTACAO_ESTOQUE, NULL, P_TIPO_ITEM, P_NUCHAVE) THEN
                ERRMSG := ERRMSG || ' para movimenta¿¿o de estoque.';
                RAISE ERROR;
            END IF;

            IF P_IS_CALC_CUSTO = 'S' AND SNK_BLOQUEIO_FECHAMENTO (P_CODEMP, P_DATA, P_TIPOACAO, P_MOVIMENTACAO_CUSTO_NOTA, NULL, P_TIPO_ITEM, P_NUCHAVE) THEN             
                ERRMSG := ERRMSG || ' para movimenta¿¿o de calculo de custo.';
                RAISE ERROR;
            END IF;  
        END IF;
    END IF;
END IF;

RETURN;

EXCEPTION WHEN ERROR THEN
  ERRMSG := SNK_FORMAT_MSG_BLOQ_FEC_CTB(ERRMSG ||  ' O m¿s ' || TO_CHAR(P_DATA,'MM/YYYY')  || ' est¿ fechado. N¿o ¿ poss¿vel realizar movimenta¿¿o referente ao item da nota ' || CAST(NVL(P_NUCHAVE, '') AS VARCHAR) || ' em per¿odos fechados pela contabilidade sem uma libera¿¿o de ' || P_TIPO_ACAO_MSG || ' para empresa ' || CAST(NVL(P_CODEMP, '') AS VARCHAR) || '.');

  RAISE_APPLICATION_ERROR(-20101, ERRMSG);
  RETURN;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_DLT_TGFITE_FEC_CTB" ENABLE;
