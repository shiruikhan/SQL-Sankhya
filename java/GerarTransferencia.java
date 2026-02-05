package br.com.spark.transferencia;

import br.com.sankhya.extensions.actionbutton.AcaoRotinaJava;
import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.Registro;
import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.core.JapeSession.SessionHandle;
import br.com.sankhya.jape.bmp.PersistentLocalEntity;
import br.com.sankhya.jape.util.JapeSessionContext;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.vo.EntityVO;
import br.com.sankhya.jape.vo.PrePersistEntityState;
import br.com.sankhya.modelcore.MGEModelException;
import br.com.sankhya.modelcore.auth.AuthenticationInfo;
import br.com.sankhya.modelcore.comercial.BarramentoRegra;
import br.com.sankhya.modelcore.comercial.centrais.CACHelper;
import br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper;
import br.com.sankhya.modelcore.util.DynamicEntityNames;
import br.com.sankhya.modelcore.util.EntityFacadeFactory;
import br.com.sankhya.util.troubleshooting.SKError;
import br.com.sankhya.util.troubleshooting.TSLevel;
import br.com.spark.transferencia.enuns.Tipo;
import br.com.spark.transferencia.util.TransferenciaUtils;
import com.sankhya.util.BigDecimalUtil;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map.Entry;

public class GerarTransferencia implements AcaoRotinaJava {
  int totalEntradas = 0;
  int qtdSaidaConfirmadas = 0;
  int qtdEntradaConfirmadas = 0;
  int qtdNFe = 0 ;
  
