/*==============================================================================
  Nome do Script : GET_LOCAL_ORIGEM
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o local de origem (CODLOCALORIG) do item da nota de
                  origem de um item atendido (via TGFVAR). [origem a
                  confirmar]
  Assinatura     : GET_LOCAL_ORIGEM (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER)
                  RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_LOCAL_ORIGEM', 'SPARKPRD') FROM dual;
                  - Origem nao confirmada: criada apos a instalacao do ERP, sem
                    marca Spark no fonte. Se for customizacao, mover para
                    functions/.
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_LOCAL_ORIGEM (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER) 
RETURN NUMBER AS
    P_LOCAL     NUMBER(10);
    
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    BEGIN
        SELECT MAX(ITE.CODLOCALORIG) INTO P_LOCAL
        FROM TGFITE ITE INNER JOIN TGFVAR VAR 
            ON (ITE.NUNOTA = VAR.NUNOTAORIG AND ITE.SEQUENCIA = VAR.SEQUENCIAORIG AND VAR.NUNOTAORIG<> VAR.NUNOTA
)
        WHERE VAR.NUNOTA = P_NUNOTA
             AND VAR.SEQUENCIA = P_SEQUENCIA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_LOCAL := -1;
    END;
    
    RETURN P_LOCAL;
END;
