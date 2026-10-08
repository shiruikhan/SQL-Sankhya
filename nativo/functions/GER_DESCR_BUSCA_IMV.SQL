/*==============================================================================
  Nome do Script : GER_DESCR_BUSCA_IMV
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta a descricao de busca do imovel (codigo, descricao,
                  bairro, cidade e UF).
  Assinatura     : GER_DESCR_BUSCA_IMV (IMVCODIGO NUMBER, DESCRICAO VARCHAR2,
                  NOMEBAI VARCHAR2, NOMECID VARCHAR2, UF VARCHAR2) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GER_DESCR_BUSCA_IMV', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GER_DESCR_BUSCA_IMV (IMVCODIGO NUMBER, DESCRICAO VARCHAR2, NOMEBAI VARCHAR2, NOMECID VARCHAR2, UF VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN TO_CHAR(IMVCODIGO) || ' - ' || NVL(DESCRICAO, 'Descrição do Imóvel não foi gerada.') || ' - ' || CASE WHEN INSTR (UPPER (DESCRICAO), UPPER (NOMEBAI)) =  0
                                                                                                                    THEN INITCAP (NVL(NOMEBAI, 'Bairro não foi informado.')) || ' - '
                                                                                                                END
          || INITCAP (NVL(NOMECID, 'Cidade não foi informada')) || ' - ' || NVL(UF, 'Unidade Federativa não foi informada');
END;
