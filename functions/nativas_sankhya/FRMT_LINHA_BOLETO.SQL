/*==============================================================================
  Nome do Script : FRMT_LINHA_BOLETO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Quebra um texto em N campos de largura fixa (com padding)
                  para linhas de instrucao do boleto.
  Assinatura     : FRMT_LINHA_BOLETO (TEXTO CLOB, WIDTH NUMBER, PADDING NUMBER,
                  QTDCAMPOS NUMBER) RETURN CLOB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FRMT_LINHA_BOLETO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FRMT_LINHA_BOLETO (TEXTO CLOB, WIDTH NUMBER, PADDING NUMBER, QTDCAMPOS NUMBER)
RETURN CLOB
IS
    V_TEXTO CLOB;
    RESULT CLOB;
    INICIO NUMBER := 1;
    TAMANHO NUMBER;
    CONTADOR NUMBER := 0;
BEGIN
    TAMANHO := WIDTH - (PADDING * 2);
    V_TEXTO := TEXTO;
    V_TEXTO := TRIM(V_TEXTO);
    LOOP
        EXIT WHEN CONTADOR = QTDCAMPOS;
        RESULT := RESULT||LPAD(' ', PADDING)||RPAD(SUBSTR(V_TEXTO, INICIO, TAMANHO), TAMANHO)||LPAD(' ', PADDING);
        CONTADOR := CONTADOR + 1;
        INICIO := INICIO + TAMANHO;
    END LOOP;
    RETURN RESULT;
END;
