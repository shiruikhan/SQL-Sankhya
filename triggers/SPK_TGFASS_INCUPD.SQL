create or replace TRIGGER SPK_TGFASS_INCUPD 
BEFORE INSERT OR UPDATE ON AD_TGFASS 
FOR EACH ROW
/*==============================================================================
  Nome do Script : SPK_TGFASS_INCUPD
  Tipo           : Trigger
  Descrição      : Popula automaticamente dados de endereço (rua, número, CEP, estado, cidade, bairro) do parceiro consultando tabelas relacionadas.
  Tabela         : AD_TGFASS
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODPARC INTEGER;
    
    P_ENDERECO VARCHAR(200);
    P_ENDNUMERO VARCHAR(50);
    P_CEP VARCHAR(50);
    P_ESTADO VARCHAR(50);
    P_CIDADE VARCHAR(50);
    P_BAIRRO VARCHAR (100);
    
BEGIN
    P_CODPARC := :NEW.CODPARC;
    
    IF P_CODPARC IS NOT NULL THEN
        SELECT EN.TIPO || ' ' || EN.NOMEEND,
            PAR.NUMEND,
            PAR.CEP,
            UFS.DESCRICAO,
            CID.NOMECID,
            BAI.CODBAI INTO P_ENDERECO, P_ENDNUMERO, P_CEP, P_ESTADO, P_CIDADE, P_BAIRRO
        FROM TGFPAR PAR
            INNER JOIN TSIEND EN ON PAR.CODEND = EN.CODEND
            INNER JOIN TSICID CID ON PAR.CODCID = CID.CODCID
            INNER JOIN TSIUFS UFS ON CID.UF = UFS.CODUF
            INNER JOIN TSIBAI BAI ON PAR.CODBAI = BAI.CODBAI
        WHERE PAR.CODPARC = P_CODPARC;
    END IF;
    
    :NEW.ENDERECO := P_ENDERECO;
    :NEW.ENDNUMERO := P_ENDNUMERO;
    :NEW.CEP := P_CEP;
    :NEW.ESTADO := P_ESTADO;
    :NEW.CIDADE := P_CIDADE;   
    :NEW.BAIRRO := P_BAIRRO;
END SPK_TGFASS_INCUPD;