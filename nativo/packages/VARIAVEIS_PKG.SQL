/*==============================================================================
  Nome do Script : VARIAVEIS_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Pacote central de variaveis de sessao do Sankhya: parametros
                  de custo (por empresa/local/controle), flags de
                  funcionalidades usadas pelo cliente (V_UTILIZA_*), controle
                  de rastreio, validacoes de estoque, WMS, checkout e o record
                  TYPERECCUSTO.
  Uso            : Lida pelas funcoes STP_GET_*, GET_CONTROLE_CUSTO,
                  GET_EMPRESA_CUSTO, GET_LOCAL_CUSTO,
                  GET_ADIARATUALIZACAOESTOQUE, GET_VALEST_BLOQWMS_FAT e
                  GET_TEM_RASTSTULTENTRADA, alem de triggers e procedures
                  nativas.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'VARIAVEIS_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE VARIAVEIS_PKG 
AS
	V_DHCARGAPKG                  DATE      := NULL;
	V_DHPARAMETROS                DATE      := SYSDATE;
	V_TEMPRODUTOSEMFAMILIA        CHAR( 1 ) := 'N';
	V_INSERCAOAUTOMATICA          CHAR( 1 ) := 'N';
	V_CONSIDERARIMPOSTORETIDONOTA CHAR( 1 ) := 'N';
	V_CUSTOPOREMPRESA             CHAR( 1 ) := 'N';
	V_CUSTOPORLOCAL               CHAR( 1 ) := 'N';
	V_CUSTOPORCONTROLE            CHAR( 1 ) := 'N';
	V_SOMACUSTOMEDIODASMPSNOPA    CHAR( 1 ) := 'N';
	V_FATURANDOESTOQUECONFERIDO   CHAR(1)   := 'N';
	V_DECIMAISPARACUSTO           INTEGER   := 2;
	V_EMPRESADESMEMBRARCUSTO      INTEGER   := 0;
	V_DTINICIOCONTEST             DATE      := ADD_MONTHS( SYSDATE, -1200 );
	V_ATUALIZANDO                 BOOLEAN   := FALSE;
	V_TEMOTICAS                   CHAR( 1 ) := 'N';
	CODBARRA_EST                  CHAR( 3 ) := ' ';
	V_ALTERADO_PELA_CAB           BOOLEAN   := FALSE;
	V_VALEST_BLOQWMS_FAT          CHAR( 1 ) := 'S';
	V_DTLIMALTERCUSTO             DATE      := TRUNC( SYSDATE - 90 );
	V_DLT_REG_COMPENSACAO         BOOLEAN   := FALSE;
	V_DLT_MOV_COMISSAO            BOOLEAN   := TRUE;
	V_DLT_PROD                    BOOLEAN   := FALSE;
	V_GERANDO_REMESSA             BOOLEAN   := FALSE;
	V_IPINACOMPRASEMDESCONTO      CHAR( 1 ) := 'N';
	V_IPINAVENDASEMDESCONTO       CHAR( 1 ) := 'N';
	V_SOMARSERVICONOTA            CHAR( 1 ) := 'S';
	V_CODOBSGARANTIDO             INTEGER;
	V_CODIMPGARANTIDO             INTEGER;
	V_TEMFUNRURAL                 CHAR( 1 );
	V_TOPSREQCON                  VARCHAR2( 400 );
	V_NATVA                       INTEGER;
	V_NATVT                       INTEGER;
	V_FORMULAFRETE_IRF            VARCHAR2( 4000 );
	V_VLRMINRETENCAOIR            FLOAT;
	V_TOPPISREDAQUIS              INTEGER;
	V_CODTIPTIT_TROCA             NUMBER(5) := NULL;
	V_DESMEMBRANDOBEM             CHAR(1)   := 'N';
	V_USACODVOLPARC               CHAR( 1 ) := 'N';
	V_PROCPROVFIN_BATCH           INTEGER   := 0;
	V_FATURARESTWMS               CHAR(1);
	V_DISTJDCONF                  BOOLEAN       := FALSE;
	V_RATDESCSEMIMP               CHAR(1)       := 'N';
	V_EDITMPSOMAEXT               CHAR(1)       := 'N';
	V_TIPCANCELATEF               CHAR(1)       := NULL;
	V_PROCESSO_ATUAL_CUSTO        VARCHAR2(255) := NULL;
	V_ADIARATUALIZACAOORIGEM      CHAR(1)       := 'N';
	V_ADIARATUALIZACAOESTOQUE     CHAR(1)       := 'N';
	-- VERIFICA SE O CLIENTE UTILIZA DETERMINADA FUNCIONALIDADE
	V_UTILIZA_CERTIFIC          CHAR( 1 );
	V_UTILIZA_TGAMOV            CHAR( 1 );
	V_UTILIZA_GRANDES_CARGAS    CHAR( 1 );
	V_UTILIZA_ESTTERC           CHAR( 1 );
	V_UTILIZA_METAS             CHAR( 1 );
	V_UTILIZA_FLEX              CHAR( 1 );
	V_UTILIZA_INDENIZ           CHAR( 1 );
	V_UTILIZA_TGFCPP            CHAR( 1 );
	V_UTILIZA_RASTEST           CHAR( 1 );
	V_UTILIZA_TCIBEM            CHAR( 1 );
	V_UTILIZA_VERIFCORTE        CHAR( 1 );
	V_UTILIZA_DAV               CHAR( 1 );
	V_UTILIZA_TRANSG            CHAR( 1 );
	V_UTILIZA_HCRUZADAS         CHAR( 1 );
	V_USA_CONTA_BAIXA           CHAR( 1 );
	V_IGNORE_OCORR_BAIXA        BOOLEAN := FALSE;
	V_IGNORE_VALID_EST_MOV      CHAR(1);
	V_NUNOTA_LIV_PERMITEALTERAR NUMBER( 10 );
	V_DBHASHCODE                VARCHAR2( 400 );
	V_RASTSTULTENTRA            CHAR(1) := '*'; -- Indefinido
	V_UTILDOCNAOFISCALRASTST    CHAR(1) := 'N';
	V_AJUSIMPRASTSTCOMULTENT    CHAR(1) := 'N';
	V_REPROCESSANDODRCST        CHAR(1) := 'N';
	V_TIMUTILIZAIMOB            BOOLEAN := FALSE;
	V_VALIDA_FORNECEDOR         BOOLEAN := TRUE;
	V_SNK_CHECKOUT_CALC_IMP     BOOLEAN := FALSE;
	V_USA_RECURSIVO			    BOOLEAN := FALSE;
	V_SBPRODUTO                 BOOLEAN := FALSE;
	RASTESTVALIMP				CHAR(1);
	V_HABALIQESPICMS            BOOLEAN := FALSE;
	V_IGNORA_VINCULO_FUNC		CHAR(1)   := 'N';
	V_CONSIDERAR_TIT_RENEG      BOOLEAN := FALSE;
	V_VALIDA_EST_RESERVAR       BOOLEAN := FALSE;
	V_VALIDA_EST_GRUPROD        BOOLEAN := FALSE;
	V_WMSDESCONESTBLQ			BOOLEAN := FALSE;
	V_SUBESTDOCAWMS				BOOLEAN := FALSE;
	
TYPE TYPERECCUSTO
IS
	RECORD
	(
		NUNOTA        NUMBER( 10 )
		, SEQUENCIA   NUMBER( 5 )
		, DTBASE      DATE
		, CODEMP      NUMBER( 5 )
		, CODPROD     NUMBER( 10 )
		, CODLOCAL    NUMBER( 10 )
		, CONTROLE    VARCHAR( 50 )
		, CUSTOEXPLOD CHAR( 1 ) );
END;
