/*==============================================================================
  Nome do Script : SNK_PRECO
  Tipo           : Function Nativa Sankhya (referência — não customizada)
  Descrição      : Function nativa do ERP Sankhya que retorna o preço vigente
                    de um produto (P_CODPROD) numa tabela de preços (P_CODTAB),
                    considerando a vigência mais recente (MAX(DTVIGOR) <=
                    SYSDATE) e delegando o cálculo para STP_OBTEM_PRECO2.
                    Armazenada aqui apenas como referência/documentação — não
                    é mantida pela Spark, é nativa do Sankhya.
  Parâmetros     : P_CODTAB  — código da tabela de preços (ex.: 14 = tabela
                    padrão de serviços, usada por TRG_SPKCAE_VLRCONSERTO_SPARK)
                   P_CODPROD — código do produto a precificar
  Retorno        : Preço vigente do produto na tabela informada; se não houver
                    tabela de preço vigente na data (NO_DATA_FOUND), passa
                    V_NUTAB = 0 para STP_OBTEM_PRECO2
  Tabelas        : TGFTAB -- consulta (vigência da tabela de preços)
  Dependencias   : STP_OBTEM_PRECO2 (procedure nativa Sankhya)
  Uso            : TRG_SPKCAE_VLRCONSERTO_SPARK e
                    scripts/AD_SPKCAE_BACKFILL_VLRCONSERTO.SQL — cálculo do
                    valor de conserto (VLRCONSERTO) a partir do preço de
                    serviço do produto.

  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem
                     sobrescrever esta function. Revisar após cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 17/09/2026, via:
                     SELECT TEXT FROM DBA_SOURCE
                      WHERE NAME = 'SNK_PRECO' ORDER BY LINE
==============================================================================*/
create or replace FUNCTION SNK_PRECO(P_CODTAB IN INTEGER, P_CODPROD IN INTEGER)
RETURN FLOAT
IS
  V_PRECO FLOAT;
  V_NUTAB INTEGER;
BEGIN
 BEGIN
    SELECT T.NUTAB
      INTO V_NUTAB
      FROM TGFTAB T
     WHERE T.CODTAB = P_CODTAB
       AND T.DTVIGOR = (SELECT MAX (DTVIGOR)
                          FROM TGFTAB M
                         WHERE M.CODTAB = P_CODTAB
                           AND M.DTVIGOR <= SYSDATE);

 EXCEPTION WHEN NO_DATA_FOUND THEN
  V_NUTAB := 0;
 END;

 STP_OBTEM_PRECO2(V_NUTAB, P_CODPROD, SYSDATE, V_PRECO);

 RETURN (V_PRECO);
END;
