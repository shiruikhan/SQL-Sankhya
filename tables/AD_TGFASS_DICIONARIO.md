# AD_TGFASS — Dicionário de Dados Sankhya

Mapeamento de `TDDCAM` (campos) e `TDDOPC` (opções) da `AD_TGFASS`, capturado
em 04/11/2026 com `scripts/CAPTURA_DICIONARIO_AD_TGFASS.SQL`. DDL físico em
`AD_TGFASS.SQL`.

Tipo: `I` inteiro · `F` decimal · `S` texto · `D` data · `H` data/hora · `B` binário.
Apresentação: `P` padrão · `O` lista de opções (ver TDDOPC) · `T` texto longo · `I` imagem.

## Campos (TDDCAM, por NUCAMPO)

| NUCAMPO | Campo | Descrição | Tipo | Apres. | Obs. |
|---|---|---|---|---|---|
| 9999992852 | NUMOS | Nr. da OS | I | P | PK |
| 9999992853 | DTRECEB | DT. do Recebimento | D | P | |
| 9999992854 | SNENTRADA | SN Recebido | S | P | |
| 9999992859 | STATUS | Status | S | O | |
| 9999992861 | DTCONCLUSAO | Dt. de Conclusão | D | P | |
| 9999992862 | OBSADM | Observação Administrativa | S | T | |
| 9999992863 | OBSTECNICO | Observação Técnica | S | T | |
| 9999992871 | VLRPROD | Vlr. Produto | F | P | |
| 9999992872 | CODPARC | Cód. Parceiro | I | P | FK TGFPAR |
| 9999992873 | NUMNOTAENT | Nr. Nota de Entrada | I | P | |
| 9999992874 | NUMNOTASAIDA | Nr. Nota de Saída | I | P | |
| 9999992875 | DEFEITO | Causa do Defeito | S | O | |
| 9999992881 | FOTO | Imagem do Produto | B | I | |
| 9999992897 | DTVENDA | Dt. da Venda | D | P | **Calculado** (não existe no DDL): `SELECT MAX(DTVENDA) FROM VGFSERIES WHERE SERIE = SNENTRADA AND MOVIMENTO = 'SAÍDA'` |
| 9999992900 | COMPROVANTE | Comprovante de Envio | B | I | |
| 9999992902 | CODPARCASS | Assistência Responsável | I | P | FK TGFPAR |
| 9999992903 | DTENVIO | Dt. de Envio | D | P | |
| 9999992904 | T_CODPROD | Cód. do Produto | I | P | |
| 9999992905 | T_DESCRPROD | Descrição do Produto | S | P | |
| 9999992907 | T_DESCRPARVENDA | Parceiro de Venda | S | P | |
| 9999992908 | T_DTVENDA | Dt. da Venda | D | P | |
| 9999992909 | T_DTFABRICACAO | Dt. de Fabricação | D | P | |
| 9999992910 | T_TIPO | Tipo de SN | S | P | |
| 9999992911 | T_LOTE | Lote de Prd. | S | P | |
| 9999992912 | T_RFINTERNA | Referência Interna | S | P | |
| 9999992913 | ENDERECO | Endereço | S | P | |
| 9999992915 | CEP | CEP | S | P | |
| 9999992916 | ESTADO | Estado | S | P | |
| 9999992917 | CIDADE | Cidade | S | P | |
| 9999992918 | ENDNUMERO | Número | S | P | |
| 9999992919 | BAIRRO | Bairro | S | P | |
| 9999992923 | DISJUNTOR | Disjuntor | S | O | checklist |
| 9999992924 | COOLER | Cooler Solto | S | O | checklist |
| 9999992925 | DISPLAY | Programação Display | S | O | checklist |
| 9999992926 | ADESIVO | Adesivo Errado | S | O | checklist |
| 9999992927 | CHICOTE | Chicote Cooler | S | O | checklist |
| 9999992928 | LED | Led | S | O | checklist |
| 9999992929 | MICA | Sem Mica | S | O | checklist |
| 9999992930 | CORRENTEMIN | Corrente Desregulada Mínima | S | O | checklist |
| 9999992931 | CORRENTEMAX | Corrente Desregulada Máxima | S | O | checklist |
| 9999992932 | CURTO | Curto na Placa/Componente | S | O | checklist |
| 9999992933 | SOLDA | Solda Fria | S | O | checklist |
| 9999992934 | INDUTOR | Indutor em Curto | S | O | checklist |
| 9999992935 | TRANSFORMADOR | Transformador em Curto | S | O | checklist |
| 9999992936 | COMPINVERTIDO | Componente Invertido/Quebrado | S | O | checklist |
| 9999992939 | VERSAO | Versão | S | P | |
| 9999993543 | TIPOENTREGA | Tipo de Envio | S | O | |
| 9999994108 | RASTREIO | Rastreio | S | P | |
| 9999994184 | FUNCSOLDA | Res. Solda | I | P | |
| 9999994185 | FUNCSOLDA2 | Res. Solda 2 | I | P | |
| 9999994186 | FUNCTESTE | Resp. Teste | I | P | |
| 9999994187 | FUNCINSERCAO | Res. Inserção | I | P | |
| 9999994189 | TECNICO | Técnico Manutentor | I | P | FK AD_CADFUNC |
| 9999994197 | DTLANC | Dt. Lançamento | H | P | |
| 9999994212 | VLRCONSERTO | Vlr. Conserto | F | P | TRG_TGFASS_VLRCONSERTO_SPARK (CODTAB 14) |
| 9999994214 | VLRSERVTECNICO | Vlr. Serviço Técnico | F | P | TRG_TGFASS_VLRCONSERTO_SPARK (CODTAB 15) |
| 9999994217 | NUNOTA | Nro. Único Nota de Serviço | I | P | FK TGFCAB |
| 9999994218 | MESFOLHA | Id. Pagamento Técnico | S | P | |
| 9999994221 | DHALTER | Dh. Alteração | H | P | Padrão `return $ctx_dh_atual;` (Nov/2026) |

