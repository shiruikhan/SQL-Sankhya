create or replace PROCEDURE "STP_ENVIAEMAILOS_SPARK" (
	P_TIPOEVENTO INT,
	P_IDSESSAO VARCHAR2,
    P_CODUSU INT
) AS
/*==============================================================================
  Nome do Script : STP_ENVIAEMAILOS_SPARK
  Descrição      : Evento que dispara emails aos setores responsáveis quando uma
                   nova Ordem de Serviço é criada.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 11/03/2025
  Última Revisão : 28/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/
    -- Constantes para eventos
    BEFORE_INSERT CONSTANT INT := 0;
    AFTER_INSERT  CONSTANT INT := 1;
    BEFORE_DELETE CONSTANT INT := 2;
    AFTER_DELETE  CONSTANT INT := 3;
    BEFORE_UPDATE CONSTANT INT := 4;
    AFTER_UPDATE  CONSTANT INT := 5;
    BEFORE_COMMIT CONSTANT INT := 10;

    -- Variáveis para armazenamento de dados
    P_NUMOS         NUMBER;
    P_MAXFILA       NUMBER;
    P_SETOR         CHAR;
    P_EMAIL         VARCHAR2(100);
    P_NOMEUSU       VARCHAR2(100);
    P_DHCRIACAO     DATE;
    P_PROBAPONTADO  VARCHAR2(4000);
    P_PRIORIDADE    VARCHAR2(60);

BEGIN
    -- Coleta de dados da sessão
	P_NUMOS := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUMOS');
	P_SETOR := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'SETOR');
	P_DHCRIACAO := EVP_GET_CAMPO_DTA(P_IDSESSAO, 'DHCRIACAO');
    P_PROBAPONTADO := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'PROBAPONTADO');
    P_PRIORIDADE := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'PRIORIDADE');
	SELECT MAX(CODFILA)+1 INTO P_MAXFILA FROM TMDFMG;
	SELECT NOMEUSU INTO P_NOMEUSU FROM TSIUSU WHERE CODUSU = P_CODUSU;
    
    -- Ajuste da descrição da prioridade
    IF P_PRIORIDADE = '1' THEN
        P_PRIORIDADE := 'URGENTE';
    ELSIF P_PRIORIDADE = '2' THEN
        P_PRIORIDADE := 'ALTA';
    ELSIF P_PRIORIDADE = '3' THEN
        P_PRIORIDADE := 'NORMAL';
    END IF;

	-- Verificação do tipo de evento
    IF P_TIPOEVENTO = BEFORE_INSERT THEN
        DECLARE
            V_TITULO VARCHAR2(200);
            V_CONTEUDO VARCHAR2(4000);
        BEGIN
            V_TITULO := 'Inclusão de nova O.S ' || P_PRIORIDADE || ' - ' || P_NUMOS;
            V_CONTEUDO := '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Nova Ordem de Serviço Criada</h2>
                            <p>Uma nova O.S foi criada no portal de Ordens de Serviço - Internas.</p>
                            <p><strong>Data de Criação:</strong> ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '</p>
                            <p><strong>Usuário Criador:</strong> ' || P_NOMEUSU || '</p>
                            <div style="margin-top: 20px;">
                                <h3 style="background-color: #f2f2f2; padding: 10px; border-radius: 5px;">Descrição do Problema</h3>
                                <p style="border: 1px solid #ccc; padding: 10px; background-color: #f9f9f9; border-radius: 5px;">' || P_PROBAPONTADO || '</p>
                            </div>
                          </div>';

            -- Envio de e-mails de acordo com o setor
            IF P_SETOR = 'M' THEN
                STP_GRAVA_FILA_BI2(P_MAXFILA, V_TITULO, V_CONTEUDO, 'pcm@usinaspark.com.br', NULL);
            ELSE
                STP_GRAVA_FILA_BI2(P_MAXFILA, V_TITULO, V_CONTEUDO, 'ti@usinaspark.com.br', NULL);
                STP_GRAVA_FILA_BI2(P_MAXFILA + 1, V_TITULO, V_CONTEUDO, 'tec.ti@usinaspark.com.br', NULL);
            END IF;
        END;
    END IF;

	EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'O.S. não encontrada: ' || P_NUMOS);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro em SPK_ENVIAEMAILOS: ' || SQLERRM);
END;