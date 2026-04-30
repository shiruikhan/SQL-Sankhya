package br.com.spark.transferencia;

/**
 * <b>Nome:</b> GerarTransferencia<br>
 * <b>Tipo:</b> Botão de Ação ({@link br.com.sankhya.extensions.actionbutton.AcaoRotinaJava})<br>
 * <b>Descrição:</b> Gera notas de transferência entre empresas a partir de pedidos de venda
 * selecionados. O processo é executado em 5 etapas sequenciais, cada uma com transação própria:
 * <ol>
 *   <li>Geração das notas de saída (usando modelo {@code CabecalhoNotaModelo} ID 278268)</li>
 *   <li>Cálculo de impostos das saídas via {@code ImpostosHelpper}</li>
 *   <li>Geração das notas de entrada espelhando as saídas (modelo ID 278275)</li>
 *   <li>Cálculo de impostos das entradas</li>
 *   <li>Confirmação das notas e geração de lote NF-e via {@code ServicosNFeHelper2}</li>
 * </ol>
 * Ao final, vincula pedido, saída e entrada nos campos {@code AD_NUNOTASAI} e {@code AD_NUNOTAENT}
 * de {@code TGFCAB}.
 *
 * <p><b>Parâmetros esperados no contexto:</b> P_CODEMPORIG, P_CODEMPDEST,
 * P_CODLOCALORIG, P_CODLOCALDEST</p>
 * <p><b>Pré-condições:</b> pedido deve ser TIPMOV='P', com conferência finalizada
 * e sem transferência prévia gerada.</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 2.0
 * @since 2023
 * @see TransferenciaUtils
 * @see GerarTransferenciaOriginal
 */
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

    // 1. GERAÇÃO DE SAÍDAS (Primeira Transação)
    SessionHandle hnd = null;
    try {  
    	hnd = JapeSession.open();
    	hnd.execWithTX( new JapeSession.TXBlock(){
			public void doWithTx() throws Exception{
    		    for (int i = 0; i < ctx.getLinhas().length; i++) {
    		        Registro line = ctx.getLinhas()[i];
    			    System.out.println("Gerando Transferência de Saída para Nro. Unico: " + line.getCampo("NUNOTA"));
			        EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
			        BigDecimal nuNota = (BigDecimal)line.getCampo("NUNOTA");
			        DynamicVO cabVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(DynamicEntityNames.CABECALHO_NOTA, new Object[] {nuNota});       
			        TransferenciaUtils.ehPedido(cabVO);
			        TransferenciaUtils.ehGerada(cabVO);
			        TransferenciaUtils.validaConferencia(cabVO);
			        //Busca Modelo Cabeçalho (278268 = 254438 | Produção vs Teste)
			        DynamicVO modelSaidaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO("CabecalhoNotaModelo", new Object[] {278268});
			        //Gera Saída
			        DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(modelSaidaVO,codEmpOrig,codEmpDestino);
			        if(transferenciaVO == null) 
				    	throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lançamento de Nro. Único: " + nuNota + " já gerou uma erro na hora de compilar o modelo da nota!")); 
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
				    documentosSaidas.add(nuNotaSaida);
    		    } 
			}
    	});
    } catch(Exception e) {
    	e.printStackTrace();
    	MGEModelException.throwMe(e);
    } finally {
    	JapeSession.close(hnd);
    }

    if (notasSaida.isEmpty()) {
        throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("A rotina falhou!. Não foram geradas notas de saída."));
    }

    // 2. CÁLCULO DE IMPOSTOS DAS SAÍDAS (Fora de Transação para persistência)
    if (!documentosSaidas.isEmpty()) {
        SessionHandle hndCalc = null;
        try {
            hndCalc = JapeSession.open();
            for(BigDecimal nuNotaSaida : documentosSaidas) {
                try {
                    ImpostosHelpper helper = new ImpostosHelpper();
                    helper.setForcarRecalculo(true);
                    helper.calcularImpostos(nuNotaSaida);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } finally {
            JapeSession.close(hndCalc);
        }
    }

    // 3. GERAÇÃO DE ENTRADAS (Segunda Transação)
    if (!notasSaida.isEmpty()) {
        SessionHandle hndEnt = null;
        try {  
            hndEnt = JapeSession.open();
            hndEnt.execWithTX( new JapeSession.TXBlock(){
                public void doWithTx() throws Exception{
                    int qtdEntradas = 0;
                    for (Entry<BigDecimal, BigDecimal> saida : notasSaida.entrySet()) {           		
                        System.out.println("Gerando Transferência de Entrada para Nro. Unico: " + saida.getValue());
                        EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
                        //Busca Modelo Cabeçalho 278275 = 254448 | Produção vs Teste 
                        DynamicVO modelEntradaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO("CabecalhoNotaModelo", new Object[] {278275});
                        //Gera Entrada (Inverte Origem/Destino)
                        DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(modelEntradaVO,codEmpDestino,codEmpOrig);
                        if(transferenciaVO == null) 
                            throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("O lançamento de Nro. Único: " + saida.getValue() + " já gerou uma erro na hora de compilar o modelo da nota!")); 
                        CACHelper cacHelper = new CACHelper();
                        AuthenticationInfo auth = AuthenticationInfo.getCurrent();
                        JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);
                        PrePersistEntityState cabPreState = PrePersistEntityState.build(ewf,"CabecalhoNota", transferenciaVO);
                        BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
                        DynamicVO entradaVO = bRegrasCab.getState().getNewVO();
                        BigDecimal nuNotaEntrada = entradaVO.asBigDecimal("NUNOTA");
                        
                        // IMPORTANTE: Agora buildItens vai ler a Saída do banco, que JÁ TEM impostos calculados no passo 2!
                        // E como alteramos TransferenciaUtils para copiar impostos, a Entrada nascerá correta.
                        Collection<PrePersistEntityState> itensNota = TransferenciaUtils.buildItens(saida.getValue(),codLocalDestino);      
                        cacHelper.incluirAlterarItem(nuNotaEntrada, auth, itensNota, true);
                        TransferenciaUtils.gerarSerie(saida.getValue(),nuNotaEntrada);
                        
                        documentos.put(saida.getKey(), new HashMap<BigDecimal,BigDecimal>() {{  		    			
                            put(saida.getValue(),nuNotaEntrada);
                        }});
                        documentosEntradas.add(nuNotaEntrada);
                        qtdEntradas++;
                    }
                    totalEntradas = qtdEntradas;

                    // Vinculação (Salvar Origem)
                    if(totalEntradas > 0) {	
                        documentos.forEach((pedido, value) -> {
                            HashMap<BigDecimal, BigDecimal> mov = (HashMap<BigDecimal, BigDecimal>) value;
                            mov.forEach((saida, entrada) -> {
                                try {
                                    TransferenciaUtils.salvarOrigem(pedido,saida,entrada,Tipo.PEDIDO);
                                    TransferenciaUtils.salvarOrigem(pedido,saida,entrada,Tipo.SAIDA);
                                    TransferenciaUtils.salvarOrigem(pedido,saida,entrada,Tipo.ENTRADA);
                                }catch(Exception e) {
                                    e.printStackTrace();
                                }
                            });
                        });
                    } else {
                        throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("A rotina falhou!. Não foram localizadas notas de saída para gerar as respectivas entradas.")); 
                    }
                }
            });
        } catch(Exception e) {
            e.printStackTrace();
            MGEModelException.throwMe(e);
        } finally {
            JapeSession.close(hndEnt);
        }
    }

    // 4. CÁLCULO DE IMPOSTOS DAS ENTRADAS
    if (!documentosEntradas.isEmpty()) {
        SessionHandle hndCalcEnt = null;
        try {
            hndCalcEnt = JapeSession.open();
            for(BigDecimal nuNotaEntrada : documentosEntradas) {
                try {
                    ImpostosHelpper helper = new ImpostosHelpper();
                    helper.setForcarRecalculo(true);
                    helper.calcularImpostos(nuNotaEntrada);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } finally {
            JapeSession.close(hndCalcEnt);
        }
    }

    // 5. CONFIRMAÇÕES E LOTES (desativado — apenas criação de notas e processamento de entradas são executados)
//	documentosSaidas.forEach((nunota) -> {
//		try {
//			TransferenciaUtils.confirmaNota(nunota);
//			qtdSaidaConfirmadas++;
//		} catch (MGEModelException e) {
//			e.printStackTrace();
//		}
//	});
//
//	if (qtdSaidaConfirmadas > 0) {
//		try {
//			TransferenciaUtils.gerarLote(documentosSaidas);
//			qtdNFe++;
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//
//		if (qtdNFe > 0) {
//			documentosEntradas.forEach((nunota) -> {
//				try {
//					TransferenciaUtils.confirmaNota(nunota);
//					qtdEntradaConfirmadas++;
//				} catch (MGEModelException e) {
//					e.printStackTrace();
//				}
//			});
//		} else {
//			mgsRetorno = "! , porém nenhuma nota de saída foi enviada para sefaz e as entradas não foram confirmadas!";
//		}
//	} else {
//		mgsRetorno = "! , porém nenhuma nota foi confirmada!";
//	}
//
//	if (qtdEntradaConfirmadas == 0 && qtdNFe > 0) {
//		mgsRetorno = "! , porém as entradas não foram confirmadas!";
//	}

	ctx.setMensagemRetorno("Transferência realizada com sucesso! (confirmação e transmissão NF-e desativadas)");
  }
}