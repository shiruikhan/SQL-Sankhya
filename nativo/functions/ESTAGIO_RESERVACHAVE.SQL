/*==============================================================================
  Nome do Script : ESTAGIO_RESERVACHAVE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Classifica o imovel quanto a reserva de chave para a FAC
                  (Reservados, Disponiveis, Nao Disponiveis).
  Assinatura     : ESTAGIO_RESERVACHAVE (SEMCHAVES_P VARCHAR2, CODIMOVEL_P
                  NUMBER, ESTAGIO_P CHAR, FAC_P NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'ESTAGIO_RESERVACHAVE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION ESTAGIO_RESERVACHAVE (SEMCHAVES_P VARCHAR2, CODIMOVEL_P NUMBER, ESTAGIO_P CHAR, FAC_P NUMBER)
RETURN VARCHAR2
IS
    COUNT_V NUMBER;
    N_DISPONIVEL VARCHAR2(20) := 'Não Disponíveis';
    RESERVADA VARCHAR2(20) := 'Reservados';
    RESERVAR VARCHAR2(20) := 'Disponíveis';
BEGIN
    IF ESTAGIO_P = 'DI' THEN
        SELECT COUNT(*) INTO COUNT_V FROM TIMIPR WHERE IPRIMOVEL = CODIMOVEL_P AND IPRFAC = FAC_P AND IPRMOTIVO IS NOT NULL;
        IF COUNT_V > 0 THEN
            RETURN N_DISPONIVEL; -- Devolvida.
        ELSE 
            SELECT COUNT(*) INTO COUNT_V FROM TIMFAC WHERE FACCODIGO = FAC_P;
            IF COUNT_V > 0 THEN
                RETURN RESERVAR; -- Não Reservada.
            END IF;
            RETURN N_DISPONIVEL; -- Não Disponivel.
        END IF;
    ELSIF ESTAGIO_P = 'CA' THEN
        SELECT COUNT(*) INTO COUNT_V FROM TIMIPR WHERE IPRFAC = FAC_P AND IPRIMOVEL = CODIMOVEL_P AND IPRCHAVE = 'S';
        IF COUNT_V > 0 THEN
            RETURN RESERVADA; -- Reservada para esta FAC.
        END IF;
        RETURN N_DISPONIVEL; -- Reserva para outra FAC.
    ELSE
        RETURN N_DISPONIVEL; -- Não Disponível.
    END IF;
    RETURN RESERVAR;
END;
