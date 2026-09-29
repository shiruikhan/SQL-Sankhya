/*==============================================================================
  Nome do Script : CHECK_STATUS_TRIGGERS_SPARK
  Tipo           : Script de consulta (não-DDL)
  Descrição      : Levanta o STATUS (ENABLED/DISABLED) atual de todas as
                   triggers customizadas Spark presentes no repositório
                   "triggers/", para servir de baseline ANTES de qualquer
                   CREATE OR REPLACE em novas rodadas de otimização.

                   Motivo: CREATE OR REPLACE TRIGGER sempre recria a trigger
                   como ENABLED, independente do estado anterior no banco.
                   Uma trigger DISABLED por decisão de negócio pode ser
                   reativada silenciosamente se isso não for checado antes
                   (foi a causa raiz de um incidente de produção em Set/2026 —
                   ver triggers/README.md §15).

  Como usar      : Rodar este SELECT (ou o script inteiro) ANTES de iniciar
                   cada lote do plano de melhoria de triggers. Qualquer linha
                   com STATUS = 'DISABLED' deve ser tratada como decisão de
                   negócio deliberada: NÃO alterar/recriar essa trigger sem
                   confirmação explícita do responsável pelo ambiente.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Setembro/2026
==============================================================================*/

SELECT t.owner
      ,t.table_name
      ,t.trigger_name
      ,t.status
      ,t.triggering_event
      ,t.trigger_type
  FROM all_triggers t
 WHERE t.trigger_name IN (
        'TRG_INS_UPD_CODLOCALDEST', -- renomeado de SPK_INS_UPD_CODLOCALDEST.SQL em 29/09/2026
        'SPK_INS_UPD_TGFCAB_AVISOPARC',
        'TRG_INS_UPD_TWFIVAR_CODIGONOVO', -- renomeado de SPK_INS_UPD_TWFIVAR_CODIGONOVO em 29/09/2026
        'TRG_TGFASS_INC_SPARK', -- renomeado de SPK_TGFASS_INC em 29/09/2026
        'TRG_TGFASS_INCUPD_SPARK', -- renomeado de SPK_TGFASS_INCUPD em 29/09/2026
        'SPK_TGFCAB_TSIBLOCK',
        'TRG_TGFFIN_LOG_SPARK', -- renomeado de SPK_TGFFIN_LOG em 29/09/2026
        'TRG_INS_TGFCUS_SPARK', -- renomeado de SPK_TRG_INS_TGFCUS em 29/09/2026
        -- (SPK_TRG_OSINTERNA removido: confirmado ausente do banco em 28/09/2026, movido para inativos/)
        'TRG_TGFCUS_SPARK', -- renomeado de SPK_TRG_TGFCUS em 29/09/2026
        'SPK_UPD_INS_TGFITE_CONSUMOPRD',
        'TRG_AD_EMBPED_SPARK',
        'TRG_APOQLD_INS_SPARK',
        'TRG_CMP_TGFCAB_NFE_SPARK',
        'TRG_CMP_TGFVAR_NUNOTASIT',
        'TRG_CMP_TRANFS_SPARK',
        'TRG_COTAFRETE_EMB_SPARK',
        'TRG_COTAFRETE_SPARK',
        'TRG_DEL_TGFCAB_CLEAN_SPARK',
        'TRG_DEL_TPRSERPA_SPARK3',
        'TRG_DLT_TGFSER_SPARK',
        'TRG_INCDEVCH_SPARK',
        'TRG_INC_AD_TGFFTA_SPARK',
        'TRG_INC_AD_TGSIXN_SPARK',
        'TRG_INC_TGFCAB_DC_SPARK',
        'TRG_INC_TGFIXN_EMAIL_SPARK',
        'TRG_INC_TGFPAR_SPARK',
        'TRG_INC_TGFSER_SPARK',
        'TRG_INC_TGFVAR_SPARK',
        'TRG_INC_TPRCOI_SPARK',
        'TRG_INC_TPRCOI_SPARK2',
        'TRG_INC_TPRLPA_SPARK',
        'TRG_INC_TPRSERPA_SPARK2',
        'TRG_INC_TSICID_SPARK',
        'TRG_INC_UPD_AD_TGSCMP_SPARK',
        'TRG_INC_UPD_AD_TGSIXN_SPARK',
        'TRG_INC_UPD_AD_TPRSERPA_SPARK',
        'TRG_INC_UPD_CMF_SPARK',
        'TRG_INC_UPD_DLT_TPRAPA_SPARK',
        'TRG_INC_UPD_DLT_TPRIPA_SPARK',
        'TRG_INC_UPD_INFCOLETA',
        'TRG_INC_UPD_TGFCAB_PREVENT',
        'TRG_INC_UPD_TGFCAB_PROD_SPARK',
        'TRG_INC_UPD_TGFITE_SPARK',
        'TRG_INC_UPD_TGFITE_SPARK2',
        'TRG_INC_UPD_TGFVAR_SPARK',
        'TRG_INC_UPD_TPRCONF_SPARK',
        'TRG_INC_UPD_TPRIMRP_SPARK',
        'TRG_INC_UPD_TPRIPROC_SPARK',
        'TRG_INC_UPD_TPRROPE_PROD_SPARK',
        'TRG_INC_UPT_TGFPRO_SPARK',
        'TRG_INS_OSSTATUS_SPARK',
        'TRG_SPKCAE_INC_SPARK',
        'TRG_SPKCAE_VLRCONSERTO_SPARK',
        'TRG_TGFASS_VLRCONSERTO_SPARK',
        'TRG_TGFCOI2_SPARK',
        'TRG_TGFCON2_SPARK',
        'TRG_TGFITE_SPARK1',
        'TRG_TGFNCT_SPARK',
        'TRG_TGSCAB_TRANSP_SPARK',
        'TRG_UPD_AD_TGSIXN_SPARK',
        'TRG_UPD_AVISOSPARK',
        'TRG_UPD_OSINTERNA',
        'TRG_UPD_OSINTERNA_DHFIM',
        'TRG_UPD_TGFCAB_DTFAT_SPARK',
        'TRG_UPD_TGFCAB_IMF_SPARK',
        'TRG_UPD_TGFCAB_TRANSP_SPARK',
        'TRG_UPD_TGFPAR_UF_SPARK',
        'TRG_UPD_TGSLOGLIB_SPARK',
        'TRG_UPT_TGFITE',
        'TRG_VAL_AD_CODFUNC_TPRAPA',
        'TRG_VAL_CSTIPI_SPARK',
        'TRG_VAL_SETOR_CODFUNC_TPRAPA',
        'TRG_ATUALIZA_STATUS_NUNOTA',
        'TRG_AVISOCONF_SPARK',
        'TRG_BLOQUEIA_DELETE_SC',
        'TRG_BLOQUEIA_EDICAO_STATUS_CR',
        'TRG_FRETE_CIF_MTKPL_SPARK',
        -- (TRG_INC_ATUALIZAATRIB_SPARK removido: confirmado ausente do banco em 28/09/2026, movido para inativos/)
        'TRG_INC_UPD_INTEGRA',
        'TRG_INC_UPD_TPRPRC_SPARK',
        'TRG_NOTIFICA_SOLIC_COMPRA',
        'TRG_NOTIF_PARCERIA_SPARK',
        'TRG_REFORCA_NAT_FIN',
        'TRG_STATUS_PADRAO_SC',
        'TRG_TPRCOI_REPLICA_PA',
        'TRG_UPD_DIFALPB_SPARK',
        'TRG_UPD_TGFCAB_MOEDA_SPARK2',
        'TRG_VALIDA_PRAZO_SC'
       )
 ORDER BY DECODE(t.status, 'DISABLED', 0, 1)
         ,t.table_name
         ,t.trigger_name;

/* Leitura do resultado:
   - STATUS = 'ENABLED'  -> comportamento normal, pode prosseguir com a
                            revisão de performance conforme o plano de lotes.
   - STATUS = 'DISABLED' -> PARAR. Registrar o nome aqui e tratar como as
                            3 triggers já catalogadas como inativas
                            (TRG_VAL_CSTIPI_SPARK, TRG_INC_TGFIXN_EMAIL_SPARK,
                            TRG_UPD_TGSLOGLIB_SPARK) antes de tocar no
                            arquivo .sql correspondente.
   - Sem linha retornada  -> trigger não existe (ou não existe mais) no
                            schema consultado; confirmar se o nome no banco
                            mudou ou se o objeto foi removido.
*/
