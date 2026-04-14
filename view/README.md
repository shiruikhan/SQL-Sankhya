# Pasta `view`

Esta pasta contém views auxiliares de consulta usadas pelo ERP Sankhya e integrações.

## Objetivos das views

- `VGFEST`: soma o estoque disponível por SKU para produtos ativos com movimento recente e tipos de uso específicos.
- `VW_CTE_AUTORIZADOS`: retorna CT-e autorizados com referência a NF-e na estrutura XML de `DOCSREF`.
- `VGFNFE`: retorna registros de NF-e ativos emitidos em vendas por vendedor específico nos últimos 4 dias.

## Views documentadas

### VGFEST
- Tipo: `VIEW`
- Colunas: `SKU`, `ESTO`
- Descrição: agrega estoque do local `109` e empresa `1` para produtos ativos (`PRO.ATIVO = 'S'`) que tenham vendas/negócios nos últimos 300 dias e uso de produto em `'R'` ou `'V'`.
- Detalhes: inclui estoque direto de `TGFEST` e também estoque indireto via matéria-prima em `TGFICP`.

### VW_CTE_AUTORIZADOS
- Tipo: `VIEW`
- Colunas: `NRARQUIVO`, `NUMNOTA`, `NUNOTA`, `CHAVEACESSO`, `DHIMPORT`, `DHPROCESS`, `XML`, `TIPO`, `CODUSUIMP`, `CODUSUPROC`, `CODTIPOPER`, `SITUACAOCTE`, `ULTEVEDFE`, `DOCSREF`, `CHAVEACESSO_REF`, `CODTIPOPER_NFE`, `NR_SEQUENCIA`, `CNPJREMET`, `CNPJDEST`, `CFOPXML`
- Descrição: retorna CT-e do tipo `'C'` e situação `'A'` com documentos referenciados em XML (`DOCSREF`). A view extrai cada `chaveAcesso` referenciada dentro do XML e busca o `CODTIPOPER` da NF-e de referência.

### VGFNFE
- Tipo: `VIEW`
- Colunas: `NUNOTA`, `CODVEND`, `PEDIDOEXTERNO`, `AD_WAREHOUSEID`, `CHAVENFE`, `NOTAXML`
- Descrição: seleciona notas fiscais de vendas (`TIPMOV = 'V'`) do vendedor `42`, com NF-e ativa e protocolo recente (últimos 4 dias). Retorna também o XML da NF-e do cliente quando disponível.

## Observações

- Estes scripts são criados como views para suporte a relatórios e processos de integração.
- Caso haja alteração na estrutura das tabelas fonte, atualize também as definições e a documentação nesta pasta.
