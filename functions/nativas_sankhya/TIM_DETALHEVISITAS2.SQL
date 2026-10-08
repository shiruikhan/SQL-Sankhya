/*==============================================================================
  Nome do Script : TIM_DETALHEVISITAS2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Detalha em texto os motivos de devolucao/desistencia
                  registrados nas visitas ao imovel.
  Assinatura     : TIM_DETALHEVISITAS2 (CODIMOVEL IN NUMBER, dtLibera in Date)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_DETALHEVISITAS2', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_DETALHEVISITAS2 (CODIMOVEL IN NUMBER, dtLibera in Date) 
    RETURN VARCHAR2 
    IS
         --AUTOR: BOSCO 
         RETORNO VARCHAR2(4000);
         INICIO varchar2(50);
         NOVALINHA VarChar2(5);
         OLD_DESISTENCIA CHAR;
         CURSOR RSVIS IS 
                SELECT mtd.MTDDESISTENCIA, mtd.MTDMOTIVO, ECD.IPROBSDEVOLUCAO AS ECDCOMPLEMENTO   
                  FROM TIMFAC ech 
                  INNER JOIN TIMIPR  ecd on ech.FACCODIGO = ecd.IPRFAC 
                  INNER JOIN TIMMTD  mtd ON ecd.IPRMOTIVO = mtd.mtdCodigo 
                 WHERE ECD.IPROBSDEVOLUCAO is not null 
                    and ech.FACLANCAMENTO >= dtLibera 
                    and ECD.IPRIMOVEL = codImovel  
                 ORDER BY mtdDesistencia DESC, mtdMotivo;
BEGIN
    NOVALINHA := Chr(13) || chr(10);
    INICIO := 'Retorno detalhado das visitas.' || NOVALINHA;
    OLD_DESISTENCIA := NULL;
    FOR VIS IN RSVIS LOOP
        if vis.MTDDESISTENCIA is not null then
            IF OLD_DESISTENCIA IS NULL OR VIS.MTDDESISTENCIA != OLD_DESISTENCIA THEN
                IF VIS.MTDDESISTENCIA = 'S' THEN
                    RETORNO := RETORNO||RPAD('Gostou', 14)||TRIM(VIS.ECDCOMPLEMENTO)||NOVALINHA;
                ELSE 
                    RETORNO := RETORNO||RPAD('Não Gostou', 14)||TRIM(VIS.ECDCOMPLEMENTO)||NOVALINHA;
                END IF;
            ELSE
                RETORNO := RETORNO||LPAD(' ', 14)||TRIM(VIS.ECDCOMPLEMENTO)||NOVALINHA;
            END IF;
            -- UPDATE VARIABLES.
            OLD_DESISTENCIA := VIS.MTDDESISTENCIA;
        end if;
    END LOOP;
    if RETORNO = INICIO then
    RETORNO := '';
    end if;
    RETURN RETORNO;
END;
