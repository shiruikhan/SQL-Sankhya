/*==============================================================================
  Nome do Script : TIM_MONTAFORMAREPASSE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Descreve em texto a forma de repasse (percentuais por
                  proprietario e IRB) de um contrato de administracao.
  Assinatura     : TIM_MONTAFORMAREPASSE (ADMNUCONTRATO IN NUMBER) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_MONTAFORMAREPASSE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_MONTAFORMAREPASSE (ADMNUCONTRATO IN NUMBER)
RETURN VARCHAR2
IS
 TEMP_PROP VARCHAR2(1000) := '#PROP# proprietario(a) de #PERPROP#% do Imóvel, receberá #PORCENTO#% do que tem direito em #TIPTITULO#';
 TEMP_SEIRB VARCHAR2(1000) := ' e o restante será repassado da seguinte forma: ';
 MSG_PROP VARCHAR2(1000);
 TEMP_IRB VARCHAR2(1000) := '#PORCENTO#% para #IRB# em #TIPTITULO#';
 MSG_IRB VARCHAR2(1000);
 EXISTS_IRB NUMBER;
 CONTADOR NUMBER := 0;
 RESP VARCHAR2(10000) := '';
BEGIN
    FOR IMP IN (SELECT IMP.IMPCONTRATO, PAR.NOMEPARC, IMP.IMPPERCENTUAL, NVL(TIT.DESCRTIPTIT, '<SEM TIPO DE TÍTULO PARA REPASSE>') AS DESCRTIPTIT, IMP.IMPPROPRIETARIO, IMP.IMPPERCENTUALRETIDO FROM TIMIMP IMP
                  INNER JOIN TGFPAR PAR ON IMP.IMPPROPRIETARIO = PAR.CODPARC
                 LEFT JOIN TGFTIT TIT ON IMP.IMPCODTIPTIT = TIT.CODTIPTIT
                 WHERE IMP.IMPCONTRATO = ADMNUCONTRATO)
    LOOP
        MSG_PROP := REPLACE(TEMP_PROP, '#PROP#', IMP.NOMEPARC);    
        MSG_PROP := REPLACE(MSG_PROP, '#PERPROP#', IMP.IMPPERCENTUAL);
        MSG_PROP := REPLACE(MSG_PROP, '#TIPTITULO#', IMP.DESCRTIPTIT);
        IF IMP.IMPPERCENTUALRETIDO IS NOT NULL THEN
           MSG_PROP := REPLACE(MSG_PROP, '#PORCENTO#', IMP.IMPPERCENTUALRETIDO);
        ELSE
           MSG_PROP := REPLACE(MSG_PROP, '#PORCENTO#', '100');
        END IF;
        RESP := RESP || case when length(trim(RESP)) > 10 then '; ' end || MSG_PROP;
        SELECT COUNT(*) INTO EXISTS_IRB FROM TIMIRB IRB WHERE IRB.IRBCONTRATO = IMP.IMPCONTRATO AND IRB.IRBPROPIMOVEL = IMP.IMPPROPRIETARIO;
        IF EXISTS_IRB > 0 THEN
           RESP := RESP || TEMP_SEIRB;
        END IF;
        FOR IRB IN (SELECT IBB.IRBCONTRATO, IBB.IRBPERCENTUAL, CTT.NOMECONTATO , NVL(TIT.DESCRTIPTIT, '<SEM TIPO DE TÍTULO PARA REPASSE>') AS DESCRTIPTIT FROM TIMIRB IBB
                    INNER JOIN TGFCTT CTT ON CTT.CODPARC = IBB.IRBPROPIMOVEL AND CTT.CODCONTATO = IBB.IRBBENEFICIARIO  
                    LEFT JOIN TGFTIT TIT ON TIT.CODTIPTIT = IBB.IRBCODTIPTIT
                    WHERE IBB.IRBCONTRATO = IMP.IMPCONTRATO AND IBB.IRBPROPIMOVEL = IMP.IMPPROPRIETARIO)
        LOOP
            MSG_IRB := REPLACE(TEMP_IRB, '#IRB#', IRB.NOMECONTATO);
            MSG_IRB := REPLACE(MSG_IRB, '#PORCENTO#', IRB.IRBPERCENTUAL);
            IF CONTADOR = 0 THEN
                  MSG_IRB := REPLACE(MSG_IRB, '#TIPTITULO#', IRB.DESCRTIPTIT);
            ELSE
               MSG_IRB := ', ' || REPLACE(MSG_IRB, '#TIPTITULO#', IRB.DESCRTIPTIT);
            END IF;
            RESP := RESP || MSG_IRB;
            CONTADOR := CONTADOR + 1;
        END LOOP;
    END LOOP;
    RETURN RESP;
END;
