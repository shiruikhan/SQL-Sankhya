# Especificação: pedido do e-commerce com série, conferência fechada e liberação

Levantamento feito em 17/11/2026 a partir do repositório e de consultas ao banco
(`SPARKPRD`) rodadas pelo responsável. Serve de entrada para a alteração da
integração do e-commerce (Supabase Edge Function), que hoje sobe o pedido sem série.

**Objetivo:** o pedido sobe já com a série do produto vendido, com a conferência
da expedição fechada e as liberações tratadas, ficando pronto para faturamento.
Usuário da conferência e das liberações: **5**.

Legenda: **[CONFIRMADO]** visto no banco ou no código; **[INFERIDO]** dedução
minha, a validar; **[PENDENTE]** ainda sem resposta.

## 1. Parâmetros do ambiente

| Item | Valor | Origem |
|---|---|---|
| TOP do e-commerce | 1006 (`TIPMOV = 'P'`) | [CONFIRMADO] TGFCAB do pedido 838132 |
| Empresa / vendedor | 2 / 6 | [CONFIRMADO] idem |
| Configuração de conferência da TOP | `NUCCO = 2` ("CONFERÊNCIA - SAÍDA") | [CONFIRMADO] TGFCCO |
| `MOMENTOCONFERENCIA` | `F` (conferência depois da liberação, na fase de faturamento) | [CONFIRMADO] valor; significado [INFERIDO] pela `SNK_GET_SATUSCONFERENCIA` |
| `MULTENTREGAS` | `S` | [CONFIRMADO] |
| `FATAOCONCLUIR` | `N` (concluir a conferência não fatura sozinho) | [CONFIRMADO] |
| `FORMACAOVOLUMES` | `S` | [CONFIRMADO]; efeito em outras tabelas [PENDENTE] |
| `CONFPORSERIE` | `N` (a conferência por série não é a nativa) | [CONFIRMADO] |
| `CORTECONF` / `CORTEPARCIAL` | `S` / `S` (divergência gera fluxo de corte) | [CONFIRMADO] |

## 2. Sequência

1. Incluir o pedido e os itens (sem `TGFSER`). Item no padrão de
   `STP_INTEGRAPEDIDO_SITESPARK`: `ATUALESTOQUE = 1`, `RESERVA = 'S'`, local 109.
   Gravar `AD_LIBCONFERENCIA = 'S'` no cabeçalho (ver seção 7, item 8).
2. Confirmar o pedido pelo serviço nativo. O Sankhya cria as linhas de `TSILIB`
   só se alguma regra exigir; sem regra, o pedido já fica com `STATUSNOTA = 'L'`
   (caso do 838132, sem nenhuma linha em `TSILIB`).
3. Liberações (ver seção 5). O pedido só avança com `STATUSNOTA = 'L'`.
4. Conferência (seção 3):
   1. Gerar `NUCONF` (seção 4).
   2. `INSERT` em `TGFCON2` com `STATUS = 'A'`.
   3. `UPDATE TGFCAB SET NUCONFATUAL = <NUCONF>`.
   4. `INSERT` em `TGFCOI2`, uma linha por série.
   5. `UPDATE TGFCON2 SET STATUS = 'F', DHFINCONF = SYSDATE`. Tem que ser um
      `UPDATE` separado: a `TRG_TGFCON2_SPARK` só dispara na **mudança** de
      status; inserir já com `'F'` não preenche `TGFSER`.
5. Pedido pronto para faturamento. Verificar `TGFCAB.LIBCONF <> 'S'` no fim
   (com `LIBCONF = 'S'` e `MULTENTREGAS = 'S'` a conferência volta para a fila).

Fazer os passos 4.1 a 4.5 numa única transação, de preferência numa procedure
do Sankhya (`STP_*_SPARK`) chamada pela edge function. Idempotência: se já
existir `TGFCON2` para o `NUNOTAORIG`, não criar outra.

## 3. Estrutura das tabelas

### TGFCON2 (cabeçalho da conferência) [CONFIRMADO]

