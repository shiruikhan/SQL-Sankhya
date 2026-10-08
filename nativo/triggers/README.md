# Triggers Nativas

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  

---

## Contexto

Esta pasta contém triggers nativas do Sankhya das tabelas que a Spark customiza (detalhe de cada uma no catálogo abaixo). Diferentemente das triggers em `triggers/` (raiz do repositório, código da Spark), estas existem nativamente no ERP — sua estrutura foi extraída direto do banco (via `DBMS_METADATA.GET_DDL`) para referência, revisão de impacto e, quando aplicável, para identificar customizações da Spark. A pasta é versionada para que o `git diff` mostre o que mudou a cada recaptura (ver [`../README.md`](../README.md)).

> **Atenção:** Atualizações do ERP Sankhya podem sobrescrever estas triggers. Revisar após cada atualização de versão.

## Catálogo (capturado em 08/10/2026)

Triggers das tabelas nativas que a Spark também customiza, sem arquivo próprio no repositório da Spark. **Estado = `ENABLED`/`DISABLED` no banco na captura.** "Origem" segue a data de criação: *instalação* = 12/2021 (ERP); *lote* = criada junto de ≥5 triggers no mesmo dia (atualização do ERP); *pontual* / *AD_** = origem a confirmar pelo código.

### `TGFCAB` (23 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFCAB_AFTER`](TRG_DLT_TGFCAB_AFTER.SQL) | AFTER STATEMENT DELETE | ENABLED | 19/09/2025 | 21/09/2026 | 22 | lote 19/09/2025 |
| [`TRG_DLT_TGFCAB_AUTINV`](TRG_DLT_TGFCAB_AUTINV.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 63 | instalação |
| [`TRG_DLT_TGFCAB_ECF`](TRG_DLT_TGFCAB_ECF.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 43 | instalação |
| [`TRG_DLT_TGFCAB_ESTTERC`](TRG_DLT_TGFCAB_ESTTERC.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 09/07/2025 | 82 | instalação |
| [`TRG_DLT_TGFCAB_LIB41`](TRG_DLT_TGFCAB_LIB41.SQL) | BEFORE ROW DELETE | ENABLED | 03/07/2024 | 03/07/2024 | 40 | lote 03/07/2024 |
| [`TRG_DLT_TGFCAB_METAS`](TRG_DLT_TGFCAB_METAS.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 65 | instalação |
| [`TRG_DLT_TGFCAB_RASTEST`](TRG_DLT_TGFCAB_RASTEST.SQL) | AFTER ROW DELETE | ENABLED | 01/07/2022 | 03/07/2024 | 95 | lote 01/07/2022 |
| [`TRG_INC_UPD_FX_TGFCAB`](TRG_INC_UPD_FX_TGFCAB.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 08/12/2021 | 03/07/2024 | 57 | instalação |
| [`TRG_INC_UPD_TGFCAB_RASTST`](TRG_INC_UPD_TGFCAB_RASTST.SQL) | BEFORE ROW INSERT OR UPDATE OR DELETE | ENABLED | 01/07/2022 | 21/09/2026 | 50 | lote 01/07/2022 |
| [`TRG_INC_UPD_TGFCAB_TGFGXE`](TRG_INC_UPD_TGFCAB_TGFGXE.SQL) | AFTER ROW UPDATE | ENABLED | 01/07/2022 | 21/09/2026 | 31 | lote 01/07/2022 |
| [`TRG_TGFCAB_INC_UPD_AFT_TIMFK`](TRG_TGFCAB_INC_UPD_AFT_TIMFK.SQL) | AFTER STATEMENT INSERT OR UPDATE | ENABLED | 07/12/2021 | 26/08/2026 | 96 | instalação |
| [`TRG_TGFCAB_INC_UPD_TIMFK`](TRG_TGFCAB_INC_UPD_TIMFK.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 46 | instalação |
| [`TRG_TGFCAB_INC_UPD_VINCNT`](TRG_TGFCAB_INC_UPD_VINCNT.SQL) | AFTER ROW UPDATE | ENABLED | 01/07/2022 | 03/07/2024 | 24 | lote 01/07/2022 |
| [`TRG_UPD_DLT_TGFCAB_EC`](TRG_UPD_DLT_TGFCAB_EC.SQL) | BEFORE ROW UPDATE OR DELETE | ENABLED | 04/04/2023 | 20/04/2026 | 32 | lote 04/04/2023 |
| [`TRG_UPD_TGFCAB_AFTER`](TRG_UPD_TGFCAB_AFTER.SQL) | AFTER STATEMENT UPDATE | ENABLED | 22/04/2026 | 21/09/2026 | 120 | pontual (a confirmar) |
| [`TRG_UPD_TGFCAB_DTBEM`](TRG_UPD_TGFCAB_DTBEM.SQL) | AFTER ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 40 | instalação |
| [`TRG_UPD_TGFCAB_EST_TGFEFA`](TRG_UPD_TGFCAB_EST_TGFEFA.SQL) | AFTER ROW UPDATE | ENABLED | 01/07/2022 | 03/07/2024 | 64 | lote 01/07/2022 |
| [`TRG_UPD_TGFCAB_GRANDES_CARGAS`](TRG_UPD_TGFCAB_GRANDES_CARGAS.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 54 | instalação |
| [`TRG_UPD_TGFCAB_SERIE`](TRG_UPD_TGFCAB_SERIE.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 104 | instalação |
| [`TRG_UPD_TGFCAB_TCIBEM`](TRG_UPD_TGFCAB_TCIBEM.SQL) | AFTER ROW UPDATE | ENABLED | 06/09/2023 | 03/07/2024 | 108 | pontual (a confirmar) |
| [`TRG_UPD_TGFCAB_TGAMOV`](TRG_UPD_TGFCAB_TGAMOV.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 19/09/2025 | 47 | instalação |
| [`TRG_UPD_TGFCAB_TGFCPP`](TRG_UPD_TGFCAB_TGFCPP.SQL) | AFTER ROW UPDATE | ENABLED | 03/02/2026 | 03/02/2026 | 101 | pontual (a confirmar) |
| [`TRG_UPD_TGFCAB_TRANSG`](TRG_UPD_TGFCAB_TRANSG.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 49 | instalação |

### `TGFFIN` (21 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFFIN_EXCLUSAO`](TRG_DLT_TGFFIN_EXCLUSAO.SQL) | AFTER ROW DELETE | ENABLED | 03/07/2024 | 03/07/2024 | 58 | lote 03/07/2024 |
| [`TRG_INC_UPD_TGFFIN_DTNEG`](TRG_INC_UPD_TGFFIN_DTNEG.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 37 | instalação |
| [`TRG_INC_UPD_TGFFIN_DTPRAZO`](TRG_INC_UPD_TGFFIN_DTPRAZO.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 03/07/2024 | 03/07/2024 | 24 | lote 03/07/2024 |
| [`TRG_INC_UPD_TGFFIN_DTVENC`](TRG_INC_UPD_TGFFIN_DTVENC.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 24 | instalação |
| [`TRG_INC_UPD_TGFFIN_TGFORD`](TRG_INC_UPD_TGFFIN_TGFORD.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 46 | instalação |
| [`TRG_INC_UPD_TGFFIN_VINCNT`](TRG_INC_UPD_TGFFIN_VINCNT.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 24 | instalação |
| [`TRG_INC_UPD_TGFNNH_TGFFIN`](TRG_INC_UPD_TGFNNH_TGFFIN.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 83 | instalação |
| [`TRG_TGFFIN_ATL_IPTU`](TRG_TGFFIN_ATL_IPTU.SQL) | BEFORE ROW UPDATE | ENABLED | 01/07/2022 | 03/07/2024 | 50 | lote 01/07/2022 |
| [`TRG_TGFFIN_DLT_AFT_TIMFK`](TRG_TGFFIN_DLT_AFT_TIMFK.SQL) | AFTER STATEMENT DELETE | ENABLED | 01/07/2022 | 03/07/2024 | 89 | lote 01/07/2022 |
| [`TRG_TGFFIN_DLT_TIMFK`](TRG_TGFFIN_DLT_TIMFK.SQL) | BEFORE ROW DELETE | DISABLED | 07/12/2021 | 03/07/2024 | 41 | instalação |
| [`TRG_TGFFIN_INC_UPD_DIFVLRLDT`](TRG_TGFFIN_INC_UPD_DIFVLRLDT.SQL) | AFTER ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 92 | instalação |
| [`TRG_TGFFIN_INC_UPD_TIMFK`](TRG_TGFFIN_INC_UPD_TIMFK.SQL) | BEFORE ROW INSERT OR UPDATE | DISABLED | 07/12/2021 | 03/07/2024 | 80 | instalação |
| [`TRG_TGFFIN_TIMVALDTL`](TRG_TGFFIN_TIMVALDTL.SQL) | AFTER ROW UPDATE | DISABLED | 07/12/2021 | 03/07/2024 | 35 | instalação |
| [`TRG_TGFFIN_TIMVALDTL_AFT`](TRG_TGFFIN_TIMVALDTL_AFT.SQL) | AFTER STATEMENT UPDATE | ENABLED | 01/07/2022 | 21/09/2026 | 95 | lote 01/07/2022 |
| [`TRG_TGFFIN_TIM_BAIXA_CJMD`](TRG_TGFFIN_TIM_BAIXA_CJMD.SQL) | AFTER ROW UPDATE | DISABLED | 07/12/2021 | 03/07/2024 | 49 | instalação |
| [`TRG_TGFFIN_TIM_BAIXA_CJMDB`](TRG_TGFFIN_TIM_BAIXA_CJMDB.SQL) | BEFORE ROW UPDATE | DISABLED | 07/12/2021 | 03/07/2024 | 87 | instalação |
| [`TRG_UPD_TGFFIN_GRAVAR`](TRG_UPD_TGFFIN_GRAVAR.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 56 | instalação |
| [`TRG_UPT_TGFFIN_AFTER`](TRG_UPT_TGFFIN_AFTER.SQL) | AFTER STATEMENT UPDATE | ENABLED | 07/12/2021 | 21/09/2026 | 61 | instalação |
| [`TRG_UPT_TGFFIN_M2`](TRG_UPT_TGFFIN_M2.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 47 | instalação |
| [`TRG_UPT_TGFFIN_METAS`](TRG_UPT_TGFFIN_METAS.SQL) | AFTER ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 58 | instalação |
| [`TRG_UPT_TGFFIN_NUBCO`](TRG_UPT_TGFFIN_NUBCO.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 57 | instalação |

### `TGFITE` (13 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFITE_HCRUZADAS`](TRG_DLT_TGFITE_HCRUZADAS.SQL) | AFTER ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 32 | instalação |
| [`TRG_DLT_TGFITE_METAS`](TRG_DLT_TGFITE_METAS.SQL) | AFTER ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 24 | instalação |
| [`TRG_DLT_TGFITE_TGFCUSITE`](TRG_DLT_TGFITE_TGFCUSITE.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 45 | instalação |
| [`TRG_DLT_TGFITE_TGFICO`](TRG_DLT_TGFITE_TGFICO.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/02/2022 | 31 | instalação |
| [`TRG_DLT_TGFITE_TRANSG`](TRG_DLT_TGFITE_TRANSG.SQL) | AFTER ROW DELETE | ENABLED | 07/12/2021 | 03/02/2022 | 22 | instalação |
| [`TRG_INC_TGFITE_AFTER`](TRG_INC_TGFITE_AFTER.SQL) | AFTER STATEMENT INSERT | ENABLED | 13/01/2023 | 21/09/2026 | 76 | pontual (a confirmar) |
| [`TRG_INC_UPD_DLT_TGFITE_LIB41`](TRG_INC_UPD_DLT_TGFITE_LIB41.SQL) | BEFORE ROW INSERT OR UPDATE OR DELETE | ENABLED | 07/12/2021 | 13/11/2024 | 48 | instalação |
| [`TRG_INC_UPD_TGFITE`](TRG_INC_UPD_TGFITE.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 61 | instalação |
| [`TRG_INC_UPD_TGFITE_ATIVO`](TRG_INC_UPD_TGFITE_ATIVO.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 17/03/2026 | 42 | instalação |
| [`TRG_INC_UPD_TGFITE_TGFGXE`](TRG_INC_UPD_TGFITE_TGFGXE.SQL) | AFTER ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 21/09/2026 | 24 | instalação |
| [`TRG_INC_UPD_TGFITE_VERIFCORTE`](TRG_INC_UPD_TGFITE_VERIFCORTE.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 42 | instalação |
| [`TRG_UPD_TGFITE_TCIBEM`](TRG_UPD_TGFITE_TCIBEM.SQL) | BEFORE ROW UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 59 | instalação |
| [`TRG_UPT_TGFITE_METAS`](TRG_UPT_TGFITE_METAS.SQL) | AFTER ROW UPDATE | ENABLED | 05/11/2025 | 05/11/2025 | 55 | pontual (a confirmar) |

### `TGFPRO` (8 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFPRO`](TRG_DLT_TGFPRO.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 91 | instalação |
| [`TRG_INC_UPD_DLT_TGFPRO_SUBST`](TRG_INC_UPD_DLT_TGFPRO_SUBST.SQL) | AFTER ROW INSERT OR UPDATE OR DELETE | ENABLED | 07/12/2021 | 21/09/2026 | 108 | instalação |
| [`TRG_INC_UPD_TGFPRO_EC`](TRG_INC_UPD_TGFPRO_EC.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 04/04/2023 | 30/06/2026 | 40 | lote 04/04/2023 |
| [`TRG_INC_UPD_TGFPRO_TGFREA`](TRG_INC_UPD_TGFPRO_TGFREA.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 30 | instalação |
| [`TRG_INC_UPT_TGFPRO_MARCA`](TRG_INC_UPT_TGFPRO_MARCA.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 29 | instalação |
| [`TRG_INC_UPT_TGFPRO_REFERENCIA`](TRG_INC_UPT_TGFPRO_REFERENCIA.SQL) | BEFORE ROW INSERT OR UPDATE | DISABLED | 07/12/2021 | 03/07/2024 | 75 | instalação |
| [`TRG_UPD_TGFPRO_LOG`](TRG_UPD_TGFPRO_LOG.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 54 | instalação |
| [`TRG_UPD_TGFPRO_TGFVOA`](TRG_UPD_TGFPRO_TGFVOA.SQL) | AFTER ROW UPDATE | ENABLED | 24/02/2023 | 08/01/2025 | 47 | pontual (a confirmar) |

### `TGFEST` (6 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_INC_UPD_DLT_TGFEST_EC`](TRG_INC_UPD_DLT_TGFEST_EC.SQL) | BEFORE ROW INSERT OR UPDATE OR DELETE | ENABLED | 04/04/2023 | 27/02/2025 | 19 | lote 04/04/2023 |
| [`TRG_INC_UPD_TGFEST_BAR`](TRG_INC_UPD_TGFEST_BAR.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 46 | instalação |
| [`TRG_INC_UPD_TGFEST_ROUND`](TRG_INC_UPD_TGFEST_ROUND.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 06/09/2023 | 03/07/2024 | 19 | pontual (a confirmar) |
| [`TRG_INC_UPD_TGFEST_TGFGXE`](TRG_INC_UPD_TGFEST_TGFGXE.SQL) | AFTER ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/02/2022 | 23 | instalação |
| [`TRG_INC_UPT_TGFEST_BAR_TRANSF`](TRG_INC_UPT_TGFEST_BAR_TRANSF.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 93 | instalação |
| [`TRG_INC_UPT_TGFEST_CODBARRA`](TRG_INC_UPT_TGFEST_CODBARRA.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 143 | instalação |

### `TGFPAR` (5 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFPAR`](TRG_DLT_TGFPAR.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 19/09/2025 | 124 | instalação |
| [`TRG_FX_TGFPAR`](TRG_FX_TGFPAR.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 24/02/2023 | 03/07/2024 | 32 | pontual (a confirmar) |
| [`TRG_INC_UPD_TGFPAR_AFTER`](TRG_INC_UPD_TGFPAR_AFTER.SQL) | AFTER ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 12/01/2026 | 27 | instalação |
| [`TRG_INC_UPD_TGFPAR_EC`](TRG_INC_UPD_TGFPAR_EC.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 04/04/2023 | 28/09/2026 | 49 | lote 04/04/2023 |
| [`TRG_INS_UPD_TGFPAR_FLEX`](TRG_INS_UPD_TGFPAR_FLEX.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 36 | instalação |

### `TGFVAR` (4 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFVAR`](TRG_DLT_TGFVAR.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 20 | instalação |
| [`TRG_DLT_TGFVAR_AFTER`](TRG_DLT_TGFVAR_AFTER.SQL) | AFTER STATEMENT DELETE | ENABLED | 07/12/2021 | 21/09/2026 | 34 | instalação |
| [`TRG_INC_TGFVAR_BLOQ_SAFRA`](TRG_INC_TGFVAR_BLOQ_SAFRA.SQL) | BEFORE ROW INSERT | ENABLED | 07/12/2021 | 03/07/2024 | 69 | instalação |
| [`TRG_INC_UPD_DEL_TGFVAR_CFIDEL`](TRG_INC_UPD_DEL_TGFVAR_CFIDEL.SQL) | BEFORE ROW INSERT OR UPDATE OR DELETE | ENABLED | 07/12/2021 | 21/09/2026 | 121 | instalação |

### `TSICID` (3 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TSICID`](TRG_DLT_TSICID.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 03/07/2024 | 38 | instalação |
| [`TRG_FX_TSICID`](TRG_FX_TSICID.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 24/02/2023 | 03/07/2024 | 35 | pontual (a confirmar) |
| [`TRG_INC_UPD_TSICID_SITE`](TRG_INC_UPD_TSICID_SITE.SQL) | BEFORE ROW INSERT OR UPDATE | DISABLED | 07/12/2021 | 28/09/2026 | 8 | instalação |

### `TGFCUS` (3 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_UPD_TGFCUS`](TRG_DLT_UPD_TGFCUS.SQL) | BEFORE ROW UPDATE OR DELETE | ENABLED | 01/07/2022 | 03/07/2024 | 20 | lote 01/07/2022 |
| [`TRG_INC_UPD_TGFCUS`](TRG_INC_UPD_TGFCUS.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 15 | instalação |
| [`TRG_INC_UPD_TGFCUS_DATA_LAKE`](TRG_INC_UPD_TGFCUS_DATA_LAKE.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 19/09/2025 | 19/09/2025 | 6 | lote 19/09/2025 |

### `TGFSER` (2 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TGFSER`](TRG_DLT_TGFSER.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 20/04/2026 | 54 | instalação |
| [`TRG_INC_TGFSER`](TRG_INC_TGFSER.SQL) | BEFORE ROW INSERT | ENABLED | 07/12/2021 | 19/09/2025 | 81 | instalação |

### `TPRLPA` (2 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_DLT_TPRLPA`](TRG_DLT_TPRLPA.SQL) | BEFORE ROW DELETE | ENABLED | 07/12/2021 | 24/02/2023 | 55 | instalação |
| [`TRG_INC_TPRLPA`](TRG_INC_TPRLPA.SQL) | BEFORE ROW INSERT | ENABLED | 03/07/2024 | 24/04/2026 | 65 | lote 03/07/2024 |

### `TPRAPA` (1 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_INC_UPD_DLT_TPRAPA`](TRG_INC_UPD_DLT_TPRAPA.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/02/2022 | 12 | instalação |

### `TGFMDC` (1 capturadas)

| Trigger | Evento | Estado | Criada | Alterada | Linhas | Origem |
|---|---|---|---|---|---|---|
| [`TRG_INC_UPD_TGFMDC`](TRG_INC_UPD_TGFMDC.SQL) | BEFORE ROW INSERT OR UPDATE | ENABLED | 07/12/2021 | 03/07/2024 | 30 | instalação |

### Pendentes de recaptura (57)

O primeiro lote devolveu o DDL **truncado em 4000 caracteres** para estas triggers (o client converteu o CLOB para `VARCHAR2(4000)`), então elas **não foram gravadas**. Recaptura em pedaços: `scripts/CAPTURA_DDL_NATIVOS_LOTE1B.SQL`. Os arquivos atuais `TRG_INC_TGFITE.SQL` e `TRG_INC_TGFVAR.SQL` (capturas anteriores, completas) seguem valendo até lá — mas a versão do banco de `TRG_INC_TGFITE` foi alterada em 21/09/2026 e precisa ser comparada.

`TRG_DLT_TGFCAB`, `TRG_DLT_TGFFIN`, `TRG_DLT_TGFITE`, `TRG_DLT_TGFITE_AFTER`, `TRG_DLT_TGFITE_FLEX`, `TRG_FX_TGFPRO`, `TRG_INC_TGFCAB`, `TRG_INC_TGFCAB_EC`, `TRG_INC_TGFFIN`, `TRG_INC_TGFITE`, `TRG_INC_TGFITE_FLEX`, `TRG_INC_TGFPAR`, `TRG_INC_TGFVAR`, `TRG_INC_UPD_DLT_TGFFIN_SSPMB`, `TRG_INC_UPD_DLT_TGFITE_DAV`, `TRG_INC_UPD_DLT_TGFITE_ESE`, `TRG_INC_UPD_DLT_TGFITE_ESTTERC`, `TRG_INC_UPD_DLT_TGFITE_RASTEST`, `TRG_INC_UPD_DLT_TGFITE_RASTST`, `TRG_INC_UPD_TGFCAB_CERTIFIC`, `TRG_INC_UPD_TGFCAB_ORD`, `TRG_INC_UPD_TGFFIN_CERTIFIC`, `TRG_INC_UPD_TGFFIN_MONIOCOREM`, `TRG_INC_UPD_TGFITE_CERTIFIC`, `TRG_INC_UPD_TGFITE_PRODNFE`, `TRG_INC_UPD_TGFITE_RASTEST`, `TRG_INC_UPD_TGFITE_TGAMOV`, `TRG_INC_UPD_TGFITE_TRANSG`, `TRG_INC_UPD_TGFPRO`, `TRG_INC_UPD_TGFVAR`, `TRG_INC_UPT_DLT_TGFCAB_FEC_CTB`, `TRG_INC_UPT_DLT_TGFCAB_INDENIZ`, `TRG_INC_UPT_DLT_TGFCUS_FEC_CTB`, `TRG_INC_UPT_DLT_TGFFIN_FEC_CTB`, `TRG_INC_UPT_DLT_TGFITE_FEC_CTB`, `TRG_INC_UPT_TGFFIN_STATUSNFE`, `TRG_I_U_D_1_TGFPRO_LOG`, `TRG_I_U_D_2_TGFPRO_LOG`, `TRG_I_U_D_3_TGFPRO_LOG`, `TRG_I_U_D_4_TGFPRO_LOG`, `TRG_I_U_D_5_TGFPRO_LOG`, `TRG_TGFFIN_INC_UPD_AFT_TIMFK`, `TRG_TGFFIN_TIM_BAIXA_CJMD_AFT`, `TRG_UPD_TGFCAB`, `TRG_UPD_TGFCAB_EST`, `TRG_UPD_TGFCAB_FLEX`, `TRG_UPD_TGFCAB_METAS`, `TRG_UPD_TGFEST`, `TRG_UPD_TGFFIN_GRAVAR_AFT`, `TRG_UPD_TGFFIN_TIMDTREPASSE`, `TRG_UPD_TGFITE_FLEX`, `TRG_UPD_TGFPAR`, `TRG_UPD_TGFPAR_LOG`, `TRG_UPT_TGFEST_AFTER`, `TRG_UPT_TGFFIN`, `TRG_UPT_TGFITE_AFTER`, `TRG_UPT_TGFVAR`

---

## `TRG_INC_TGFITE`

**Arquivo:** `TRG_INC_TGFITE.SQL`  
**Tabela:** `TGFITE` (itens de nota/movimento)  
**Evento:** `BEFORE INSERT`  
**Escopo:** `FOR EACH ROW`  

**Descrição:** Trigger nativa de inclusão de item de nota, com lógicas de validação e controle de estoque. Executa antes de cada inserção de linha em `TGFITE`.

**Responsabilidades:**

1. **Validação de agrupamento mínimo (`AGRUPMIN`):** Verifica se a quantidade inserida respeita o agrupamento mínimo definido para o produto. Calcula o resto da divisão e ajusta se necessário.

2. **Controle de lote:** Verifica o tamanho de lote padrão (`TPRLPA`) e valida se a quantidade está dentro dos limites.

3. **Validação de estoque:** Consulta o grupo do produto para verificar o tipo de validação de estoque (`VALEST`).

4. **Validação de CFOP:** Verifica se o CFOP configurado na TOP está correto para a operação de entrada ou saída.

5. **Validações de IPI:** Verifica se o produto possui IPI em vendas (`P_TEMIPIVENDA`) e compras (`P_TEMIPICOMPRA`) para aplicação correta.

6. **Controle de reserva:** Verifica se a TOP exige reserva de estoque (`P_RESERVADO_TOP`).

**Variáveis declaradas (principais):**

| Variável | Tipo | Uso |
|---|---|---|
| `P_VALEST` | `TGFGRU.VALEST%TYPE` | Tipo de validação de estoque do grupo |
| `P_AGRUPMIN` | `FLOAT` | Agrupamento mínimo do produto |
| `P_TAMLOTEPAD` | — | Tamanho de lote padrão |
| `P_CFOSAIDA` | `TGFTOP.CODCFO_SAIDA%TYPE` | CFOP de saída configurado na TOP |
| `P_CFOENTRADA` | `TGFTOP.CODCFO_ENTRADA%TYPE` | CFOP de entrada configurado na TOP |
| `P_RESERVADO_TOP` | `CHAR` | Indica se a TOP exige reserva |

### Customização da Spark — pendente de delimitação

O cabeçalho do arquivo diz que a trigger tem "customizações adicionadas pela Spark" (agrupamento mínimo, estoque por TOP, CFOP de transferência, IPI), mas **o arquivo não marca quais linhas são da Spark**: não há comentário `-- SPARK`, e as demais referências a OS no cabeçalho (717072, 748512, 756293, 823336, 902640, 954116) são numeração de chamados da Sankhya. Além disso, `AGRUPMIN`, `VALIDAAGRUPMIN` e a lógica de CFOP de transferência são recursos nativos do ERP — então a lista do cabeçalho pode descrever o que a trigger *faz*, e não o que a Spark *alterou*. O histórico do git não ajuda: o arquivo nunca foi versionado antes.

**Consequência:** hoje não é possível reaplicar a customização depois de um upgrade que sobrescreva a trigger — o único jeito seria reler o arquivo inteiro e adivinhar.

**Para fechar a pendência (precisa de quem conhece a alteração):**

1. Obter a versão original do fabricante da `TRG_INC_TGFITE` — pelo suporte Sankhya, por um ambiente sem customização, ou pelo `DBA_SOURCE`/backup anterior à alteração, se existir.
2. Gerar o diff entre a original e a atual e salvar como `triggers/patches/TRG_INC_TGFITE.patch` (pasta versionada, código da Spark) — é esse patch que se reaplica após cada upgrade.
3. Marcar as linhas alteradas no arquivo com `-- SPARK:` e corrigir o cabeçalho para listar apenas o que foi realmente alterado.
4. Atualizar esta seção e o §14 de `triggers/README.md`.

Até lá, vale a regra do "Como Manter" abaixo: comparar com o banco após cada upgrade e tratar qualquer diferença como suspeita.

---

## `TRG_INC_TGFVAR`

**Arquivo:** `TRG_INC_TGFVAR.SQL`
**Tabela:** `TGFVAR` (variações de nota — atendimento/entrega parcial)
**Evento:** `BEFORE INSERT`
**Escopo:** `FOR EACH ROW`
**Customização Spark:** Nenhuma — trigger 100% nativa, documentada aqui só por referência/impacto.

**Descrição:** Processa a inclusão de uma "nota de variação" (mecanismo nativo do Sankhya para atendimento/entrega/devolução parcial de um item). Dispara com `WHEN ((NEW.SEQUENCIA <> 0) AND (NEW.SEQUENCIAORIG <> 0) AND (NEW.QTDATENDIDA <> 0))`.

**Responsabilidades:**

1. Sai cedo durante sincronização de dados (`STP_GET_ATUALIZANDO`) ou quando `Fpodevalidar('TGFVAR')` indica que a validação não deve rodar.
2. Valida que a nota atual e a nota de origem (`NUNOTAORIG`/`SEQUENCIAORIG`) existem em `TGFITE`/`TGFCAB`.
3. **Atualiza o item de origem em `TGFITE`** (`QTDENTREGUE` e `QTDFIXADA`) proporcionalmente à quantidade atendida (`:NEW.QTDATENDIDA`) — esse é o único ponto em que esta trigger toca `TGFITE`, e é ele quem dispara, em cascata, qualquer trigger de `TGFITE` (ex.: `TRG_VAL_CSTIPI_SPARK`) para o item de origem.
4. Duplica/realoca compromissos financeiros/orçamentários em `TGMTRA` quando a nota de origem tem compromisso vinculado (`TIPO = 'C'`), incluindo troca de `NUMTRANSF` via `SNK_VERIFICA_PK_TGMTRA`/`STP_TROCA_NUMTRANSF` quando necessário.

**Observação de incidente (Set/2026):** o `UPDATE TGFITE` do item 3 acima **não escreve em `CSTIPI`** — ele preserva o valor já existente no item de origem. Se esse item tiver `CSTIPI` nulo/zero, qualquer trigger de validação de `TGFITE` sem cláusula `OF <coluna>` (ex.: `TRG_VAL_CSTIPI_SPARK`, quando ativa) dispara sobre essa atualização de rotina, mesmo sem nenhuma mudança de CST IPI envolvida. Ver `triggers/README.md` §15 para o caso completo.

---

## Como Manter

1. Após cada atualização do Sankhya, comparar cada arquivo desta pasta com a trigger vigente no banco via: `SELECT TEXT FROM DBA_SOURCE WHERE NAME = '<NOME_DA_TRIGGER>' ORDER BY LINE` (ex.: `TRG_INC_TGFITE`, `TRG_INC_TGFVAR`)
2. Identificar se as customizações (quando houver) ainda estão presentes
3. Se a atualização sobrescreveu, reaplicar as customizações e atualizar este arquivo
4. Antes de qualquer `CREATE OR REPLACE` numa trigger nativa, confirmar `STATUS` em `USER_TRIGGERS` — o Oracle sempre recria como `ENABLED`, então uma trigger nativa desativada por algum motivo de negócio pode ser reativada sem querer (ver `triggers/README.md` §15)
5. Commitar a nova versão com a nota da versão do ERP no commit message
