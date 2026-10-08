/*==============================================================================
  Nome do Script : STP_GERGUIAICMS_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Criar os financeiros automatico apartir do preenchimento da tela de obrigações
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 13/05/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_GERGUIAICMS_SPARK" (
    P_CODUSU    NUMBER,
    P_IDSESSAO  VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM  OUT VARCHAR2
) AS
    FIELD_CODREC VARCHAR2(100);
    FIELD_CODUF  NUMBER;
    FIELD_CODEMP NUMBER;
    FIELD_VALOR  NUMBER;
    FIELD_DTREF  DATE;
    FIELD_DTVCTO DATE;

    V_CODTIPOPER       AD_TGSFINDET.CODTIPOPER%TYPE;
    V_CODNAT           AD_TGSFINDET.CODNAT%TYPE;
    V_CODCENCUS        AD_TGSFINDET.CODCENCUS%TYPE;
    V_CODBCO           AD_TGSFINDET.CODBCO%TYPE;
    V_CODTIPTIT        AD_TGSFINDET.CODTIPTIT%TYPE;
    V_CODCTACTBCOINT   AD_TGSFINDET.CODCTABCOINT%TYPE;
    V_CODREC           AD_TGSFINDET.CODREC%TYPE;
    V_COUNT            INT;
    V_CODPARC          TSIUFS.CODPARCSECRECEST%TYPE;

/*****************************************************************
Autor: Lucas Gabriel 
Data: 13/05/2025
Objetivo: Criar os financeiros automatico apartir do preenchimento 
da tela de obrigações

*****************************************************************/
BEGIN
    FOR I IN 1 .. P_QTDLINHAS 
	LOOP
        FIELD_CODREC := ACT_TXT_FIELD(P_IDSESSAO, I, 'CODREC');
        FIELD_CODEMP := ACT_INT_FIELD(P_IDSESSAO, I, 'CODEMP');
        FIELD_DTREF  := ACT_DTA_FIELD(P_IDSESSAO, I, 'DTREF');
        FIELD_DTVCTO := ACT_DTA_FIELD(P_IDSESSAO, I, 'DTVCTO');
        FIELD_VALOR  := ACT_DEC_FIELD(P_IDSESSAO, I, 'VALOR');
        FIELD_CODUF  := ACT_INT_FIELD(P_IDSESSAO, I, 'CODUF');

        SELECT COUNT(0)
        INTO V_COUNT
        FROM AD_TGSFINDET
        WHERE CODREC = FIELD_CODREC;

        IF V_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20191,
                FC_FORMATAHTML(
                    'Ação não permitida!',
                    'Falta cadastrar as regras de financeiro para o tipo de recolhimento ' || FIELD_CODREC,
                    ''
                )
            );
        END IF;


        SELECT 
			   CODTIPOPER
			 , CODNAT
			 , CODCENCUS
			 , CODBCO
			 , CODTIPTIT
			 , CODCTABCOINT
			 , CODREC
        INTO V_CODTIPOPER
		   , V_CODNAT
		   , V_CODCENCUS
		   , V_CODBCO
		   , V_CODTIPTIT
		   , V_CODCTACTBCOINT
		   , V_CODREC
        FROM AD_TGSFINDET
        WHERE CODREC = FIELD_CODREC;


        SELECT UFS.CODPARCSECRECEST
        INTO V_CODPARC
        FROM TSIUFS UFS
        WHERE UFS.CODUF = FIELD_CODUF;


        INSERT INTO TGFFIN (
						   NUFIN
						 , CODEMP
						 , NUMNOTA
						 , SERIENOTA
						 , DTNEG
						 , DESDOBRAMENTO
						 , DHMOV
						 , DTVENCINIC
						 , DTVENC
						 , CODPARC
						 , CODTIPOPER
						 , DHTIPOPER
						 , CODBCO
						 , CODCTABCOINT
						 , CODNAT
						 , CODCENCUS
						 , CODTIPTIT
						 , HISTORICO
						 , VLRDESDOB
						 , AUTORIZADO
						 , RECDESP
						 , PROVISAO
						 , ORIGEM
						 , DTENTSAI
						 , DTALTER
						 , CODUSU
        ) VALUES (
            (SELECT SNK_GET_NUFIN FROM DUAL),
            FIELD_CODEMP,
            TO_NUMBER(TO_CHAR(SYSDATE, 'MMYYYY')),
            NULL,
            FIELD_DTREF,
            0,
            FIELD_DTREF,
            FIELD_DTVCTO,
            FIELD_DTVCTO,
            V_CODPARC,
            V_CODTIPOPER,
            (SELECT MAX(DHALTER) FROM TGFTOP WHERE CODTIPOPER = V_CODTIPOPER),
            V_CODBCO,
            V_CODCTACTBCOINT,
            V_CODNAT,
            V_CODCENCUS,
            V_CODTIPTIT,
            'Guia de imposto Cód. Recolhimento ' || FIELD_CODREC,
            FIELD_VALOR,
            'S',
            -1,
            'N',
            'F',
            FIELD_DTREF,
            FIELD_DTREF,
            STP_GET_CODUSULOGADO()
        );
    END LOOP;

    P_MENSAGEM := 'Financeiro gerado com sucesso!';
END;