PK `NUCONF`. FKs: `NUNOTAORIG` -> `TGFCAB` (cascade), `CODUSUCONF` -> `TSIUSU`,
`NUCONFORIG` -> `TGFCON2`. Sem CHECK em `STATUS`.

| Coluna | Tipo | Obrigatória | Valor a gravar |
|---|---|---|---|
| `NUCONF` | NUMBER(10) | Sim | da `TGFNUM` (seção 4) |
| `NUNOTAORIG` | NUMBER(10) | Não | `NUNOTA` do pedido |
| `STATUS` | VARCHAR2(1) | Não | `'A'` ao inserir, depois `'F'` |
| `NUCONFORIG` | NUMBER(10) | Não | nulo |
| `DHINICONF` | DATE | Não | `SYSDATE` |
| `DHFINCONF` | DATE | Não | `SYSDATE` ao fechar |
| `CODUSUCONF` | NUMBER(5) | Não | `5` |
| `QTDVOL` | NUMBER(10) | Sim (default 0) | nº de volumes (1 no pedido de referência) |
| `NUPEDCOMP`, `NUNOTADEV` | NUMBER(10) | Não | nulos |

### TGFCOI2 (itens da conferência) [CONFIRMADO]

PK `(NUCONF, SEQCONF)`. FKs: `NUCONF` -> `TGFCON2` (cascade), `CODPROD` ->
`TGFPRO`, `CODVOL` -> `TGFVOL`. `COPIA` aceita `'S'`, `'N'` ou nulo.

| Coluna | Tipo | Obrigatória | Valor a gravar |
|---|---|---|---|
| `NUCONF` | NUMBER(10) | Sim | o da `TGFCON2` |
| `SEQCONF` | NUMBER(5) | Sim | 1, 2, 3... |
| `CODBARRA` | VARCHAR2(50) | Não | a série, igual à de `VGFSER` (ex.: `SN260021060188`) |
| `CODPROD` | NUMBER(10) | Não | produto do item |
| `CODVOL` | VARCHAR2(2) | Não | volume do item (ex.: `UN`) |
| `CONTROLE` | VARCHAR2(15) | Não | `' '` (um espaço) |
| `QTDCONFVOLPAD` | FLOAT | Não | `1` |
| `QTDCONF` | FLOAT | Não | `1` |
| `COPIA` | VARCHAR2(1) | Não | nulo |
| `DHALTER` | DATE | Não | `SYSDATE` |

### TGFSER (série do pedido), não gravar à mão [CONFIRMADO]

Nasce da `TRG_TGFCON2_SPARK` no `UPDATE` para `'F'`: `ATUALESTOQUE = 0`,
`TIPCONTEST = 'N'`, `CODUSU = STP_GET_CODUSULOGADO()`, `SEQUENCIA` = MAX da
`SEQUENCIA` do produto no pedido. Só copia se a nota ainda não tem nenhuma série.
Se o mesmo produto aparecer em dois itens, as séries caem todas no último item.

### TGFITE [CONFIRMADO]

`QTDCONFERIDA` fica em **0** mesmo depois da conferência e do faturamento
(pedido 838132). A integração não deve preenchê-lo.

### TSILIB (liberações) [CONFIRMADO]

PK `(NUCHAVE, TABELA, EVENTO, SEQUENCIA, SEQCASCATA, NUCLL)`. Sem trigger
sobre a tabela. NOT NULL sem default: `NUCHAVE`, `TABELA` (`'TGFCAB'`),
`EVENTO`, `CODUSUSOLICIT`, `DHSOLICIT`, `VLRLIMITE`, `VLRATUAL`. NOT NULL com
default: `VLRLIBERADO`, `CODUSULIB` (0), `PERCLIMITE`, `SEQUENCIA`, `SEQCASCATA`,
`NUCLL` (0), `REPROVADO`, `SUPLEMENTO`, `ANTECIPACAO`, `TRANSF` (`'N'`).

## 4. Numeração do NUCONF [CONFIRMADO]