## Opções (TDDOPC)

### STATUS (NUCAMPO 9999992859)

| Ordem | Valor | Opção |
|---|---|---|
| 1 | G | Garantia |
| 2 | RN | Renovação |
| 3 | D | Devolução |
| 4 | T | Perda/Troca |
| 5 | RT | Retorno/Troca |
| 6 | R | Retorno |
| 7 | TG | Troca de Geração |
| 8 | SP | Substituição de Placa |
| 9 | A | Atualização |
| 10 | RA | Retorno Autorizada |
| 11 | ED | Devolução E-commerce |
| 12 | EG | Garantia E-commerce |
| 13 | TR | Troca |
| 14 | RTC | Retorno Técnico |

Em Nov/2026 `T` deixou de ser "Troca" e passou a ser "Perda/Troca"; a troca
comum agora é `TR`. Entraram também `ED`, `EG` e `RTC`.

### DEFEITO (NUCAMPO 9999992875)

| Ordem | Valor | Opção |
|---|---|---|
| 1 | ATT | Necessidade de Atualização |
| 2 | MU | Mau Uso |
| 3 | DC | Desgaste (Cronológico) |
| 6 | FAB | Montagem (Fábrica) |
| 10 | SD | Sem Defeito |

### TIPOENTREGA (NUCAMPO 9999993543)

| Ordem | Valor | Opção |
|---|---|---|
| 1 | M | EM MÃOS |
| 2 | S | SEDEX |
| 3 | P | PAC |
| 4 | R | RODONAVES |
| 5 | B | BRASPRESS |
| 6 | O | OUTROS |

### Checklist (DISJUNTOR … COMPINVERTIDO)

Todos os 14 campos do checklist usam `S` = Sim e `N` = Não.
