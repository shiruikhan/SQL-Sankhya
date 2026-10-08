/*==============================================================================
  Nome do Script : SNK_ORIGEM_DESTINO_ENTREGA
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Resolve cidade e UF de origem, destino e entrega da nota a partir de empresa, parceiros, remetente e contato de entrega, conforme o tipo de movimento; usa STP_END_ICMS.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 19/09/2025, última alteração em 29/05/2026.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'SNK_ORIGEM_DESTINO_ENTREGA', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."SNK_ORIGEM_DESTINO_ENTREGA" (P_NUNOTA           NUMBER,
                                                       P_CODEMP           NUMBER,
                                                       P_CODEMPNEG        NUMBER,
                                                       P_CODPARC          NUMBER,
                                                       P_CODPARCDEST      NUMBER,
                                                       P_CODPARCREMETENTE NUMBER,
                                                       P_CODCONTATOENT    NUMBER,
                                                       P_TIPMOV           VARCHAR2,
                                                       P_CODCIDORIG       OUT NUMBER,
                                                       P_CODCIDDEST       OUT NUMBER,
                                                       P_CODCIDENTREGA    OUT NUMBER,
                                                       P_CODUFORIG        OUT NUMBER,
                                                       P_CODUFDEST        OUT NUMBER,
                                                       P_CODUFENTREGA     OUT NUMBER)
AS
    P_CODEMP_UTIL           NUMBER(10);
    P_CODEMPNEG_UTIL        NUMBER(10);
    P_CODPARC_UTIL          NUMBER(10);
    P_CODPARCDEST_UTIL      NUMBER(10);
    P_CODPARCREMETENTE_UTIL NUMBER(10);
    P_CODCONTATOENT_UTIL    NUMBER(10);
	P_ENDICMS               NUMBER(10);
 	P_COUNT     NUMBER(5);
    P_TIPMOV_UTIL           TGFCAB.TIPMOV%TYPE;
    P_TIPMOV_TEST           TGFCAB.TIPMOV%TYPE;
    P_VENDA                 TGFCAB.TIPMOV%TYPE := 'V'; 
    P_COMPRA                TGFCAB.TIPMOV%TYPE := 'C';
    P_PEDIDO_COMPRA         TGFCAB.TIPMOV%TYPE := 'O';
    P_DEVOLUCAO_COMPRA      TGFCAB.TIPMOV%TYPE := 'E';
    P_REQUISICAO            TGFCAB.TIPMOV%TYPE := 'Q';
    P_TRANSFERENCIA         TGFCAB.TIPMOV%TYPE := 'T';
    P_CIDEMP                TSIEMP.CODCID%TYPE;
    P_CIDPARC               TGFPAR.CODCID%TYPE;
    P_PARCEIRO              TGFPAR.CODPARC%TYPE;
    P_EMPRESA               TSIEMP.CODEMP%TYPE;
    P_CIDENTREGA            TGFPAR.CODCID%TYPE := 0;
BEGIN
    /*
    >> Operação com consumidor final:
      - se UFEntrega = 0 então é pela UFOrigem e UFDestino
      - se UFEntrega <> 0 então é pela UFOrigem e UFEntrega
    >> Operação com contribuinte: 
      - É pela UFOrigem e UFDestino independente da UFEntrega 
    */
    P_CODCIDENTREGA := 0;
    P_CODUFENTREGA := 0;
    /*DEFINE FONTE DOS DADOS*/
    IF NVL(P_NUNOTA, 0) = 0 THEN
        P_CODEMP_UTIL           := NVL(P_CODEMP, 0);
        P_CODEMPNEG_UTIL        := NVL(P_CODEMPNEG, 0);
        P_CODPARC_UTIL          := NVL(P_CODPARC, 0);
        P_CODPARCDEST_UTIL      := NVL(P_CODPARCDEST, 0);
        P_CODPARCREMETENTE_UTIL := NVL(P_CODPARCREMETENTE, 0);
        P_CODCONTATOENT_UTIL    := NVL(P_CODCONTATOENT, 0);
        P_TIPMOV_UTIL           := NVL(P_TIPMOV, ' ');
    ELSE
        BEGIN
            SELECT CODEMP, NVL(CODEMPNEGOC, 0), CODPARC, NVL(CODPARCDEST, 0), NVL(CODPARCREMETENTE, 0), TIPMOV, NVL(CODCONTATOENTREGA, 0)
              INTO P_CODEMP_UTIL, P_CODEMPNEG_UTIL, P_CODPARC_UTIL, P_CODPARCDEST_UTIL, P_CODPARCREMETENTE_UTIL, P_TIPMOV_UTIL, P_CODCONTATOENT_UTIL
            FROM TGFCAB
            WHERE NUNOTA = P_NUNOTA;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101, 'Nota de número único '||P_NUNOTA||' não encontrada!');
        END;
    END IF;
    IF ( P_CODPARCDEST_UTIL <> 0 AND P_CODPARCREMETENTE_UTIL <> 0 AND 
         (P_TIPMOV_UTIL = P_VENDA OR (P_TIPMOV_UTIL = P_COMPRA AND GET_TSIPAR_LOGICO('USAPARREMDESCPA') = 'S'))
       ) THEN
       STP_END_ICMS(P_CODPARCREMETENTE_UTIL, 0, P_CODCIDORIG, P_CIDEMP);
       STP_END_ICMS(P_CODPARCDEST_UTIL, 0, P_CODCIDDEST, P_CIDEMP);
    ELSIF P_TIPMOV_UTIL = P_REQUISICAO THEN
       STP_END_ICMS(0, P_CODEMP_UTIL, P_CIDPARC, P_CODCIDORIG);
       P_CODCIDDEST := P_CODCIDORIG;
    ELSE
        IF P_CODPARCDEST_UTIL <> 0 AND P_TIPMOV_UTIL = P_TRANSFERENCIA THEN
            P_PARCEIRO := P_CODPARCDEST_UTIL;
            P_TIPMOV_TEST := P_VENDA;
        ELSE
            P_PARCEIRO := P_CODPARC_UTIL;
            P_TIPMOV_TEST := P_TIPMOV_UTIL;
        END IF;
        
        IF P_CODEMPNEG_UTIL <> 0 THEN
            P_EMPRESA := P_CODEMPNEG_UTIL;
        ELSE
            P_EMPRESA := P_CODEMP_UTIL;
        END IF;
        
        STP_END_ICMS(P_PARCEIRO, P_CODEMP_UTIL, P_CIDPARC, P_CIDEMP);
        
        IF P_TIPMOV_TEST IN (P_COMPRA, P_DEVOLUCAO_COMPRA, P_PEDIDO_COMPRA) THEN
            IF P_TIPMOV_TEST = P_DEVOLUCAO_COMPRA AND EHSIMPLESNACIONAL(P_CODEMP_UTIL) THEN
                P_CODCIDORIG := P_CIDEMP;
                P_CODCIDDEST := P_CIDPARC;
            ELSE
                P_CODCIDORIG := P_CIDPARC; 
                P_CODCIDDEST := P_CIDEMP;
            END IF;
        ELSIF P_TIPMOV_TEST = P_TRANSFERENCIA THEN
            P_CODCIDORIG := P_CIDEMP;
            IF P_CODEMP_UTIL = P_EMPRESA THEN
                P_CODCIDDEST := P_CODCIDORIG;
            ELSE
                STP_END_ICMS(0, P_EMPRESA, P_CIDPARC, P_CIDEMP);
                P_CODCIDDEST := P_CIDEMP;
            END IF;
        ELSE
            P_CODCIDORIG := P_CIDEMP; 
            P_CODCIDDEST := P_CIDPARC;
        END IF;
        
        IF (P_CODCONTATOENT_UTIL <> 0) THEN
				SELECT COUNT(1) INTO P_COUNT FROM TSIPAR WHERE CHAVE = 'ENDICMS';
				P_ENDICMS := GET_TSIPAR_INTEIRO('ENDICMS');
        	IF( P_ENDICMS = 0 AND P_COUNT > 0) THEN
        		P_CODCIDENTREGA := P_CIDPARC; 
        		P_CODUFENTREGA := GETUF(P_CIDPARC);
        	ELSE
	            P_CODCIDENTREGA := GETCIDCONTATO(P_CODPARC_UTIL, P_CODCONTATOENT_UTIL);
    	        P_CODUFENTREGA := GETUF(P_CODCIDENTREGA);	
        	END IF;
        END IF;
        
    END IF;

    P_CODUFORIG := GETUF(P_CODCIDORIG);
    P_CODUFDEST := GETUF(P_CODCIDDEST);   
END;