`TGFNUM`: `ARQUIVO = 'TGFCON2'`, `CODEMP = 1`, `SERIE = '.'`, `ULTCOD = 14836`.
Linha única (vale para todas as empresas). A PK no banco é
`(ARQUIVO, CODEMP, SERIE, CODMODDOC)`; a chave que o dicionário declara
para o `DatasetSP` ainda não foi confirmada (o `TDDCAM` não traz essa marcação). A linha tem `CODMODDOC = 0` e `CODMAQ` nulo [CONFIRMADO em
17/11/2026; `ULTCOD` subiu de 14836 para 14837 no mesmo dia, ou seja, o contador
está em uso pela conferência nativa]. Gerar assim:

```sql
UPDATE TGFNUM
   SET ULTCOD = ULTCOD + 1
 WHERE ARQUIVO = 'TGFCON2' AND CODEMP = 1 AND SERIE = '.' AND CODMODDOC = 0
RETURNING ULTCOD INTO V_NUCONF;
```

Não usar o padrão `SELECT MAX(ULTCOD)+1` de outras procedures (não trava a linha).
Conferir uma vez que `ULTCOD >= MAX(NUCONF)` em `TGFCON2`.

## 5. Liberações

**Decisão do responsável:** liberar automaticamente os **eventos 2 e 8** com o
usuário 5. Qualquer outro evento pendente: **não avançar o pedido** e devolver
aviso (pedido + evento) para liberação manual.

Dados observados (únicos dois pedidos do e-commerce com liberação no histórico):

| Pedido | Evento | `VLRATUAL` | `VLRLIMITE` | `VLRLIBERADO` | Solicitante | Liberador |
|---|---|---|---|---|---|---|
| 822880 | 2 | 1020,49 | 678,11 | 1020,49 | 113 | 55 |
| 825667 | 8 | 11 | 0 | 11 | 113 | 99 |

Ambos: `SEQUENCIA = SEQCASCATA = NUCLL = 0`, `REPROVADO = 'N'`, `DHLIB` no mesmo
dia da solicitação, `STATUSNOTA = 'L'` ao final.

Regra de liberação por linha pendente (`DHLIB IS NULL AND REPROVADO = 'N'`):

- `DHLIB = SYSDATE`, `CODUSULIB = 5`, `VLRLIBERADO = VLRATUAL`.
- `WHERE` com a chave completa de 6 colunas.

```sql
SELECT NUCHAVE, TABELA, EVENTO, SEQUENCIA, SEQCASCATA, NUCLL, VLRATUAL, VLRLIMITE
  FROM TSILIB
 WHERE TABELA = 'TGFCAB' AND NUCHAVE = :NUNOTA
   AND DHLIB IS NULL AND REPROVADO = 'N';
```

## 6. Validações que podem derrubar a integração [CONFIRMADO]

