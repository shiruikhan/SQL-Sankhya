package br.com.spark.transferencia.util;

/**
 * <b>Nome:</b> TransferenciaUtils<br>
 * <b>Tipo:</b> Classe utilitária (static helpers)<br>
 * <b>Descrição:</b> Centraliza todos os métodos de suporte ao processo de transferência
 * entre empresas executado por {@link br.com.spark.transferencia.GerarTransferencia}.
 * Agrupa validações de pré-condição, construtores de VO, geração de séries,
 * confirmação de nota e envio de lote NF-e.
 *
 * <p><b>Métodos principais:</b></p>
 * <ul>
 *   <li>{@code ehPedido}          — valida se a nota é TIPMOV='P' (pedido de venda)</li>
 *   <li>{@code ehGerada}          — valida se já foi gerada transferência para a nota</li>
 *   <li>{@code validaConferencia} — valida se a conferência está finalizada (status 'F')</li>
 *   <li>{@code buildCabecalho}    — cria o VO de cabeçalho da nota de transferência</li>
 *   <li>{@code buildItens}        — cria a coleção de itens para a nota de transferência,
 *                                   copiando impostos da nota de origem</li>
 *   <li>{@code gerarSerie}        — copia séries de produtos da nota de origem para a destino</li>
 *   <li>{@code salvarOrigem}      — vincula pedido, saída e entrada via AD_NUNOTASAI/AD_NUNOTAENT</li>
 *   <li>{@code confirmaNota}      — confirma a nota via {@code ConfirmacaoNotaHelper}</li>
 *   <li>{@code gerarLote}         — envia lote NF-e via {@code ServicosNFeHelper2}</li>
 *   <li>{@code getLinkNota}       — gera link HTML para abertura da nota no Sankhya</li>
 * </ul>
 *
 * <p><b>Queries SQL auxiliares:</b> queItem.sql, queSerie.sql (carregadas via NativeSql.loadSql)</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 2.0
 * @since 2023
 * @see br.com.spark.transferencia.GerarTransferencia
 * @see br.com.spark.transferencia.enuns.Tipo
 */
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collection;

import com.sankhya.util.Base64Impl;
import com.sankhya.util.BigDecimalUtil;
import com.sankhya.util.JdbcUtils;
import com.sankhya.util.TimeUtils;

import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.core.JapeSession.SessionHandle;
import br.com.sankhya.jape.dao.JdbcWrapper;
import br.com.sankhya.jape.sql.NativeSql;
import br.com.sankhya.jape.util.FinderWrapper;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.vo.PrePersistEntityState;
import br.com.sankhya.jape.wrapper.JapeFactory;
import br.com.sankhya.jape.wrapper.JapeWrapper;
import br.com.sankhya.modelcore.MGEModelException;
import br.com.sankhya.modelcore.auth.AuthenticationInfo;
import br.com.sankhya.modelcore.comercial.BarramentoRegra;
import br.com.sankhya.modelcore.comercial.CentralFaturamento;
import br.com.sankhya.modelcore.comercial.ComercialUtils;
import br.com.sankhya.modelcore.comercial.ConfirmacaoNotaHelper;
import br.com.sankhya.modelcore.comercial.nfe.DocumentoEletronicoHelper;
import br.com.sankhya.modelcore.comercial.nfe.ServicosNFeHelper2;
import br.com.sankhya.modelcore.helper.ConferenciaHelper;
import br.com.sankhya.modelcore.util.CentralNotasUtil;
import br.com.sankhya.modelcore.util.DynamicEntityNames;
import br.com.sankhya.modelcore.util.EntityFacadeFactory;
import br.com.sankhya.modelcore.util.MGECoreParameter;
import br.com.sankhya.util.troubleshooting.SKError;
import br.com.sankhya.util.troubleshooting.TSLevel;
import br.com.spark.transferencia.enuns.Tipo;
import  br.com.sankhya.mgecomercial.model.facades.ServicosNfeSPBean;
import br.com.sankhya.mgecomercial.model.facades.helpper.EnvioNotaSefazHelper;

public class TransferenciaUtils {

