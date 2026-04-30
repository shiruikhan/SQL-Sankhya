package br.com.spark.transferencia;

/**
 * <b>Nome:</b> GerarTransferencia<br>
 * <b>Tipo:</b> Botão de Ação ({@link br.com.sankhya.extensions.actionbutton.AcaoRotinaJava})<br>
 * <b>Descrição:</b> Gera notas de saída de transferência entre empresas a partir de pedidos de
 * venda selecionados. O processo é executado em 2 etapas sequenciais:
 * <ol>
 *   <li>Geração das notas de saída (usando modelo {@code CabecalhoNotaModelo} ID 278268)</li>
 *   <li>Cálculo de impostos das saídas via {@code ImpostosHelpper}</li>
 * </ol>
 * Ao final, vincula pedido e saída no campo {@code AD_NUNOTASAI} de {@code TGFCAB}.
 * Geração de entrada, confirmação e transmissão NF-e são realizadas manualmente pelo operador.
 *
 * <p><b>Parâmetros esperados no contexto:</b> P_CODEMPORIG, P_CODEMPDEST, P_CODLOCALORIG</p>
 * <p><b>Pré-condições:</b> pedido deve ser TIPMOV='P', com conferência finalizada
 * e sem transferência prévia gerada.</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 2.2
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
import br.com.sankhya.jape.util.JapeSessionContext;
import br.com.sankhya.jape.vo.DynamicVO;
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

public class GerarTransferencia implements AcaoRotinaJava {

  public void doAction(ContextoAcao ctx) throws Exception {

    BigDecimal codEmpOrig     = BigDecimalUtil.valueOf((String)ctx.getParam("P_CODEMPORIG"));
    BigDecimal codEmpDestino  = BigDecimalUtil.valueOf((String)ctx.getParam("P_CODEMPDEST"));
    BigDecimal codLocalOrig   = BigDecimalUtil.valueOf((String)ctx.getParam("P_CODLOCALORIG"));
    HashMap<BigDecimal, BigDecimal> notasSaida    = new HashMap();
    Collection<BigDecimal>         documentosSaidas = new ArrayList<>();

    // 1. GERAÇÃO DE SAÍDAS
    SessionHandle hnd = null;
    try {
        hnd = JapeSession.open();
        hnd.execWithTX(new JapeSession.TXBlock(){
            public void doWithTx() throws Exception {
                for (int i = 0; i < ctx.getLinhas().length; i++) {
                    Registro line = ctx.getLinhas()[i];
                    BigDecimal nuNota = (BigDecimal)line.getCampo("NUNOTA");
                    System.out.println("Gerando Transferência de Saída para Nro. Único: " + nuNota);
                    EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
                    DynamicVO cabVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(DynamicEntityNames.CABECALHO_NOTA, new Object[]{nuNota});
                    TransferenciaUtils.ehPedido(cabVO);
                    TransferenciaUtils.ehGerada(cabVO);
                    TransferenciaUtils.validaConferencia(cabVO);
                    // Modelo 278268 (Produção) = 254438 (Teste)
                    DynamicVO modelSaidaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO("CabecalhoNotaModelo", new Object[]{278268});
                    DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(modelSaidaVO, codEmpOrig, codEmpDestino);
                    if (transferenciaVO == null)
                        throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("Nro. Único: " + nuNota + " — erro ao compilar o modelo da nota de saída."));
                    CACHelper cacHelper = new CACHelper();
                    AuthenticationInfo auth = AuthenticationInfo.getCurrent();
                    JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);
                    PrePersistEntityState cabPreState = PrePersistEntityState.build(ewf, "CabecalhoNota", transferenciaVO);
                    BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
                    DynamicVO saidaVO = bRegrasCab.getState().getNewVO();
                    BigDecimal nuNotaSaida = saidaVO.asBigDecimal("NUNOTA");
                    System.out.println("Nota Saída gerada: " + nuNotaSaida);
                    // Impostos omitidos do item; ImpostosHelpper (step 2) calcula com base na TOP de transferência
                    Collection<PrePersistEntityState> itensNota = TransferenciaUtils.buildItens(nuNota, codLocalOrig);
                    cacHelper.incluirAlterarItem(nuNotaSaida, auth, itensNota, true);
                    TransferenciaUtils.gerarSerie(nuNota, nuNotaSaida);
                    TransferenciaUtils.salvarOrigem(nuNota, nuNotaSaida, BigDecimal.ZERO, Tipo.PEDIDO);
                    TransferenciaUtils.salvarOrigem(nuNota, nuNotaSaida, BigDecimal.ZERO, Tipo.SAIDA);
                    notasSaida.put(nuNota, nuNotaSaida);
                    documentosSaidas.add(nuNotaSaida);
                }
            }
        });
    } catch (Exception e) {
        e.printStackTrace();
        MGEModelException.throwMe(e);
    } finally {
        JapeSession.close(hnd);
    }

    if (notasSaida.isEmpty()) {
        throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("A rotina falhou! Nenhuma nota de saída foi gerada."));
    }

    // 2. CÁLCULO DE IMPOSTOS DAS SAÍDAS (fora de transação para garantir persistência)
    SessionHandle hndCalc = null;
    try {
        hndCalc = JapeSession.open();
        for (BigDecimal nuNotaSaida : documentosSaidas) {
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

    ctx.setMensagemRetorno("Notas de saída geradas com sucesso! Gere as entradas, confirme e transmita manualmente.");
  }
}
