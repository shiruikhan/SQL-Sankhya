/*==============================================================================
  Nome do Script : STP_TIM_INSERT_TIMLDT
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Insere um lançamento (TIMLDT) de uma parcela (NUFIN) no módulo TIM (locação), com recebedor/repassa-para conforme o sinal do valor; chamada pelas triggers de TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 08/12/2021.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_TIM_INSERT_TIMLDT', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_TIM_INSERT_TIMLDT" (
	P_NUFIN INT,
    P_DTINI DATE,
    P_DTFIN DATE,
    P_HISTORICO INT,
    P_VALOR FLOAT,
    P_COMPLEMENTO VARCHAR)
IS
BEGIN
	
	INSERT INTO TIMLDT(
        LDTCODIGO,
        LDTPARCELA,
        LDTRECEBEDE,
        LDTREPASSAPARA,
        LDTDTFIM,
        LDTDTINIC,
        LDTHISTORICO,
        LDTVALOR,
        LDTCOMPLEMENTO,
        LDTDATAMOV,
        LDTDATAINCLUSAO,
        LDTUSUARIO,
        LDTDATAALTERACAO,
        LDTUSUARIOALT
    )
    SELECT (
            SELECT NVL(MAX(NVL(LDTCODIGO,0)),0)+1
            FROM TIMLDT
            WHERE LDTPARCELA = P_NUFIN
        ) LDTCODIGO,
        P_NUFIN LDTPARCELA,
        CASE WHEN P_VALOR < 0 THEN HCBREPASSAPARA ELSE HCBRECEBEDE END LDTRECEBEDE,
        CASE WHEN P_VALOR < 0 THEN HCBRECEBEDE ELSE HCBREPASSAPARA END LDTREPASSAPARA,
        P_DTFIN LDTDTFIM,
        P_DTINI LDTDTINIC,
        HCBCODIGO LDTHISTORICO,
        ABS(P_VALOR) LDTVALOR,
        P_COMPLEMENTO LDTCOMPLEMENTO,
        SYSDATE LDTDATAMOV,
        SYSDATE LDTDATAINCLUSAO,
        STP_GET_CODUSULOGADO() LDTUSUARIO,
        SYSDATE LDTDATAALTERACAO,
        STP_GET_CODUSULOGADO() LDTUSUARIOALT
    FROM TIMHCB
    WHERE HCBCODIGO = P_HISTORICO;

END;
