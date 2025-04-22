create or replace PROCEDURE "SPK_ENVIAEMAILOS" (
	P_TIPOEVENTO INT,    -- Identifica o tipo de evento
	P_IDSESSAO VARCHAR2, -- Identificador da execução. Serve para buscar informações dos campos da execução.
    P_CODUSU INT         -- Código do usuário logado
) AS
	BEFORE_INSERT INT;
	AFTER_INSERT  INT;
    BEFORE_DELETE INT;
	AFTER_DELETE  INT;
    BEFORE_UPDATE INT;
	AFTER_UPDATE  INT;
	BEFORE_COMMIT INT;

	-- Variáveis para armazenar os dados
	P_NUMOS NUMBER;	
    P_MAXFILA NUMBER;
	P_SETOR CHAR;
	P_EMAIL VARCHAR(100);
	P_NOMEUSU VARCHAR(100);
	P_DHCRIACAO DATE;
    P_PROBAPONTADO VARCHAR(4000);
    P_PRIORIDADE VARCHAR(60);

BEGIN

	BEFORE_INSERT := 0;
	AFTER_INSERT  := 1;
	BEFORE_DELETE := 2;
	AFTER_DELETE  := 3;
	BEFORE_UPDATE := 4;
	AFTER_UPDATE  := 5;
	BEFORE_COMMIT := 10;

	P_NUMOS := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUMOS');
	P_SETOR := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'SETOR');
	P_DHCRIACAO := EVP_GET_CAMPO_DTA(P_IDSESSAO, 'DHCRIACAO');
    P_PROBAPONTADO := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'PROBAPONTADO');
    P_PRIORIDADE := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'PRIORIDADE');
	SELECT MAX(CODFILA)+1 INTO P_MAXFILA FROM TMDFMG;

	SELECT NOMEUSU INTO P_NOMEUSU FROM TSIUSU WHERE CODUSU = P_CODUSU;
    
    IF P_PRIORIDADE = '1' THEN
        P_PRIORIDADE := 'URGENTE';
    ELSIF P_PRIORIDADE = '2' THEN
        P_PRIORIDADE := 'ALTA';
    ELSIF P_PRIORIDADE = '3' THEN
        P_PRIORIDADE := 'NORMAL';
    END IF;

	IF P_TIPOEVENTO = BEFORE_INSERT THEN
		IF P_SETOR = 'M' THEN
			STP_GRAVA_FILA_BI2(P_MAXFILA,
			'Inclusão de nova O.S ' || P_PRIORIDADE || ' - ' || P_NUMOS,
            '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Nova Ordem de Serviço Criada</h2>            
            <p>Uma nova O.S foi criada no portal de Ordens de Serviço - Internas.</p>            
            <p><strong>Data de Criação:</strong> ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '</p>
            <p><strong>Usuário Criador:</strong> ' || P_NOMEUSU || '</p>        
            <div style="margin-top: 20px;">
                <h3 style="background-color: #f2f2f2; padding: 10px; border-radius: 5px;">Descrição do Problema</h3>
                <p style="border: 1px solid #ccc; padding: 10px; background-color: #f9f9f9; border-radius: 5px;">' || P_PROBAPONTADO || '</p>
            </div>
            </div>',
			'pcm@usinaspark.com.br',
			NULL);
		ELSE
			STP_GRAVA_FILA_BI2(P_MAXFILA,
			'Inclusão de nova O.S ' || P_PRIORIDADE || ' - ' || P_NUMOS,
            '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Nova Ordem de Serviço Criada</h2>            
            <p>Uma nova O.S foi criada no portal de Ordens de Serviço - Internas.</p>            
            <p><strong>Data de Criação:</strong> ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '</p>
            <p><strong>Usuário Criador:</strong> ' || P_NOMEUSU || '</p>        
            <div style="margin-top: 20px;">
                <h3 style="background-color: #f2f2f2; padding: 10px; border-radius: 5px;">Descrição do Problema</h3>
                <p style="border: 1px solid #ccc; padding: 10px; background-color: #f9f9f9; border-radius: 5px;">' || P_PROBAPONTADO || '</p>
            </div>
            </div>',
			'ti@usinaspark.com.br',
			NULL);
			STP_GRAVA_FILA_BI2(P_MAXFILA+1,
			'Inclusão de nova O.S ' || P_PRIORIDADE || ' - ' || P_NUMOS,
            '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Nova Ordem de Serviço Criada</h2>            
            <p>Uma nova O.S foi criada no portal de Ordens de Serviço - Internas.</p>            
            <p><strong>Data de Criação:</strong> ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '</p>
            <p><strong>Usuário Criador:</strong> ' || P_NOMEUSU || '</p>        
            <div style="margin-top: 20px;">
                <h3 style="background-color: #f2f2f2; padding: 10px; border-radius: 5px;">Descrição do Problema</h3>
                <p style="border: 1px solid #ccc; padding: 10px; background-color: #f9f9f9; border-radius: 5px;">' || P_PROBAPONTADO || '</p>
            </div>
            </div>',
			'tec.ti@usinaspark.com.br',
			NULL);
		END IF;
	END IF;

	--IF P_TIPOEVENTO = BEFORE_DELETE THEN

	--END IF;

	--IF P_TIPOEVENTO = BEFORE_UPDATE THEN

	--END IF;
	EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'O.S. não encontrada: ' || P_NUMOS);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro em SPK_ENVIAEMAILOS: ' || SQLERRM);
END;