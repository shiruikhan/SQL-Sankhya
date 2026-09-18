/*==============================================================================
  Nome do Script : SNK_GETPRODUTOAGRUPADOGIRO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo de produto agrupado para giro de estoque (generico ou
                  alternativo), conforme tipo de agrupamento.
  Assinatura     : SNK_GETPRODUTOAGRUPADOGIRO (p_CodProd IN INT, p_TipoAgrupamento IN VARCHAR2)
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETPRODUTOAGRUPADOGIRO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETPRODUTOAGRUPADOGIRO (p_CodProd IN INT, p_TipoAgrupamento IN VARCHAR2)
RETURN INT
IS
  intCodProdAlt INT;
BEGIN
  IF (p_TipoAgrupamento = 'G') THEN
    RETURN Snk_GetProdutoGenerico(p_CodProd);
  ELSIF (p_TipoAgrupamento = 'S') THEN
     RETURN SNK_getCodProdAlt (p_CodProd, p_TipoAgrupamento);
  ELSE
     RETURN ( p_CodProd );
  END IF;
END;
