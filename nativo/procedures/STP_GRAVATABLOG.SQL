/*==============================================================================
  Nome do Script : STP_GRAVATABLOG
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Grava em TSILGT o log de alteração de um campo (tabela, chave, ação, valor novo/antigo) com usuário do sistema, usuário de banco, máquina, IP e programa da sessão.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('PROCEDURE', 'STP_GRAVATABLOG', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_GRAVATABLOG" 
(
  P_TABELA IN VARCHAR2,
  P_CHAVE  IN VARCHAR2,
  P_CAMPO  IN VARCHAR2, 
  P_CODUSU IN INT,
  P_ACAO   IN VARCHAR2,
  P_NEW    IN VARCHAR2, 
  P_OLD    IN VARCHAR2
)
AS
BEGIN 
DECLARE     V_USUARIO_BANCO VARCHAR2(60);
            V_USUARIO_REDE  VARCHAR2(60);
            V_NOMEMAQUINA   VARCHAR2(60);
            V_IPMAQUINA     VARCHAR2(60);
            V_PROGRAMA      VARCHAR2(60);
            V_USUARIOSIS    VARCHAR2(60);
            V_CODUSUAUX     VARCHAR2(100);
BEGIN 
    IF (P_CODUSU IS NULL) OR (P_CODUSU = 0) OR (P_TABELA = 'TSIUSU') THEN
      V_CODUSUAUX := Tsiusu_Log_Pkg.V_CODUSULOG;
      V_USUARIOSIS := Tsiusu_Log_Pkg.V_NOMEUSULOG;
    ELSE
      V_CODUSUAUX := P_CODUSU;
      BEGIN
        SELECT USU.NOMEUSU INTO V_USUARIOSIS FROM TSIUSU USU WHERE USU.CODUSU = V_CODUSUAUX;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        V_USUARIOSIS := 'USUARIO NAO LOCALIZADO NA TSIUSU ' || V_CODUSUAUX;
      END;
    END IF;
  
    SELECT   
        USERNAME, 
        OSUSER,
        MACHINE,
        sys_context('USERENV','IP_ADDRESS'),
        PROGRAM
    INTO
        V_USUARIO_BANCO,
        V_USUARIO_REDE,
        V_NOMEMAQUINA,
        V_IPMAQUINA,
        V_PROGRAMA
    FROM
        V$SESSION
    WHERE  AUDSID = (SELECT USERENV('SESSIONID') FROM DUAL)
        AND ROWNUM = 1;

    INSERT INTO TSILGT
    (
        NOMETAB,
        DHACAO,
        ACAO,
        USUBANCO,
        USUREDE,
        NOMMAQUINA,
        IPMAQUINA,
        PROGRAMA,
        USUARIOSIS,
        CHAVE,
        CAMPO,
        NOVO,
        VELHO
    )
    VALUES
    (
        P_TABELA,
        SYSDATE,
        P_ACAO,
        V_USUARIO_BANCO,
        V_USUARIO_REDE,
        V_NOMEMAQUINA,
        V_IPMAQUINA,
        V_PROGRAMA,
        V_USUARIOSIS,
        P_CHAVE,
        P_CAMPO,
        P_NEW,
        P_OLD   
    );
END;

END;
