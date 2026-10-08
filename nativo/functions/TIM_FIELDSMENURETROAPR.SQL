/*==============================================================================
  Nome do Script : TIM_FIELDSMENURETROAPR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna pipelined (chave/valor) com o rotulo e o valor de
                  observacao de visitas da ultima administracao do imovel.
  Assinatura     : TIM_FIELDSMENURETROAPR (P_IMVCODIGO NUMBER) RETURN
                  TYPESET_KEYVALUE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_FIELDSMENURETROAPR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_FIELDSMENURETROAPR (P_IMVCODIGO NUMBER)
RETURN TYPESET_KEYVALUE PIPELINED
IS
    CURSOR CUR IS
    SELECT 
        ADMOBSVISITAS
    FROM TIMIMV
    INNER JOIN TIMADM ON ADMIMOVEL = IMVCODIGO
        AND IMVULTADM = ADMNUCONTRATO
    WHERE IMVCODIGO = P_IMVCODIGO;
BEGIN
    FOR C IN CUR
    LOOP
        PIPE ROW(TYPE_KEYVALUE(FIELD_LABEL('TIMADM','ADMOBSVISITAS'),C.ADMOBSVISITAS));
    END LOOP;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            RETURN;
END;
