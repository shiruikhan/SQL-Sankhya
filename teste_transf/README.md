# Protótipo — Transferência com Reforma Tributária (IBS/CBS)

**Empresa:** Spark Eletrônica
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior
**Status:** Protótipo / spike — **não implantado em produção**

---

## Objetivo

Pasta isolada para o desenvolvimento do fluxo de notas de **transferência entre
empresas com suporte aos impostos da Reforma Tributária (IBS/CBS)**. Baseia-se na
classe de produção `java/GerarTransferencia.java`, acrescentando o cálculo e a
persistência dos totalizadores IBS/CBS em `TGFREFIMP`.

Enquanto o fluxo não estiver homologado, o código vive aqui e **não** no pacote de
produção `br.com.spark.transferencia`. O pacote deste protótipo é
`br.com.spark.transferencia.teste`.

---

## Arquivos

| Arquivo | Tipo | Descrição |
|---|---|---|
| `GerarTransferenciaReformaTrib.java` | Botão de Ação (`AcaoRotinaJava`) | Protótipo standalone do gerador de transferência. Sobre o fluxo original acrescenta dois passos: cálculo de IBS/CBS das notas de **saída** e das notas de **entrada** via `totalizarImpostosCbsIbsIs`. Modelos de nota: saída ID 278268, entrada ID 278275. Parâmetros de contexto: `P_CODEMPORIG`, `P_CODEMPDEST`, `P_CODLOCALORIG`, `P_CODLOCALDEST`. Pré-condições: pedido `TIPMOV = 'P'`, conferência finalizada, sem transferência prévia |
| `util/ReformaTribUtils.java` | Classe utilitária (helpers estáticos) | Encapsula as **duas fases** do cálculo IBS/CBS em torno do limite de transação exigido por `totalizarImpostosCbsIbsIs`. TX-1 calcula e commita IBS/CBS em `TGFDIN` (entity facade); TX-2 lê o estado committed e persiste os totalizadores em `TGFREFIMP` (exige TX ativa). O cabeçalho do arquivo documenta o fluxo de dados confirmado por inspeção do JAR `mgecom-model-4.35b448` e as causas conhecidas de falha |

---

## Dependências específicas

- `br.com.sankhya.mgecomercial.model.impostos.ImpostosHelpper` — de
  `mgecom-model-4.35b448.jar` (o proxy `mge-modelcore` 4.10/4.1 **não** expõe
  `totalizarImpostosCbsIbsIs`).
- Tabela `TGFREFIMP` (totalizadores IBS/CBS por nota) — migration deve estar
  aplicada.
- Parâmetro `CALCULA_REFORMA_PELA_DIN` habilitado e NT 2029/001 ativa
  (`isVersaoNT2029001`), senão o cálculo sai silenciosamente sem gravar.

---

## Observações

- Não alterar o pacote de produção `br.com.spark.transferencia` a partir daqui.
- Ao promover para produção: mover as classes para `java/`, ajustar o pacote,
  atualizar `java/README.md` e remover esta pasta (ou movê-la para `inativos/`).
- A pasta inteira está fora da estrutura de deploy — não é empacotada no `.jar`
  de produção.