- **`TRG_TGFCOI2_SPARK`** (em cada insert/update de `TGFCOI2`), ORA-20101 se:
  - a série não tem `ATUALESTOQUE = 1` em `VGFSER` para o produto ("não possui
    estoque disponível"). Vale para **qualquer** linha de `TGFCOI2`, inclusive
    produto sem controle de série;
  - a série já foi conferida na mesma conferência;
  - a série está presa em outro pedido aberto (`TGFSER.ATUALESTOQUE = 0`,
    `TIPMOV = 'P'`, `PENDENTE = 'S'`). O próprio pedido é exceção desde que o
    `TGFCON2` já exista, por isso criar o `TGFCON2` antes do `TGFCOI2`.
- **`TRG_UPD_AVISOSPARK`**: com `STATUS = 'F'` e `QTDVOL = 1` só emite
  `DBMS_OUTPUT`. Não bloqueia.
- **Chaves estrangeiras:** o usuário 5 tem que existir em `TSIUSU`;
  `CODPROD` e `CODVOL` têm que existir em `TGFPRO` e `TGFVOL`.
- **Quantidade exata:** com `CORTECONF = 'S'`, a quantidade conferida por
  produto tem que ser igual à do pedido (uma linha de `TGFCOI2` por unidade),
  senão cai no fluxo de corte.

## 7. Pendências e riscos

1. **[PENDENTE] UPDATE direto em `TSILIB` basta?** Sem trigger na tabela, mas o
   serviço nativo de liberação pode também atualizar `TGFCAB.STATUSNOTA`. Testar
   com o usuário 5 num pedido que dispare evento 2 ou 8, comparando `TGFCAB` e
   `TSILIB` antes e depois. Se o `STATUSNOTA` não mudar, liberar pelo serviço
   nativo (autenticado como usuário 5) em vez de `UPDATE`.
2. **[PENDENTE] Permissão do usuário 5** nos eventos 2 e 8 (os liberadores
   históricos foram 55 e 99).
3. **[PENDENTE] Volumes (`FORMACAOVOLUMES = 'S'`):** verificar se a conferência
   grava algo fora de `TGFCON2.QTDVOL`:
   ```sql
   SELECT C.TABLE_NAME FROM ALL_CONSTRAINTS C
    WHERE C.OWNER = 'SPARKPRD' AND C.CONSTRAINT_TYPE = 'R' AND C.R_CONSTRAINT_NAME = 'PK_TGFCON2';
   ```
   e contagem por `NUCONF = 14739` nas tabelas com coluna `NUCONF` (excluir as de
   produção: `TPRCONF`, `TPRCOI`, `AD_TPRCOI`, `AD_CORRAPONTAMENTO`).
4. **[PENDENTE] Todos os itens do e-commerce têm série?** Produto sem série
   falha na `TRG_TGFCOI2_SPARK`.
5. **[RISCO] `TGFSER.CODUSU`** vem de `STP_GET_CODUSULOGADO()`. Fora de uma
   sessão autenticada como usuário 5 (conexão direta ao banco), pode sair outro
   valor. Detalhes no item 9.
6. **[RISCO] Mais de um item do mesmo produto** no pedido: a trigger coloca
   todas as séries na última `SEQUENCIA`.
7. **[INFERIDO] Em que momento o serviço nativo confirma o pedido** e se a
   conferência pode ser gravada antes de `STATUSNOTA = 'L'`. Seguir a ordem da
   seção 2.
8. **Campos customizados de `TGFCAB` ligados à conferência** [CONFIRMADO o
   valor no 838132; papel de cada um é INFERIDO]:
   - `AD_LIBCONFERENCIA` ("Liberado para Conferência"; opções `S` = Sim,
     `N` = Não): **`'S'` no 838132**. Provável porta de entrada da fila de
     conferência. Gravar `'S'` ao subir o pedido pronto. [PENDENTE confirmar com
     a expedição quem marca esse campo hoje e se a fila depende dele.]
   - `AD_VOLCONFERE` ("Qtd. de Volumes Conferida"; opções `S`/`N`): **nulo** no
     838132. Não preencher. (`TransferenciaUtils` grava `'S'` só em transferências
     criadas por código.)
   - `AD_COLETADO` (data/hora): **11/11/26** no 838132, mesmo dia da conferência.
     Provavelmente preenchido depois, na coleta; não preencher na integração.
   - `LIBCONF = 'N'` e `NUCONFATUAL = 14739` no 838132 (confirmados).
9. **[RISCO] `TGFSER.CODUSU`.** No dicionário o campo tem expressão
   `$ctx_usuario_logado;` (`DTALTER` = `getDateTime()`), com `CALCULADO = N`, ou
   seja, valor padrão e não campo calculado. Como a `TGFSER` é inserida pela
   `TRG_TGFCON2_SPARK` (SQL, fora da camada de entidade), o 0 vem de
   `STP_GET_CODUSULOGADO()` sob a sessão OAuth. O `UPDATE` de `CODUSU = 5` por
   `DatasetSP.save` provavelmente se mantém (padrão se aplica na criação), mas
   testar; se for sobrescrito, ajustar dentro de uma procedure ou aceitar 0.
10. **[PENDENTE] Onde o dicionário declara as chaves primárias.** As colunas do
    `TDDCAM` são: `NUCAMPO`, `NOMETAB`, `NOMECAMPO`, `DESCRCAMPO`, `TIPCAMPO`,
    `MASCARA`, `EXPRESSAO`, `PERMITEPESQUISA`, `CALCULADO`, `PERMITEPADRAO`,
    `APRESENTACAO`, `ORDEM`, `VISIVELGRIDPESQUISA`, `TIPOAPRESENTACAO`,
    `SISTEMA`, `TAMANHO`, `ADICIONAL`, `CONTROLE`, `DOMAIN`. Nenhuma marca chave
    primária nem obrigatoriedade (os `S/N` são pesquisa, calculado e padrão).

## 8. Instâncias do dicionário (para `DatasetSP`) [CONFIRMADO]

| Tabela | Instância | `NUINSTANCIA` | PK no banco |
|---|---|---|---|
| `TGFCON2` | `CabecalhoConferencia` | 1261 | `NUCONF` |
| `TGFCOI2` | `DetalhesConferencia` | 1260 | `NUCONF`, `SEQCONF` |
| `TSILIB` | `LiberacaoLimite` | 247 | `NUCHAVE`, `TABELA`, `EVENTO`, `SEQUENCIA`, `SEQCASCATA`, `NUCLL` |
| `TGFCAB` | `CabecalhoNota` | 49 | `NUNOTA` |
| `TGFSER` | `SerieProduto` | 1024 | `NUNOTA`, `SEQUENCIA`, `SERIE` |
| `TGFNUM` | `ControleNumeracao` | 179 | `ARQUIVO`, `CODEMP`, `SERIE`, `CODMODDOC` |

`TGFCAB` tem uma segunda instância, `CabecalhoFox` ("Nota venda do Checkout",
2259). Usar `CabecalhoNota`, a menos que a integração atual já suba o pedido por
`CabecalhoFox`. A chave primária que o `DatasetSP` usa vem do dicionário; as
chaves acima são as do banco, a confirmar (item 10 da seção 7).

Pontos para os testes em homologação: inserir `CabecalhoConferencia` sem
`NUCONF` e ver se a chave volta e se o `ULTCOD` de `ControleNumeracao` sobe; testar
o `UPDATE` de `SerieProduto.CODUSU`; testar a liberação em `LiberacaoLimite` com o
usuário 0 e ver se o `STATUSNOTA` do pedido muda. Triggers sobre `TGFSER`
(versionadas): `TRG_INC_TGFSER_SPARK` só age nas TOPs 212, 213, 511 e 800; a nativa
`TRG_INC_TGFSER` é só de INSERT; as de DELETE não interferem. Nada bloqueia o
`UPDATE` de `CODUSU` na TOP 1006 (confirmar com `ALL_TRIGGERS`).

## 9. Pedido de referência (838132, TOP 1006, empresa 2, vendedor 6)

- `TGFCAB`: `STATUSNOTA = 'L'`, `PENDENTE = 'N'` (já faturado),
  `LIBCONF = 'N'`, `NUCONFATUAL = 14739`, `AD_LIBCONFERENCIA = 'S'` (os três
  confirmados por consulta direta, ver seção 7 item 8).
- `TGFITE`: `SEQUENCIA 1`, `CODPROD 3125026`, `QTDNEG 1`, `QTDENTREGUE 1`,
  `QTDCONFERIDA 0`, `CODVOL UN`, `ATUALESTOQUE 1`, `RESERVA S`, local 109.
- `TGFCON2`: `NUCONF 14739`, `STATUS F`, `CODUSUCONF 24`, `QTDVOL 1`,
  `DHINICONF`/`DHFINCONF` em 11/11/26.
- `TGFCOI2`: `SEQCONF 1`, `CODBARRA SN260021060188`, `CODPROD 3125026`,
  `CODVOL UN`, `CONTROLE ' '`, `QTDCONFVOLPAD 1`, `QTDCONF 1`.
- `TGFSER`: `SEQUENCIA 1`, `SERIE SN260021060188`, `ATUALESTOQUE 0`,
  `TIPCONTEST N`, `CODUSU 24`.
- `TSILIB`: sem linhas (pedido sem exigência de liberação).
