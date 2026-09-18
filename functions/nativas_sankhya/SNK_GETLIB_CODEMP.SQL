/*==============================================================================
  Nome do Script : SNK_GETLIB_CODEMP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a empresa vinculada a um evento de liberacao (TSILIB), com regra
                  especifica para apontamento de producao (TPRAPO/TPRIATV).
  Assinatura     : SNK_GETLIB_CODEMP (P_TABELA TSILIB.TABELA%TYPE, P_NUCHAVE TSILIB.NUCHAVE%TYPE, P_SEQUENCIA TSILIB.SEQUENCIA%TYPE, P_EVENTO TSILIB.EVENTO%TYPE)
                   RETURN TSIEMP
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETLIB_CODEMP', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETLIB_CODEMP (P_TABELA TSILIB.TABELA%TYPE, P_NUCHAVE TSILIB.NUCHAVE%TYPE, P_SEQUENCIA TSILIB.SEQUENCIA%TYPE, P_EVENTO TSILIB.EVENTO%TYPE)
RETURN TSIEMP.CODEMP%TYPE
IS
  P_CODEMP TSIEMP.CODEMP%TYPE;
BEGIN
    IF P_TABELA = 'TPRAPO' THEN
    	SELECT MIN(PLP.CODEMP) INTO P_CODEMP FROM TPRAPO APO
  	  	INNER JOIN TPRIATV ATV ON ATV.IDIATV = APO.IDIATV
  	  	INNER JOIN TPRIPROC IPROC ON IPROC.IDIPROC = ATV.IDIPROC
  	  	INNER JOIN TPRPLP PLP ON PLP.CODPLP = IPROC.CODPLP
  	  	WHERE APO.NUAPO = P_NUCHAVE;
        RETURN P_CODEMP;
    ELSIF P_TABELA = 'TPRIATV' THEN
        SELECT MIN(PLP.CODEMP) INTO P_CODEMP FROM TPRIATV ATV
        INNER JOIN TPRIPROC IPROC ON IPROC.IDIPROC = ATV.IDIPROC
        INNER JOIN TPRPLP PLP ON PLP.CODPLP = IPROC.CODPLP
        WHERE ATV.IDIATV = P_NUCHAVE;
        RETURN P_CODEMP;
    ELSE
        SELECT MIN(CODEMP) INTO P_CODEMP FROM TSIEMP;
        RETURN P_CODEMP;
    END IF;
END;
