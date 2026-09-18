/*==============================================================================
  Nome do Script : CAPTURA_DDL_AD_TGFASS
  Tipo           : Script Utilitário (execução única/manual)
  Descrição      : Extrai o DDL completo (CREATE TABLE, constraints, LOBs e
                    cláusulas de storage) da tabela AD_TGFASS via
                    DBMS_METADATA.GET_DDL, para conferência/atualização do
                    arquivo de referência tables/AD_TGFASS.SQL versionado no
                    repositório — mesmo padrão de captura usado para
                    tables/AD_SPKCAE.SQL.
  Tabelas        : AD_TGFASS -- somente leitura (dicionário de dados)
  Dependencias   : DBMS_METADATA (pacote nativo Oracle)
  Uso            : Rodar num client SQL (SQL Developer/Toad) para conferir o
                    DDL vigente da tabela; com o bloco SPOOL habilitado, gera
                    direto o arquivo .SQL a versionar no repositório.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 17/09/2026

  Observações    : - Ajuste o schema ('SPARKPRD') caso a base de destino use
                     outro owner.
                   - SET LONG/LONGCHUNKSIZE elevados são necessários porque
                     GET_DDL retorna CLOB e o client trunca a saída por
                     padrão.
                   - Para gerar o arquivo direto, descomente as linhas SPOOL
                     abaixo e ajuste o caminho de destino.
                   - Script reaproveitável: troque apenas o nome da tabela no
                     GET_DDL para capturar o DDL de qualquer outro objeto
                     AD_* customizado (ex.: AD_SPKCAE, AD_TGSCTF).
==============================================================================*/
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET PAGESIZE 0
SET LINESIZE 1000
SET TRIMSPOOL ON
SET FEEDBACK OFF
SET VERIFY OFF

BEGIN
    -- Sem terminador ';' e com storage/tablespace inline, no mesmo formato
    -- já versionado nos demais arquivos de tables/*.SQL
    DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', FALSE);
    DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE);
    DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', TRUE);
END;
/

-- SPOOL "tables\AD_TGFASS.SQL"

SELECT DBMS_METADATA.GET_DDL('TABLE', 'AD_TGFASS', 'SPARKPRD') AS DDL
  FROM DUAL;

-- SPOOL OFF
