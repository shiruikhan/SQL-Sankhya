/*==============================================================================
  Nome do Script : SNK_FORMAT_MSG_BLOQ_FEC_CTB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta a mensagem padrao de bloqueio fiscal/contabil, prefixando o texto
                  informado.
  Assinatura     : SNK_FORMAT_MSG_BLOQ_FEC_CTB (P_MENSAGEM VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_FORMAT_MSG_BLOQ_FEC_CTB', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_FORMAT_MSG_BLOQ_FEC_CTB (P_MENSAGEM VARCHAR2)
  RETURN VARCHAR2
 IS
  P_TEXTO CLOB;
BEGIN
  P_TEXTO := 'Atenção: Bloqueio fiscal/contábil.' || P_MENSAGEM;
  RETURN P_TEXTO;
END;
