CREATE OR REPLACE FUNCTION FN_XMLTYPE_SAFE (
    P_XML IN VARCHAR2
)
RETURN XMLTYPE
/*==============================================================================
  Nome do Script : FN_XMLTYPE_SAFE
  Tipo           : Function
  Descrição      : Converte uma string para XMLTYPE de forma segura.
                   Retorna NULL caso o conteúdo seja inválido, evitando que
                   erros de parsing (ORA-31011) derrubem queries que dependem
                   de XMLTYPE — como a VW_CTE_AUTORIZADOS.

  Parâmetros     :
    P_XML          — string contendo o XML a converter

  Retorno        :
    XMLTYPE        — objeto XML parseado
    NULL           — quando o conteúdo não é um XML válido

  Uso            : VW_CTE_AUTORIZADOS — substituição de XMLTYPE(X.DOCSREF)
                   no PASSING do XMLTABLE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2026
  Última Revisão : Abril/2026
==============================================================================*/
IS
BEGIN
    RETURN XMLTYPE(P_XML);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END FN_XMLTYPE_SAFE;
