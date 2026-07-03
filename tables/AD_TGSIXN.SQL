  CREATE TABLE "SPARKPRD"."AD_TGSIXN" 
   (	"NUCONF" NUMBER(10,0) NOT NULL ENABLE, 
	"CODUSUINC" NUMBER(10,0), 
	"DTINI" DATE, 
	"DTFIM" DATE, 
	"OBSERVACAO" CLOB, 
	"STATUS" VARCHAR2(10), 
	"NUARQUIVO" NUMBER(10,0), 
	 CONSTRAINT "PK_AD_TGSIXN" PRIMARY KEY ("NUCONF")
  USING INDEX  ENABLE, 
	 CONSTRAINT "AD_FK_D7F4619F248178E0A862E" FOREIGN KEY ("CODUSUINC")
	  REFERENCES "SPARKPRD"."TSIUSU" ("CODUSU") ENABLE, 
	 CONSTRAINT "AD_FK_0D2D719F248C35C5EE87E" FOREIGN KEY ("NUARQUIVO")
	  REFERENCES "SPARKPRD"."TGFIXN" ("NUARQUIVO") ENABLE
   ) ;

-- Apontamento de conferencia e unico por arquivo: garante a nivel de banco que
-- nao existam dois registros para o mesmo NUARQUIVO, mesmo sob concorrencia
-- (o check aplicativo em STP_APONTACONFERENCIA_SPARK sozinho nao cobre a
-- corrida entre duas sessoes clicando o botao ao mesmo tempo).
ALTER TABLE AD_TGSIXN ADD CONSTRAINT UQ_AD_TGSIXN_NUARQUIVO UNIQUE (NUARQUIVO);

-- Conferente: funcionario que assume o apontamento apos a abertura (fluxo:
-- inicia apontamento -> informa conferente). Preenchido via UPDATE
-- posterior ao INSERT; nao e bloqueado pela trigger de imutabilidade
-- porque so pode ser setado uma vez (NULL -> valor), nunca reatribuido.
-- A PK de TFPFUN e composta (CODEMP, CODFUNC) -- ver PK_TFPFUN -- por isso
-- CODEMP entra aqui tambem, fixo em 1 (unica empresa neste cenario), so
-- para permitir a FK composta; a trigger TRG_INC_AD_TGSIXN_SPARK garante
-- o valor 1 no INSERT independente do DEFAULT.
ALTER TABLE AD_TGSIXN ADD (CODEMP NUMBER(10,0) DEFAULT 1 NOT NULL);
ALTER TABLE AD_TGSIXN ADD (CODFUNC NUMBER(10,0));
ALTER TABLE AD_TGSIXN ADD CONSTRAINT FK_AD_TGSIXN_CODFUNC FOREIGN KEY (CODEMP, CODFUNC) REFERENCES TFPFUN (CODEMP, CODFUNC);

-- Numero da nota fiscal, copiado de TGFIXN.NUMNOTA no momento do INSERT
-- (busca pelo NUARQUIVO selecionado na tela). Ver TRG_INC_AD_TGSIXN_SPARK.
ALTER TABLE AD_TGSIXN ADD (NUMNOTA NUMBER(10,0));

-- Data de emissao da NF, copiada de TGFIXN.DHEMISS no momento do INSERT
-- (mesma busca por NUARQUIVO usada para NUMNOTA). Ver TRG_INC_AD_TGSIXN_SPARK.
ALTER TABLE AD_TGSIXN ADD (DHEMISS DATE);

-- Duracao da conferencia em dias uteis (DTINI ate DTFIM, ou ate SYSDATE
-- enquanto ainda aberto), desconsiderando sabado/domingo. Valor inicial
-- gravado por TRG_INC_AD_TGSIXN_SPARK no INSERT; enquanto o apontamento
-- estiver aberto, quem mantem atualizado e STP_ATUALIZADTFIM_TGSIXN_SPARK
-- (job agendado) -- sem trigger de UPDATE para isso, pois nada mais toca
-- a linha entre uma execucao e outra do job.
ALTER TABLE AD_TGSIXN ADD (DURACAO_DIAS_UTEIS NUMBER(10,0));