  public void doAction(ContextoAcao ctx) throws Exception {
    		
    BigDecimal codEmpOrig = BigDecimalUtil.valueOf((String)ctx.getParam("P_CODEMPORIG"));
    BigDecimal codEmpDestino = BigDecimalUtil.valueOf((String)ctx.getParam("P_CODEMPDEST"));
    BigDecimal codLocalOrig = BigDecimalUtil.valueOf( (String)ctx.getParam("P_CODLOCALORIG"));
    BigDecimal codLocalDestino = BigDecimalUtil.valueOf((String)ctx.getParam("P_CODLOCALDEST"));    
    HashMap<BigDecimal, BigDecimal> notasSaida = new HashMap();
    HashMap<BigDecimal,HashMap<BigDecimal, BigDecimal>> documentos = new HashMap();
    Collection<BigDecimal> documentosSaidas = new ArrayList<>();
    Collection<BigDecimal> documentosEntradas = new ArrayList<>();
    String mgsRetorno = null;
    SessionHandle hnd = null;

    try {  
    	hnd = JapeSession.open();
    	hnd.execWithTX( new JapeSession.TXBlock(){
			public void doWithTx() throws Exception{
    	    	int qtdSaidas = 0;
    	    	int qtdEntradas = 0;
    			 //Gerando Sa�das
    		    for (int i = 0; i < ctx.getLinhas().length; i++) {
    		        Registro line = ctx.getLinhas()[i];
    			    System.out.println("Gerando Transfer�ncia de Sa�da para Nro. Unico: " + line.getCampo("NUNOTA"));
			        EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
			        BigDecimal nuNota = (BigDecimal)line.getCampo("NUNOTA");
			        DynamicVO cabVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(DynamicEntityNames.CABECALHO_NOTA, new Object[] {nuNota});       
			        TransferenciaUtils.ehPedido(cabVO);
			        TransferenciaUtils.ehGerada(cabVO);
			        TransferenciaUtils.validaConferencia(cabVO);
			        //Busca Modelo Cabe�alho (278268 = 254438 | Produ��o vs Teste)
			        DynamicVO modelSaidaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO("CabecalhoNotaModelo", new Object[] {278268});
			        //Gera Sa�da
			        DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(modelSaidaVO,codEmpOrig,codEmpDestino);
			        if(transferenciaVO == null) 
				    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lan�amento de Nro. �nico: " + nuNota + " j� gerou uma erro na hora de compilar o modelo da nota!")); 
			        CACHelper cacHelper = new CACHelper();
			        AuthenticationInfo auth = AuthenticationInfo.getCurrent();
			        JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);
			        PrePersistEntityState cabPreState = PrePersistEntityState.build(ewf,"CabecalhoNota", transferenciaVO);
			        BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
			        DynamicVO saidaVO = bRegrasCab.getState().getNewVO();
			        System.out.println("Nota Saida: " + saidaVO.asBigDecimal("NUNOTA"));
			        BigDecimal nuNotaSaida =saidaVO.asBigDecimal("NUNOTA");
				    Collection<PrePersistEntityState> itensNota = TransferenciaUtils.buildItens(nuNota,codLocalOrig);      
				    cacHelper.incluirAlterarItem(nuNotaSaida, auth, itensNota, true);
				    TransferenciaUtils.gerarSerie(nuNota,nuNotaSaida);	   
				    notasSaida.put(nuNota, nuNotaSaida);
				    qtdSaidas++;
    		    } 
    		    //Gerando entradas 
    		    if(qtdSaidas>0) {
    	   	       // Exibindo todos os elementos do hashmap
    		    	for (Entry<BigDecimal, BigDecimal> saida : notasSaida.entrySet()) {           		
		    			System.out.println("Gerando Transfer�ncia de Entrada para Nro. Unico: " + saida.getValue());
		    	        EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
		    	        DynamicVO cabVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(DynamicEntityNames.CABECALHO_NOTA, new Object[] {saida.getValue()});       
		    	        //Busca Modelo Cabe�alho 278275 = 254448 | Produ��o vs Teste 
		    	        DynamicVO modelEntradaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO("CabecalhoNotaModelo", new Object[] {278275});
		    	        //Gera Sa�da
		    	        DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(modelEntradaVO,codEmpDestino,codEmpOrig);
		    	        if(transferenciaVO == null) 
		    		    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lan�amento de Nro. �nico: " + saida.getValue() + " j� gerou uma erro na hora de compilar o modelo da nota!")); 
		    	        CACHelper cacHelper = new CACHelper();
		    	        AuthenticationInfo auth = AuthenticationInfo.getCurrent();
		    	        JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);
		    	        PrePersistEntityState cabPreState = PrePersistEntityState.build(ewf,"CabecalhoNota", transferenciaVO);
		    	        BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
		    	        DynamicVO entradaVO = bRegrasCab.getState().getNewVO();
		    	        BigDecimal nuNotaEntrada = entradaVO.asBigDecimal("NUNOTA");
		    		    Collection<PrePersistEntityState> itensNota = TransferenciaUtils.buildItens(saida.getValue(),codLocalDestino);      
		    		    cacHelper.incluirAlterarItem(nuNotaEntrada, auth, itensNota, true);
		    		    TransferenciaUtils.gerarSerie(saida.getValue(),nuNotaEntrada);
		    	        PersistentLocalEntity entityEntrada = ewf.findEntityByPrimaryKey("CabecalhoNota", nuNotaEntrada);
		    	        if (entityEntrada != null) {
		    	            DynamicVO cabEntradaVO = (DynamicVO) entityEntrada.getValueObject();
		    	            cabEntradaVO.setProperty("VLRFRETE", cabEntradaVO.asBigDecimal("VLRFRETE"));
		    	            entityEntrada.setValueObject((EntityVO) cabEntradaVO);
		    	        }
		    		    ImpostosHelpper impostos = new ImpostosHelpper();
		    		    impostos.setForcarRecalculo(true);
		    		    impostos.calcularImpostos(nuNotaEntrada);
		    		    documentos.put(saida.getKey(), new HashMap<BigDecimal,BigDecimal>() {{  		    			
							    		    			   		put(saida.getValue(),nuNotaEntrada);
							    		                   }});
		    		    qtdEntradas++;
		           }
    		    totalEntradas = qtdEntradas;
			    }else {
		
			    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("A rotina falhou!. N�o foram localizadas notas de sa�da para gerar as respectivas entradas.")); 
			    }       
    if(totalEntradas > 0) {	
		documentos.forEach((pedido, value) -> {
		    HashMap<BigDecimal, BigDecimal> mov = (HashMap<BigDecimal, BigDecimal>) value;
		    mov.forEach((saida, entrada) -> {
		        try {
	    	        TransferenciaUtils.salvarOrigem(pedido,saida,entrada,Tipo.PEDIDO);
	    	        TransferenciaUtils.salvarOrigem(pedido,saida,entrada,Tipo.SAIDA);
	    	        TransferenciaUtils.salvarOrigem(pedido,saida,entrada,Tipo.ENTRADA);
	    	        documentosSaidas.add(saida);
	    	        documentosEntradas.add(entrada);
		        }catch(Exception e) {
		           	try {
						throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("A rotina falhou!. N�o foram geradas notas de entradas, consulte o log para mais informa��es."));
					} catch (Exception e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
	    	    }
		    });
		});
    }else {
    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("A rotina falhou!. N�o foram localizadas ENTRADAS, verifique o LOG do Sankhya para mais detalhes.")); 

    }	
	}});	
    }catch(Exception e) {
    	e.printStackTrace();
    	MGEModelException.throwMe(e);
    }finally {
    	JapeSession.close(hnd);
    }    	
	SessionHandle hnd2 = null;
	try {
		hnd2 = JapeSession.open();
		hnd2.execWithTX(new JapeSession.TXBlock() {
			public void doWithTx() throws Exception {
				documentosSaidas.forEach((nunota) -> {
					try {
						ImpostosHelpper helper = new ImpostosHelpper();
						helper.setForcarRecalculo(true);
						helper.calcularImpostos(nunota);
					} catch (Exception e) {
						e.printStackTrace();
					}
				});
				documentosEntradas.forEach((nunota) -> {
					try {
						ImpostosHelpper helper = new ImpostosHelpper();
						helper.setForcarRecalculo(true);
						helper.calcularImpostos(nunota);
					} catch (Exception e) {
						e.printStackTrace();
					}
				});
			}
		});
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		JapeSession.close(hnd2);
	}
	documentosSaidas.forEach((nunota) -> {
		try {
			TransferenciaUtils.confirmaNota(nunota);
			qtdSaidaConfirmadas++;
		} catch (MGEModelException e) {
			e.printStackTrace();
		}
	});

	if (qtdSaidaConfirmadas > 0) {

		try {
			TransferenciaUtils.gerarLote(documentosSaidas);
			qtdNFe++;
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (qtdNFe > 0) {
			documentosEntradas.forEach((nunota) -> {
				try {
					TransferenciaUtils.confirmaNota(nunota);
					qtdEntradaConfirmadas++;
				} catch (MGEModelException e) {
					e.printStackTrace();
				}
			});
		} else {
			mgsRetorno = "! , porém nenhuma nota de saída foi enviada para sefaz e as entradas não foram confirmadas!";
		}
	} else {
		mgsRetorno = "! , porém nenhuma nota foi confirmada!";
	}

	if (qtdEntradaConfirmadas == 0 && qtdNFe > 0) {
		mgsRetorno = "! , porém as entradas não foram confirmadas!";
	}

	ctx.setMensagemRetorno("Transferência realizada" + (mgsRetorno == null ? " com sucesso! " : mgsRetorno));	
  }
}
