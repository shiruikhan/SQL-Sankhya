create or replace PROCEDURE "STP_OSINTERNA_INC_SPARK" (
    P_CODUSU NUMBER,
    P_IDSESSAO VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM OUT VARCHAR2
) AS

    PARAM_P_SETOR VARCHAR2(4000);
    PARAM_P_PROBAPONTADO VARCHAR2(4000);
    PARAM_P_CODUSUCRI VARCHAR2(4000);
    M_NUMOS NUMBER;
    EMAIL_USU VARCHAR2(100);
    P_MAXFILA NUMBER;
BEGIN
    -- Obtenção dos parâmetros da sessão
    PARAM_P_SETOR := ACT_TXT_PARAM(P_IDSESSAO, 'P_SETOR');
    PARAM_P_PROBAPONTADO := ACT_TXT_PARAM(P_IDSESSAO, 'P_PROBAPONTADO');
    PARAM_P_CODUSUCRI := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODUSUCRI');

    -- Geração do próximo número de OS
    SELECT MAX(NUMOS) + 1 INTO M_NUMOS FROM AD_OSINTERNA;

    IF M_NUMOS IS NULL THEN
        M_NUMOS := 1;
    END IF;

    -- Busca o email do usuário criador
    SELECT EMAIL INTO EMAIL_USU FROM TSIUSU WHERE CODUSU = PARAM_P_CODUSUCRI;
    SELECT MAX(CODFILA)+1 INTO P_MAXFILA FROM TMDFMG;
    
    -- Inserção na tabela AD_OSINTERNA
    BEGIN
        INSERT INTO AD_OSINTERNA (
            NUMOS,
            DHCRIACAO,
            SETOR,
            PROBAPONTADO,
            CODUSUCRI,
            PRIORIDADE
        ) VALUES (
            M_NUMOS,                                    -- Número sequencial da OS
            SYSDATE,                                    -- Data/hora atual para criação
            PARAM_P_SETOR,                              -- Setor informado pelo usuário
            PARAM_P_PROBAPONTADO,                       -- Problema apontado
            PARAM_P_CODUSUCRI,                           -- Código do usuário criador
            1
        );
        
        -- Log de sucesso
        P_MENSAGEM := NVL(P_MENSAGEM, '') || 'OS Interna ' || M_NUMOS || ' criada com sucesso. ';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- Caso a OS já exista na tabela
            P_MENSAGEM := NVL(P_MENSAGEM, '') || 'ERRO: OS Interna ' || M_NUMOS || ' já existe na tabela. ';
        WHEN OTHERS THEN
            -- Outros erros
            P_MENSAGEM := NVL(P_MENSAGEM, '') || 'ERRO ao criar OS Interna ' || M_NUMOS || ': ' || SQLERRM || '. ';
    END;
    
    -- Controle de transação e finalização
    BEGIN
        -- Verificação de erros antes do commit
        IF P_MENSAGEM IS NULL OR INSTR(P_MENSAGEM, 'ERRO') = 0 THEN
            -- Commit apenas se não houve erros
            COMMIT;
            P_MENSAGEM := NVL(P_MENSAGEM, '') || 'Processo concluído com sucesso! 1 OS Interna foi processada.';
            STP_GRAVA_FILA_BI2(P_MAXFILA, 'Inclusão de nova O.S Urgente - ' || M_NUMOS , '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                                            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Nova Ordem de Serviço Criada</h2>
                                            <p>&#x1F389; Parabéns! Uma nova O.S foi criada <strong>automaticamente</strong> em seu nome no portal de Ordens de Serviço - Internas.</p>
                                            <p>&#x1F4A1; <em>Dica profissional:</em> Da próxima vez, que tal criar você mesmo? É mais rápido e o TI agradece! &#x1F609;</p>
                                            <p><strong>Data de Criação:</strong> ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '</p>
                                            <div style="margin-top: 20px;">
                                                <h3 style="background-color: #f2f2f2; padding: 10px; border-radius: 5px;">Descrição do Problema</h3>
                                                <p style="border: 1px solid #ccc; padding: 10px; background-color: #f9f9f9; border-radius: 5px;">' || PARAM_P_PROBAPONTADO || '</p>
                                            </div>
                                        </div>', EMAIL_USU, NULL);
        ELSE
            -- Se houve erros, fazer rollback
            ROLLBACK;
            P_MENSAGEM := 'Processo finalizado com erros. Transações foram desfeitas. ' || P_MENSAGEM;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_MENSAGEM := 'ERRO CRÍTICO durante a finalização: ' || SQLERRM;
    END;

END;
