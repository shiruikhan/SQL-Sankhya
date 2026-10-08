/*==============================================================================
  Nome do Script : STP_TIPOVOLPESO_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Alterar as informações de Peso, volume, peso apos a confirmação da nota e for feito carta de correção, pois acontece do fiscal fazer carta de correção a transportadora aprova, e precisa reimprimir as etiquetas fica impedido.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 08/04/2025, última alteração em 26/08/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_TIPOVOLPESO_SPARK" (
                                                     P_CODUSU NUMBER,      
                                                     P_IDSESSAO VARCHAR2,    
                                                     P_QTDLINHAS NUMBER,   
                                                     P_MENSAGEM OUT VARCHAR2 
) AS
    PARAM_P_QTDVOL NUMBER;
    PARAM_P_PESOBRUTO FLOAT;
    PARAM_P_PESOLIQUIDO FLOAT;
    FIELD_NUNOTA NUMBER;
    V_CODGRUP   TSIUSU.CODGRUPO%TYPE; 
    V_TIPMOV    TGFCAB.TIPMOV%TYPE;
    V_STATUSNFE TGFCAB.STATUSNFE%TYPE;
/****************************************************************************
Autor: Lucas Gabriel
Data: 02/04/2025
Objetivo: Alterar as informações de Peso, volume, peso apos a confirmação da nota
e for feito carta de correção, pois acontece do fiscal fazer carta de correção 
a transportadora aprova, e precisa reimprimir as etiquetas fica impedido.
*****************************************************************************/
BEGIN
    PARAM_P_QTDVOL      := ACT_INT_PARAM(P_IDSESSAO, 'P_QTDVOL');
    PARAM_P_PESOBRUTO   := ACT_DEC_PARAM(P_IDSESSAO, 'P_PESOBRUTO');
    PARAM_P_PESOLIQUIDO := ACT_DEC_PARAM(P_IDSESSAO, 'P_PESOLIQUIDO');
    FOR I IN 1..P_QTDLINHAS 
    LOOP                   
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        BEGIN
            SELECT CODGRUPO 
            INTO V_CODGRUP
            FROM TSIUSU 
            WHERE CODUSU = STP_GET_CODUSULOGADO();
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                V_CODGRUP := NULL; 
        END;
        IF V_CODGRUP IS NULL 
            OR V_CODGRUP <> 5
            THEN
			RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                    'Não Foi Possível prosseguir com a alteração Apenas o Fiscal tem Permissão!',
                    'Seu usuario pertence ao grupo ' || V_CODGRUP ||' Apenas o Fiscal tem permissão.',
                    'Procure o Departamento fiscal para mais informações!'
                            ));
        END IF;
        SELECT TIPMOV
              , NVL(STATUSNFE,'X')
        INTO V_TIPMOV
           , V_STATUSNFE
        FROM TGFCAB 
        WHERE NUNOTA = FIELD_NUNOTA;
        IF V_TIPMOV <> 'V' 
            AND V_STATUSNFE = 'A' THEN 
			RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                    'Não Foi Possível prosseguir com a alteração Apenas o Fiscal tem Permissão!',
                    'Seu usuario pertence ao grupo ' || V_CODGRUP ||' Apenas o Fiscal tem permissão.',
                    'Procure o Departamento fiscal para mais informações!'
                            ));
        END IF;
        IF NVL(PARAM_P_QTDVOL,0) > 0 
			THEN 
            UPDATE TGFCAB 
				SET QTDVOL = PARAM_P_QTDVOL 
			WHERE NUNOTA = FIELD_NUNOTA;
        END IF;
        IF NVL(PARAM_P_PESOBRUTO,0) > 0
			THEN 
            UPDATE TGFCAB 
				SET PESOBRUTO = PARAM_P_PESOBRUTO 
			WHERE NUNOTA = FIELD_NUNOTA;
        END IF;
        IF NVL(PARAM_P_PESOLIQUIDO,0) > 0 
			THEN 
            UPDATE TGFCAB
				SET PESO = PARAM_P_PESOLIQUIDO 
			WHERE NUNOTA = FIELD_NUNOTA;
        END IF;
    END LOOP;
    P_MENSAGEM := 'A alteração foi feita com Sucesso não esqueça da carta de correção!';
        EXCEPTION
    WHEN OTHERS 
        THEN
        P_MENSAGEM := 'Erro: ' || SQLERRM;
END;
