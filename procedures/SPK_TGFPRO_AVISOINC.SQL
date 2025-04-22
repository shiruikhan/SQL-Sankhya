create or replace PROCEDURE SPK_TGFPRO_AVISOINC (
    P_TIPOEVENTO  IN INT,
    P_IDSESSAO    IN VARCHAR2,
    P_CODUSU      IN INT
) AS
    -- Constantes para tipos de eventos
    BEFORE_INSERT   CONSTANT INT := 0;
    AFTER_INSERT    CONSTANT INT := 1;
    BEFORE_DELETE   CONSTANT INT := 2;
    AFTER_DELETE    CONSTANT INT := 3;
    BEFORE_UPDATE   CONSTANT INT := 4;
    AFTER_UPDATE    CONSTANT INT := 5;
    BEFORE_COMMIT   CONSTANT INT := 10;

    -- Variáveis para armazenar os dados
    P_CODPROD      NUMBER;
    P_DESCRPROD    VARCHAR2(255);
    P_NOMEUSU      VARCHAR(60);
    P_CODUSUINC    NUMBER;
    P_DTALTER      DATE;
    P_MAXFILA      NUMBER;
    P_CODGRUPOPROD NUMBER;
    P_DESCRGRUPOPROD VARCHAR(100);
    
BEGIN
    IF P_TIPOEVENTO = AFTER_INSERT/* OR P_TIPOEVENTO = AFTER_UPDATE*/ THEN
        -- Captura o código do produto usando a function
        P_CODPROD := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPROD');

        -- Captura dados do produto em uma única consulta
        SELECT DESCRPROD, CODUSU, DTALTER, CODGRUPOPROD
        INTO P_DESCRPROD, P_CODUSUINC, P_DTALTER, P_CODGRUPOPROD
        FROM TGFPRO
        WHERE CODPROD = P_CODPROD;
        
        SELECT NOMEUSU INTO P_NOMEUSU
        FROM TSIUSU
        WHERE CODUSU = P_CODUSU;
        
        SELECT DESCRGRUPOPROD 
        INTO P_DESCRGRUPOPROD 
        FROM TGFGRU 
        WHERE CODGRUPOPROD = P_CODGRUPOPROD;
        
        SELECT MAX(CODFILA)+1 INTO P_MAXFILA FROM TMDFMG;

        -- Chama a segunda procedure com todos os parâmetros
        STP_GRAVA_FILA_BI2(P_MAXFILA,
            'INCLUSÃO DE PRODUTO NOVO',
            '<div>Foi criado o produto ' || P_CODPROD || ' - ' || P_DESCRPROD || ' pertencendo ao grupo ' || P_CODGRUPOPROD || ' - ' || P_DESCRGRUPOPROD || '.</div><div></div>
            <div>O Produto foi criado em ' || P_DTALTER || ' pelo usuário ' || P_NOMEUSU || '.</div>',
            'fiscal@usinaspark.com.br',
            NULL);
        /*STP_GRAVA_FILA_BI2(P_MAXFILA,
            'INCLUSÃO DE PRODUTO NOVO',
            '<div>Foi criado o produto ' || P_CODPROD || ' - ' || P_DESCRPROD || '.</div><div></div>
            <div>O Produto foi criado em ' || P_DTALTER || ' pelo usuário ' || P_NOMEUSU || '.</div>',
            'fiscal02@usinaspark.com.br',
            NULL);*/
        STP_GRAVA_FILA_BI2(P_MAXFILA+1,
            'INCLUSÃO DE PRODUTO NOVO',
            '<div>Foi criado o produto ' || P_CODPROD || ' - ' || P_DESCRPROD || ' pertencendo ao grupo ' || P_CODGRUPOPROD || ' - ' || P_DESCRGRUPOPROD || '.</div><div></div>
            <div>O Produto foi criado em ' || P_DTALTER || ' pelo usuário ' || P_NOMEUSU || '.</div>',
            'desenvolvimento01@usinaspark.com.br',
            NULL);
        /*STP_GRAVA_FILA_BI2(P_MAXFILA,
            'INCLUSÃO DE PRODUTO NOVO',
            '<div>Foi criado o produto ' || P_CODPROD || ' - ' || P_DESCRPROD || ' pertencendo ao grupo ' || P_CODGRUPOPROD || ' - ' || P_DESCRGRUPOPROD || '.</div><div></div>
            <div>O Produto foi criado em ' || P_DTALTER || ' pelo usuário ' || P_NOMEUSU || '.</div>',
            'ti@usinaspark.com.br',
            NULL);*/
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Produto não encontrado: ' || P_CODPROD);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro em SPK_EVENTO_TGFPRO: ' || SQLERRM);
END;