	public static void validaConferencia(DynamicVO cabVO) throws MGEModelException {
		JapeSession.SessionHandle hnd = null;		
		try {
			EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
			JdbcWrapper conn = ewf.getJdbcWrapper();
			DynamicVO topVO = cabVO.asDymamicVO(DynamicEntityNames.TIPO_OPERACAO);
			ConferenciaHelper confHelper = new ConferenciaHelper(cabVO);
			String status = confHelper.getStatusConferenciaAtual();
		    if (status == null)
		    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_E04652", new Exception(String.format("\n Conferência exigida pela TOP %s ainda não realizada. (Nro. = %s)", new Object[] { topVO.asBigDecimal("CODTIPOPER"), cabVO.asBigDecimal("NUNOTA") }))); 
		    if (!"F".equals(status))
		        throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_E04651", new Exception(String.format("\n O status atual da conferência ainda não permite o faturamento (Nro = %s)", new Object[] { cabVO.asBigDecimal("NUNOTA") }))); 
		    try {
			    if (confHelper.existeProdutosSujeitosAConferencia(conn, cabVO.asBigDecimal("NUNOTA"))) {
			    String statusConf = confHelper.verificarConferenciaFinalizada();
			    if (!"F".equals(statusConf))
			    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_E04653", new Exception(String.format("\n Conferência finalizada, mas não confere com os itens do pedido ou nota %s.", new Object[] { cabVO.asBigDecimal("NUNOTA") }))); 
			    }		    	
		    }finally {
				JdbcWrapper.closeSession(conn);				
			}
		}catch(Exception e) {
			MGEModelException.throwMe(e);  
		}finally {
			JapeSession.close(hnd);
		}      
	}
	
	public static void ehPedido(DynamicVO cabVO) throws Exception {
		 BigDecimal nuNota = cabVO.asBigDecimal("NUNOTA");
		if(!"P".equals(cabVO.asString("TIPMOV")))
			throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lançamento de Nro. único: " + nuNota + " não é um Pedido de Venda, impossível continuar")); 	
	}
	
	public static void ehGerada(DynamicVO cabVO) throws Exception {		
		 BigDecimal nuNota = cabVO.asBigDecimal("NUNOTA");
		 if(cabVO.asBigDecimalOrZero("AD_NUNOTASAI").intValue() > 0) {
		    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lançamento de Nro. único: " + nuNota + " já gerou uma Transferência de Saída, impossível continuar")); 
	        }else if(cabVO.asBigDecimalOrZero("AD_NUNOTAENT").intValue() > 0) {
		    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lançamento de Nro. único: " + nuNota + " já gerou uma Transferência de Entrada, impossível continuar")); 
	        }
	}
	
	public static DynamicVO buildCabecalho(DynamicVO modelVO, BigDecimal codEmp , BigDecimal codEmpParc ) throws MGEModelException {		
		JapeSession.SessionHandle hnd = null;
		try {
			EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
            BigDecimal codParc = queryBigDecimal("CODPARC", "TSIEMP", "CODEMP = " + codEmpParc);
			DynamicVO topVO = modelVO.asDymamicVO(DynamicEntityNames.TIPO_OPERACAO);
			DynamicVO transfenciaVO = (DynamicVO) ewf.getDefaultValueObjectInstance(DynamicEntityNames.CABECALHO_NOTA);
			transfenciaVO.setProperty("CODEMP", codEmp);
			transfenciaVO.setProperty("CODPARC", codParc);
			transfenciaVO.setProperty("CODTIPOPER", modelVO.asBigDecimal("CODTIPOPER"));
			transfenciaVO.setProperty("CODTIPVENDA", modelVO.asBigDecimal("CODTIPVENDA"));
			transfenciaVO.setProperty("TIPMOV",  topVO.asString("TIPMOV"));
			transfenciaVO.setProperty("SERIENOTA",  modelVO.asString("SERIENOTA"));
			transfenciaVO.setProperty("DTNEG",  TimeUtils.getNow());
			transfenciaVO.setProperty("DTFATUR",  TimeUtils.getNow());
			transfenciaVO.setProperty("CODNAT",  modelVO.asBigDecimal("CODNAT"));
			transfenciaVO.setProperty("CODCENCUS",  modelVO.asBigDecimal("CODCENCUS"));
			transfenciaVO.setProperty("CODPROJ",  modelVO.asBigDecimal("CODPROJ"));
			transfenciaVO.setProperty("AD_VOLCONFERE",  "S");
			if("V".equals(topVO.asString("TIPMOV")))
				transfenciaVO.setProperty("CIF_FOB", "S");
			
			return transfenciaVO;
		}catch(Exception e) {
			MGEModelException.throwMe(e);  
		}finally {
			JapeSession.close(hnd);
		}
		return null; 
	}
	
