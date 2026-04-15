create or replace TRIGGER SPK_UPD_INS_TGFITE_CONSUMOPRD 
BEFORE INSERT OR UPDATE ON TGFITE 
FOR EACH ROW
/*==============================================================================
  Nome do Script : SPK_UPD_INS_TGFITE_CONSUMOPRD
  Tipo           : Trigger
  Descrição      : Define CODLOCALORIG em TGFITE conforme centro de custo.
                  Mapeia unidades de produção (TOP 509) para locais de origem específicos.
  Tabela         : TGFITE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODTIPOPER INT;
    P_CODCENCUS INT;
    P_CODLOCALORIG INT;
BEGIN
    --CAPTURAR TOP
    SELECT CODTIPOPER INTO P_CODTIPOPER FROM TGFCAB WHERE NUNOTA = :NEW.NUNOTA;
    --CAPTURAR CENTRO DE RESULTADO
    SELECT CODCENCUS INTO P_CODCENCUS FROM TGFCAB WHERE NUNOTA = :NEW.NUNOTA;
    --DEFINIR LOCAL
    IF P_CODTIPOPER = 509 THEN
        IF P_CODCENCUS = 10201 THEN
            P_CODLOCALORIG := 102;
        END IF;
        IF P_CODCENCUS = 10301 THEN
            P_CODLOCALORIG := 103;
        END IF;
        IF P_CODCENCUS = 10302 THEN
            P_CODLOCALORIG := 103;
        END IF;
        IF P_CODCENCUS = 10303 THEN
            P_CODLOCALORIG := 103;
        END IF;
        IF P_CODCENCUS = 10304 THEN
            P_CODLOCALORIG := 104;
        END IF;
        IF P_CODCENCUS = 10305 THEN
            P_CODLOCALORIG := 105;
        END IF;
        IF P_CODCENCUS = 10306 THEN
            P_CODLOCALORIG := 107;
        END IF;
        IF P_CODCENCUS = 10307 THEN
            P_CODLOCALORIG := 106;
        END IF;
        IF P_CODCENCUS = 10308 THEN
            P_CODLOCALORIG := 108;
        END IF;
    END IF;
    
    --ATUALIZAR TABELA
    IF P_CODTIPOPER = 509 THEN
        :NEW.CODLOCALORIG := P_CODLOCALORIG;
    END IF;
END SPK_UPD_INS_TGFITE_CONSUMOPRD;