CREATE OR REPLACE PROCEDURE STP_AVISOINC_SPARK (
    P_TIPOEVENTO IN INT,
    P_IDSESSAO   IN VARCHAR2,
    P_CODUSU     IN INT
) AS
/*==============================================================================
  Nome do Script : STP_AVISOINC_SPARK
  Descrição      : Dispara e-mails aos grupos de desenvolvimento e fiscal
                   informando a inclusão de um novo produto.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/02/2025
  Última Revisão : 06/06/2025
  Melhorias      : Inclusão do email fiscal01@usinaspark.com.br para receber os 
  e-mails de inclusão de produtos.
==============================================================================*/

    -- Constantes de evento
    c_AFTER_INSERT CONSTANT INT := 1;

    -- Variáveis de controle
    v_CodProd         NUMBER;
    v_DescrProd       VARCHAR2(255);
    v_NomeUsu         VARCHAR2(60);
    v_CodUsuInc       NUMBER;
    v_DtAlter         DATE;
    v_CodGrupoProd    NUMBER;
    v_DescrGrupoProd  VARCHAR2(100);
    v_MaxFila         NUMBER;

    -- Variáveis auxiliares
    v_Mensagem        CLOB;
    v_Assunto         VARCHAR2(100) := 'INCLUSÃO DE PRODUTO NOVO';

BEGIN
    IF P_TIPOEVENTO = c_AFTER_INSERT THEN

        -- Obtém o código do produto da sessão
        v_CodProd := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPROD');

        -- Busca os dados do produto
        SELECT 
            DESCRPROD, CODUSU, DTALTER, CODGRUPOPROD
        INTO 
            v_DescrProd, v_CodUsuInc, v_DtAlter, v_CodGrupoProd
        FROM 
            TGFPRO
        WHERE 
            CODPROD = v_CodProd;

        -- Busca o nome do usuário responsável
        SELECT 
            NOMEUSU
        INTO 
            v_NomeUsu
        FROM 
            TSIUSU
        WHERE 
            CODUSU = P_CODUSU;

        -- Busca a descrição do grupo de produto
        SELECT 
            DESCRGRUPOPROD
        INTO 
            v_DescrGrupoProd
        FROM 
            TGFGRU
        WHERE 
            CODGRUPOPROD = v_CodGrupoProd;

        -- Determina o próximo código de fila
        SELECT 
            NVL(MAX(CODFILA), 0) + 1
        INTO 
            v_MaxFila
        FROM 
            TMDFMG;

        -- Monta a mensagem do e-mail
        v_Mensagem := 
            '<div>Foi criado o produto ' || v_CodProd || ' - ' || v_DescrProd || 
            ' pertencente ao grupo ' || v_CodGrupoProd || ' - ' || v_DescrGrupoProd || '.</div>' ||
            '<div></div>' ||
            '<div>O produto foi criado em ' || TO_CHAR(v_DtAlter, 'DD/MM/YYYY HH24:MI:SS') || 
            ' pelo usuário ' || v_NomeUsu || '.</div>';

        -- Dispara e-mails para os grupos
        STP_GRAVA_FILA_BI2(
            v_MaxFila,
            v_Assunto,
            v_Mensagem,
            'fiscal@usinaspark.com.br',
            NULL
        );

        STP_GRAVA_FILA_BI2(
            v_MaxFila + 1,
            v_Assunto,
            v_Mensagem,
            'fiscal01@usinaspark.com.br',
            NULL
        );

        STP_GRAVA_FILA_BI2(
            v_MaxFila + 2,
            v_Assunto,
            v_Mensagem,
            'desenvolvimento01@usinaspark.com.br',
            NULL
        );
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Dados não encontrados para o produto ou usuário (CODPROD: ' || NVL(TO_CHAR(v_CodProd), 'null') || ').');

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro na procedure STP_AVISOINC_SPARK: ' || SQLERRM);
END;