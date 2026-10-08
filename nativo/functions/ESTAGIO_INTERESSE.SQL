/*==============================================================================
  Nome do Script : ESTAGIO_INTERESSE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Classifica o imovel para a FAC como Interessados,
                  Disponiveis ou Nao Disponiveis.
  Assinatura     : ESTAGIO_INTERESSE (IMVCODIGO_P NUMBER, FAC_P NUMBER) RETURN
                  CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'ESTAGIO_INTERESSE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION ESTAGIO_INTERESSE (IMVCODIGO_P NUMBER, FAC_P NUMBER)
RETURN CHAR
IS
    COUNT_P NUMBER;
BEGIN
    SELECT COUNT(*) INTO COUNT_P FROM TIMFAC WHERE FACCODIGO = FAC_P;
    IF COUNT_P > 0 THEN
        SELECT COUNT(*) INTO COUNT_P FROM TIMIPR WHERE IPRIMOVEL = IMVCODIGO_P AND IPRFAC = FAC_P;
        IF COUNT_P > 0 THEN
            RETURN 'Interessados';
        END IF;
        RETURN 'Disponíveis';
    ELSE
        RETURN 'Não Disponíveis';
    END IF;
END;
