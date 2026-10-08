/*==============================================================================
  Nome do Script : FC_FORMATAHTML
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta o HTML padrao de mensagem de atencao (mensagem, motivo
                  e solucao) exibido nas criticas do Sankhya.
  Assinatura     : FC_FORMATAHTML (P_MENSAGEM VARCHAR2, P_MOTIVO VARCHAR2,
                  P_SOLUCAO VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FC_FORMATAHTML', 'SPARKPRD') FROM dual;
                  - Acentos aparecem como ? no DDL exportado; nao foi verificado
                    se o caractere esta corrompido no proprio banco ou apenas
                    na exportacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION FC_FORMATAHTML (P_MENSAGEM VARCHAR2,
                                          P_MOTIVO   VARCHAR2,
                                          P_SOLUCAO  VARCHAR2)
  RETURN VARCHAR2 IS
  P_TEXTO VARCHAR2(4000);
  p_owner varchar2(100);

BEGIN

    P_TEXTO := '<p align=''center''><a href=http://www.sankhya.com.br target=_blank><img src=https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbV1KodjtC8lyZ2hcqiiNaDzaxJF0GStNp0jy92oUKEAQuMyVYVa3FbxObsz3ms2VrAlk&usqp=CAU></img></a></p><br><br/>' ||
               '<br/><br/><br/><p align=left><font size=12 face=arial color=#8B1A1A><br><br><br><b>Atenção:  </b>' ||
               P_MENSAGEM || '  <br><br>' || case
                 when P_MOTIVO IS NULL THEN
                  ''
                 ELSE
                  '<b>Motivo: </b> ' || P_MOTIVO || '<br><br>'
               END || case
                 when P_SOLUCAO IS NULL THEN
                  ''
                 ELSE
                  '<b>Solução: </b> ' || P_SOLUCAO || '<br><br>'
               END ||
               '<p align=center><font size=10 color=#008B45><b>Informações para o Implantador e/ou equipe Sankhya</b></font>';

  RETURN P_TEXTO;
END;
