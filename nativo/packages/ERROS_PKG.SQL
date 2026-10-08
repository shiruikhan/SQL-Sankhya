/*==============================================================================
  Nome do Script : ERROS_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Constantes com as mensagens de erro padrao de validacao de
                  cadastro (registro inativo, nao analitico ou inexistente:
                  centro de resultado, conta contabil, grupo, natureza,
                  projeto, parceiro, produto, TOP, vendedor, etc.).
  Uso            : Usadas pelas triggers de validacao de cadastro do Sankhya em
                  RAISE_APPLICATION_ERROR.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'ERROS_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE ERROS_PKG as
  ERRO_CENCUS_ATIV_ANALI_EXIST  CONSTANT VARCHAR2(100) := 'Centro de resultado não esta ativo, não é ANALITICO ou não EXISTE.';
  ERRO_CTACTB_ATIV_ANALI_EXIST  CONSTANT VARCHAR2(100) := 'Código contábil não esta ativo, não ANALITICO ou não EXISTE.';
  ERRO_CTACTB2_ATIV_ANALI_EXIST CONSTANT VARCHAR2(100) := 'Código contábil 2 não esta ativo, não ANALITICO ou não EXISTE.';
  ERRO_CTACTB3_ATIV_ANALI_EXIST CONSTANT VARCHAR2(100) := 'Código contábil 3 não esta ativo, não ANALITICO ou não EXISTE.';
  ERRO_CTACTB4_ATIV_ANALI_EXIST CONSTANT VARCHAR2(100) := 'Código contábil 4 não esta ativo, não ANALITICO ou não EXISTE.';
  ERRO_GRUPO_ATIV_ANALI_EXIST   CONSTANT VARCHAR2(100) := 'Grupo de produto não esta ativo, não é ANALITICO ou não EXISTE.';
  ERRO_NAT_ATIV_ANALI_EXIST     CONSTANT VARCHAR2(100) := 'Natureza não esta ativa, não e ANALITICA ou não existe';
  ERRO_PROJ_ATIV_ANALI_EXIST    CONSTANT VARCHAR2(100) := 'Projeto não esta ativo, não e ANALITICO ou não existe.';    
  ERRO_TIPPARC_ATIV_ANALI_EXIST CONSTANT VARCHAR2(100) := 'Perfil não esta ativo, não ANALITICO ou não EXISTE.';

  ERRO_GRU_ANALI_NAOEXISTE  CONSTANT VARCHAR2(100) := 'Grupo de produto não e ANALITICO ou não EXISTE.';
  
  ERRO_REGISTRO_PADRAO      CONSTANT VARCHAR2(100) := 'Registro padrão do sistema. não pode ser alterado ou excluído.';
  ERRO_EXCECOES_ICMS        CONSTANT VARCHAR2(100) := 'Registro não pode ser excluído. Existe uma ref.nas exceções das alíquotas de ICMS.';
 
  ERRO_PRODUTO_NAOATIVO     CONSTANT VARCHAR2(100) := 'Produto/Serviço não esta ativo.';
  ERRO_PARCEIRO_NAOATIVO    CONSTANT VARCHAR2(100) := 'Parceiro não esta ativo. ';
  ERRO_VENDEDOR_NAOATIVO    CONSTANT VARCHAR2(100) := 'Vendedor não esta ativo.';
  ERRO_CONTRATO_NAOATIVO    CONSTANT VARCHAR2(100) := 'Contrato não esta ativo .';
  ERRO_TIPOPER_NAOATIVO     CONSTANT VARCHAR2(100) := 'Tipo de operação não esta ativo.';
  ERRO_PROJETO_NAOATIVO     CONSTANT VARCHAR2(100) := 'Projeto não esta ativo.';
  ERRO_VEICULO_NAOATIVO     CONSTANT VARCHAR2(100) := 'Veículo não esta ativo.';
  ERRO_EMPRESA_NAOATIVA     CONSTANT VARCHAR2(100) := 'Empresa não esta ativa.';
  ERRO_GRUPOUSU_NAOATIVO    CONSTANT VARCHAR2(100) := 'Grupo de usuário não esta ativo.';
  ERRO_IMPLANTADOR_NAOATIVO CONSTANT VARCHAR2(100) := 'Implantador não esta ativo.';
  ERRO_CONTATO_NAOATIVO     CONSTANT VARCHAR2(100) := 'Contato não esta ativo.';
  ERRO_REGIAO_NAOATIVA      CONSTANT VARCHAR2(100) := 'Região não esta ativa.';   
  
  ERRO_PARCEIRO_NAOEXISTE   CONSTANT VARCHAR2(100) := 'Parceiro não existe.';
  ERRO_PRODUTO_NAOEXISTE    CONSTANT VARCHAR2(100) := 'Produto não existe.';
  ERRO_TIPNEG_NAOEXISTE     CONSTANT VARCHAR2(100) := 'Tipo de negociação não existe';
  ERRO_USUARIO_NAOEXISTE    CONSTANT VARCHAR2(100) := 'Usuário não existe';
  ERRO_VENDEDOR_NAOEXISTE   CONSTANT VARCHAR2(100) := 'Vendedor não existe';
  ERRO_TIPPARC_NAOEXISTE    CONSTANT VARCHAR2(100) := 'Tipo de parceiro não existe';
  ERRO_TIPOPER_NAOEXISTE    CONSTANT VARCHAR2(100) := 'Tipo de operação não existe';
  ERRO_GRUPO_NAOEXISTE      CONSTANT VARCHAR2(100) := 'Grupo de produto não existe';
  ERRO_EMPRESA_NAOEXISTE    CONSTANT VARCHAR2(100) := 'Empresa não existe.';
  ERRO_ORDEMCARGA_NAOEXISTE CONSTANT VARCHAR2(100) := 'Ordem de carga não existe';
    
  ERRO_TIPOPER_NAO_ATIV_EXIST  CONSTANT VARCHAR2(100) := 'Tipo de Operação não esta ativo ou não exite.';
  ERRO_PRODUTO_NAO_ATIV_EXIST  CONSTANT VARCHAR2(100) := 'Produto não esta ativo ou não exite.';
  ERRO_SERVICO_NAO_ATIV_EXIST  CONSTANT VARCHAR2(100) := 'Serviço não esta ativo ou não exite.';
  ERRO_PARCEIRO_NAO_ATIV_EXIST CONSTANT VARCHAR2(100) := 'Parceiro não esta ativo ou não exite.';
  ERRO_REGIAO_NAO_ATIV_EXIST   CONSTANT VARCHAR2(100) := 'Região não esta ativa ou não exite.';  

  ERRO_USUARIO_RESTRITO  CONSTANT VARCHAR2(100) := 'Usuário SANKHYA não pode ser alterado.';

END;
