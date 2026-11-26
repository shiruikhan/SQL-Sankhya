CREATE OR REPLACE TRIGGER TRG_UPD_OSINTERNA 
BEFORE UPDATE ON AD_OSINTERNA
FOR EACH ROW
DECLARE
/*==============================================================================
  Nome do Script : TRG_UPD_OSINTERNA
  Tipo           : Trigger
  Descrição      : Envia e-mail ao criador da O.S. interna quando o status é
                   alterado por outro usuário: Cancelada (C, só com motivo em
                   OBSERVACAO), Programada (P, com DTPROGRAMADA) e Finalizada
                   (F, com o pedido original do usuário e a observação do
                   executante quando preenchida). Em andamento (A) e demais
                   status não geram e-mail.
  Tabela         : AD_OSINTERNA
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_OSINTERNA -- O.S. interna (leitura via :OLD/:NEW)
                   TSIUSU       -- e-mail do criador (leitura)
                   TMDFMG       -- fila de e-mail (próximo CODFILA)
  Dependencias   : STP_GRAVA_FILA_BI2

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 13/03/2025
  Última Revisão : 30/04/2025
                   Setembro/2026 — Performance: as consultas a TMDFMG
                   (MAX(CODFILA), tabela inteira) e TSIUSU (e-mail) só eram
                   úteis quando o status muda de mãos para outro usuário e o
                   e-mail existe. Movidas para dentro do IF que já checava
                   essa condição (agora aninhado), evitando as 2 consultas em
                   toda alteração de AD_OSINTERNA que não representa essa
                   troca de status por outro usuário. Comportamento
                   observável inalterado.
                   Novembro/2026 — E-mail de finalização (F) passa a incluir
                   a observação do executante (OBSERVACAO), só quando
                   preenchida, com quebras de linha convertidas em <br>.
                   Novembro/2026 — Deixa de enviar e-mail para Em andamento
                   (A): status fora de C/P/F sai antes das consultas.
                   Finalização passa a incluir o pedido original
                   (PROBAPONTADO), porque o usuário esquece o que pediu.
                   OBSERVACAO só conta como preenchida com tamanho > 0
                   (DBMS_LOB.GETLENGTH), para CLOB vazio não disparar o
                   e-mail de cancelamento sem motivo.

  Observações    : - OBSERVACAO é o campo rotulado "Observações do executante"
                     no relatório 25 (O.S. Interna); no cancelamento o mesmo
                     campo é usado como motivo.
                   - PROBAPONTADO é o problema/pedido informado na abertura.
                   - Nenhum e-mail sai quando o próprio criador altera o status.
==============================================================================*/
    P_CODUSUCRI     AD_OSINTERNA.CODUSUCRI%TYPE := :OLD.CODUSUCRI;
    P_CODUSUALT     AD_OSINTERNA.CODUSUALT%TYPE := :NEW.CODUSUALT;
    P_STATUSOLD     AD_OSINTERNA.STATUS%TYPE    := :OLD.STATUS;
    P_STATUSNEW     AD_OSINTERNA.STATUS%TYPE    := :NEW.STATUS;
    P_PROBAPONTADO  AD_OSINTERNA.PROBAPONTADO%TYPE := :NEW.PROBAPONTADO;
    P_OBSERVACAO    AD_OSINTERNA.OBSERVACAO%TYPE := :NEW.OBSERVACAO;
    P_DTPROGRAMADA  AD_OSINTERNA.DTPROGRAMADA%TYPE := :NEW.DTPROGRAMADA;
    P_NUMOS         AD_OSINTERNA.NUMOS%TYPE := :NEW.NUMOS;
    P_MAXFILA       NUMBER;
    P_EMAIL         VARCHAR2(60);
BEGIN
    -- Envia e-mail se o status foi alterado por outro usuário para um dos
    -- status notificados (C, P, F); qualquer outra troca, inclusive para
    -- Em andamento (A), sai sem consultar TSIUSU/TMDFMG
    IF P_CODUSUCRI <> P_CODUSUALT
       AND P_STATUSOLD <> P_STATUSNEW
       AND P_STATUSNEW IN ('C', 'P', 'F') THEN

    -- Geração de código de fila e recuperação do e-mail
    BEGIN
        SELECT EMAIL INTO P_EMAIL FROM TSIUSU WHERE CODUSU = P_CODUSUCRI;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Nenhum e-mail encontrado; aborta trigger
            RETURN;
        WHEN OTHERS THEN
            -- Log de erro pode ser adicionado aqui se necessário
            RETURN;
    END;

    IF P_EMAIL IS NOT NULL THEN
        SELECT MAX(CODFILA) + 1 INTO P_MAXFILA FROM TMDFMG;

        CASE P_STATUSNEW
            WHEN 'C' THEN
                -- Só notifica com motivo; GETLENGTH > 0 trata NULL e CLOB vazio
                IF DBMS_LOB.GETLENGTH(P_OBSERVACAO) > 0 THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Cancelamento da sua O.S. nº ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3;">Cancelamento da Ordem de Serviço</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi <strong>Cancelada</strong>.</p>
                            <h3 style="margin-top:20px;">Motivo</h3>
                            <p style="background:#f9f9f9; padding:10px;">' || P_OBSERVACAO || '</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;

            WHEN 'P' THEN
                IF P_DTPROGRAMADA IS NOT NULL THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Programação da sua O.S. nº ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3;">Ordem de Serviço Programada</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi marcada como <strong>Programada</strong>, prevista para ' || TO_CHAR(P_DTPROGRAMADA, 'DD/MM/YYYY') || '.</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;

            WHEN 'F' THEN
                -- Pedido original (PROBAPONTADO) entra para o usuário lembrar
                -- o que solicitou; observação do executante só quando
                -- preenchida. Quebras de linha viram <br> para não colapsarem
                -- no HTML
                STP_GRAVA_FILA_BI2(P_MAXFILA,
                    'Finalização da sua O.S. nº ' || P_NUMOS,
                    '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                        <h2 style="color: #0056b3;">Ordem de Serviço Finalizada</h2>
                        <p>A O.S. ' || P_NUMOS || ' foi <strong>Finalizada</strong>.</p>'
                    || CASE
                           WHEN DBMS_LOB.GETLENGTH(P_PROBAPONTADO) > 0 THEN
                               '<h3 style="margin-top:20px;">Seu pedido</h3>
                        <p style="background:#f9f9f9; padding:10px;">' || REPLACE(P_PROBAPONTADO, CHR(10), '<br>') || '</p>'
                       END
                    || CASE
                           WHEN DBMS_LOB.GETLENGTH(P_OBSERVACAO) > 0 THEN
                               '<h3 style="margin-top:20px;">Observações do executante</h3>
                        <p style="background:#f9f9f9; padding:10px;">' || REPLACE(P_OBSERVACAO, CHR(10), '<br>') || '</p>'
                       END
                    || '</div>',
                    P_EMAIL, NULL);

            ELSE
                NULL;
        END CASE;
    END IF;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro inesperado, impede falha na transação principal
        NULL;
END;