	/**
	 * @param copiarImpostos true quando a nota de origem já tem impostos calculados e devem ser
	 *                       espelhados (entrada ← saída). false para a saída, onde o ImpostosHelpper
	 *                       recalcula do zero com base na TOP de transferência.
	 */
	public static Collection<PrePersistEntityState> buildItens(BigDecimal nuNota, BigDecimal localOrigem, boolean copiarImpostos) throws MGEModelException{
		JapeSession.SessionHandle hnd = null;
		Collection<PrePersistEntityState> itensNota = new ArrayList();
		try {
			EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
			FinderWrapper finder = new FinderWrapper("ItemNota","this.NUNOTA = " + nuNota);
			finder.setOrderBy("SEQUENCIA ASC");
			Collection<DynamicVO> produtosVo = ewf.findByDynamicFinderAsVO(finder);
	        if (produtosVo.size() < 1) {
	            throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("Não foram Localizados Produtos para Geração da Transferência"));
	        } else {
	        	 BigDecimal codEmp =  BigDecimal.ONE;
	        	 if (((Boolean)MGECoreParameter.getParameter("controla.custo.empresa")).booleanValue())
	                  codEmp = queryBigDecimal("CODEMP", "TGFCAB", "NUNOTA = " + nuNota);
		    	 for (DynamicVO iteVO : produtosVo) {
	            	 DynamicVO itemVO;
	            	 itemVO =(DynamicVO)ewf.getDefaultValueObjectInstance("ItemNota");
	            	 itemVO.setProperty("CODPROD", iteVO.asBigDecimal("CODPROD"));
	            	 itemVO.setProperty("QTDNEG",  iteVO.asBigDecimal("QTDNEG").subtract(iteVO.asBigDecimal("QTDCONFERIDA")).subtract(iteVO.asBigDecimal("QTDENTREGUE")));
	            	 itemVO.setProperty("VLRUNIT", getCustoSpark(iteVO.asBigDecimal("CODPROD")));
	            	 itemVO.setProperty("CODVOL",  iteVO.asString("CODVOL"));
	            	 itemVO.setProperty("CODLOCALORIG",localOrigem);
	            	 itemVO.setProperty("CONTROLE",iteVO.asString("CONTROLE"));
	            	 if (copiarImpostos) {
	            	 	itemVO.setProperty("CODTRIB", iteVO.asBigDecimal("CODTRIB"));
	            	 	itemVO.setProperty("CSTIPI", BigDecimalUtil.valueOf(iteVO.asBigDecimal("BASEIPI").floatValue() > 0 ? 49 : 1 ));
	            	 	itemVO.setProperty("ALIQICMS", iteVO.asBigDecimal("ALIQICMS"));
	            	 	itemVO.setProperty("BASEICMS", iteVO.asBigDecimal("BASEICMS"));
	            	 	itemVO.setProperty("VLRICMS", iteVO.asBigDecimal("VLRICMS"));
	            	 	itemVO.setProperty("BASEIPI", iteVO.asBigDecimal("BASEIPI"));
	            	 	itemVO.setProperty("VLRIPI", iteVO.asBigDecimal("VLRIPI"));
	            	 	itemVO.setProperty("ALIQIPI", iteVO.asBigDecimal("ALIQIPI"));
	            	 }
	            	 PrePersistEntityState itePreState = PrePersistEntityState.build(ewf, "ItemNota", itemVO);
					 itensNota.add(itePreState);
				}
		   }
		}catch(Exception e) {
			MGEModelException.throwMe(e);
		}finally {
			JapeSession.close(hnd);
		}
		return itensNota;
	}
	
	public static void salvarOrigem(BigDecimal nuNotaPed, BigDecimal nuNotaSai, BigDecimal nuNotaEnt, Tipo tp) throws MGEModelException {		
		JapeSession.SessionHandle hnd = null;
		try {
			if(tp.equals(Tipo.PEDIDO)) {
				 JapeFactory.dao(DynamicEntityNames.CABECALHO_NOTA)
				            .prepareToUpdateByPK(nuNotaPed)
				            .set("AD_NUNOTASAI", nuNotaSai)
				            .set("AD_NUNOTAENT", nuNotaEnt)
					        .update();				
			}else if (tp.equals(Tipo.SAIDA)) {
				 JapeFactory.dao(DynamicEntityNames.CABECALHO_NOTA)
				            .prepareToUpdateByPK(nuNotaSai)
				            .set("AD_PEDTRANSF", nuNotaPed)
				            .set("AD_NUNOTAENT", nuNotaEnt)
					        .update();
			}else if (tp.equals(Tipo.ENTRADA)) {
				 JapeFactory.dao(DynamicEntityNames.CABECALHO_NOTA)
				            .prepareToUpdateByPK(nuNotaEnt)
				            .set("AD_PEDTRANSF", nuNotaPed)
				            .set("AD_NUNOTASAI", nuNotaSai)
					        .update();
			}else {
		    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("Não foi possível salvar a origem pois o tipo de movimento não foi encontrado!"));
		    }
		}catch(Exception e) {
			MGEModelException.throwMe(e);  
		}finally{
			JapeSession.close(hnd);
		}
	}
	
	public static BigDecimal getCustoSpark(BigDecimal codprod) throws Exception {
        return queryBigDecimal("FC_GETPRECO_TRASF_SP("+codprod+")", "DUAL", "1 = 1");
	}
	
	private static BigDecimal queryBigDecimal(String campo, String tabela, String where) throws MGEModelException {
		JapeSession.SessionHandle hnd = null;
		NativeSql ns = null;
		ResultSet rs = null;
		JdbcWrapper jdbc = null;
		try {
			jdbc = EntityFacadeFactory.getDWFFacade().getJdbcWrapper();
			ns = new NativeSql(jdbc);
			ns.appendSql("SELECT " + campo + " FROM " + tabela + " WHERE " + where);
			rs = ns.executeQuery();
			if (rs.next()) {
				return rs.getBigDecimal(1);
			}
			return null;
		} catch (Exception e) {
			MGEModelException.throwMe(e);
		} finally {
			JdbcUtils.closeResultSet(rs);
			NativeSql.releaseResources(ns);
			JapeSession.close(hnd);
		}
		return null;
	}
	
    public static void gerarSerie(BigDecimal origem, BigDecimal destino) throws MGEModelException {
    	JapeSession.SessionHandle hnd = null;
    	NativeSql queItem = null;
    	ResultSet rsItem = null;
    	JdbcWrapper jdbc;
    	try {
    		jdbc = EntityFacadeFactory.getDWFFacade().getJdbcWrapper();
    		queItem = new NativeSql(jdbc);
    		queItem.loadSql(TransferenciaUtils.class, "queItem.sql");
    		queItem.setNamedParameter("NUNOTA", origem);
    		rsItem = queItem.executeQuery();
    		while(rsItem.next()) {    			
    			NativeSql queSerie = new NativeSql(jdbc);
    			queSerie.loadSql(TransferenciaUtils.class, "queSerie.sql");
    			queSerie.setNamedParameter("NUNOTA", origem);
    			queSerie.setNamedParameter("SEQUENCIA", rsItem.getBigDecimal("SEQUENCIA"));
    			queSerie.setNamedParameter("CODPROD", rsItem.getBigDecimal("CODPROD"));
        		ResultSet rsSerie = queSerie.executeQuery();
        		while(rsSerie.next()) {   
                    JapeWrapper dao = JapeFactory.dao("SerieProduto");
                    DynamicVO serieVO = dao.create()
                    		           .set("NUNOTA", destino)
                                       .set("CODPROD", rsSerie.getBigDecimal("CODPROD"))
									   .set("SEQUENCIA", rsSerie.getBigDecimal("SEQUENCIA"))
                                       .set("SERIE", rsSerie.getString("SERIE"))
									   .set("ATUALESTOQUE", rsSerie.getBigDecimal("ATUALESTOQUE"))   
                                       .save();              
        		}
    			JdbcUtils.closeResultSet(rsSerie);
        		NativeSql.releaseResources(queSerie);   			
    		}
    		JapeWrapper dao = JapeFactory.dao("SerieProduto");
    	}catch(Exception e) {
			MGEModelException.throwMe(e);  
		}finally{
			JdbcUtils.closeResultSet(rsItem);
			NativeSql.releaseResources(queItem);
			JapeSession.close(hnd);
		}
    }
    
    public static  void confirmaNota(BigDecimal nuNota) throws MGEModelException {
        Collection<BigDecimal> lisNotasConfirmadas = new ArrayList<>();
        JapeSession.SessionHandle hnd = null;
        try {
        	 hnd = JapeSession.open();
        	 hnd.execWithTX( new JapeSession.TXBlock(){
         		public void doWithTx() throws Exception{
	        	 BarramentoRegra barramentoConfirmacao = BarramentoRegra.build(CentralFaturamento.class, "regrasConfirmacaoSilenciosa.xml", AuthenticationInfo.getCurrent());
	        	 barramentoConfirmacao.setValidarSilencioso(true);
	        	 ConfirmacaoNotaHelper.confirmarNota(nuNota, barramentoConfirmacao);
         	}});	 
         }catch(Exception e) {
			try { 
				throw new JapeSession.CanceledTransactionException();
			}catch(Exception ex) {
				MGEModelException.throwMe(ex); 
			}
		 }finally {
			JapeSession.close(hnd);
		 } 
    }
    
    public static  void gerarLote(Collection <BigDecimal> notas) throws MGEModelException {
        Collection<BigDecimal> lisNotasConfirmadas = new ArrayList<>();
        try {
        	   ServicosNFeHelper2 nfeHelper = ServicosNFeHelper2.build();
        	   nfeHelper.gerarLotes(notas, false, true);
        }catch(Exception ex) {
				MGEModelException.throwMe(ex); 
		} 
    }
    
    public static  void gerarLote_v3(Collection <BigDecimal> notas) throws MGEModelException {
        Collection<BigDecimal> lisNotasConfirmadas = new ArrayList<>();
        JapeSession.SessionHandle hnd = null;
        try {
        	 hnd = JapeSession.open();
        	 hnd.execWithTX( new JapeSession.TXBlock(){
         		public void doWithTx() throws Exception{
	        	 EnvioNotaSefazHelper nf = new EnvioNotaSefazHelper();
	        	 nf.gerarLoteNotas(notas);
         	}});	 
         }catch(Exception e) {
			try { 
				e.printStackTrace();
				throw new JapeSession.CanceledTransactionException();
			}catch(Exception ex) {
				MGEModelException.throwMe(ex); 
			}
		 }finally {
			JapeSession.close(hnd);
		 } 
    }
    
    public static  void confirmaNota_v2(BigDecimal nuNota) throws MGEModelException {
        Collection<BigDecimal> lisNotasConfirmadas = new ArrayList<>();
        JapeSession.SessionHandle hnd = null;
        try {
        	 hnd = JapeSession.open();
        	 BarramentoRegra barramento = BarramentoRegra.build(TransferenciaUtils.class, "regrasConfirmacaoCAC.xml", AuthenticationInfo.getCurrent());
			 ConfirmacaoNotaHelper.confirmarNota(nuNota, barramento);
        }catch(Exception e) {
        	MGEModelException.throwMe(e);
        }finally{
        	 JapeSession.close(hnd);
        }
    }
    
    public static void confirmaNota_v1(Collection<BigDecimal> lisNotasNaoConfirmadas) throws MGEModelException {
    	String sessaoNotas = null;
        Collection<BigDecimal> lisNotasConfirmadas = new ArrayList<>();
        JapeSession.SessionHandle hnd = null;
        try {
        	hnd = JapeSession.open();
            sessaoNotas = CentralNotasUtil.registrarSessaoNotas(lisNotasNaoConfirmadas);
        	DocumentoEletronicoHelper.confirmarCompensarNotas(hnd, lisNotasNaoConfirmadas, lisNotasConfirmadas);
        }catch(Exception e) {
        	MGEModelException.throwMe(e);
        }finally{
        	 CentralNotasUtil.finalizaSessao(sessaoNotas);
        	 JapeSession.close(hnd);
        }
    }
    
	public static String getLinkNota(final String descricao, final BigDecimal nuNota) {
        final String pk = "{\"NUNOTA\":\"{0}\"}".replace("{0}", nuNota.toString());
        String url = "<a title=\"Abrir Tela\" href=\"/mge/system.jsp#app/{0}/{1}\" target=\"_top\"><u><b>{2}</b></u></a>".replace("{0}", Base64Impl.encode("br.com.sankhya.com.mov.CentralNotas".getBytes()).trim());
        url = url.replace("{1}", Base64Impl.encode(pk.getBytes()).trim());
        url = url.replace("{2}", descricao);
        return url;
    }
}
