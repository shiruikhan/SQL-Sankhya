package br.com.spark.transferencia.teste;

/**
 * <b>Nome:</b> GerarTransferenciaReformaTrib<br>
 * <b>Tipo:</b> Botão de Ação ({@link br.com.sankhya.extensions.actionbutton.AcaoRotinaJava})<br>
 * <b>Descrição:</b> Protótipo standalone para o fluxo de notas de transferência com suporte
 * aos impostos da Reforma Tributária (IBS/CBS). Baseado em
 * {@link br.com.spark.transferencia.GerarTransferencia}, acrescenta dois passos adicionais
 * para calcular e persistir os totalizadores IBS/CBS na tabela {@code TGFREFIMP}:
 *
 * <ol>
 *   <li>Geração das notas de saída (modelo {@code CabecalhoNotaModelo} ID 278268)</li>
 *   <li>Cálculo de impostos convencionais das saídas via {@code ImpostosHelpper}</li>
 *   <li><b>[NOVO]</b> Cálculo de IBS/CBS das saídas via {@code totalizarImpostosCbsIbsIs}</li>
 *   <li>Geração das notas de entrada espelhando as saídas (modelo ID 278275)</li>
 *   <li>Cálculo de impostos convencionais das entradas</li>
 *   <li><b>[NOVO]</b> Cálculo de IBS/CBS das entradas via {@code totalizarImpostosCbsIbsIs}</li>
 *   <li>Confirmação e transmissão NF-e</li>
 * </ol>
 *
 * <p><b>Restrições:</b> Este arquivo é um protótipo isolado em {@code /teste_transf/}.
 * Não alterar o pacote de produção {@code br.com.spark.transferencia}.</p>
 *
 * <p><b>Parâmetros esperados no contexto:</b> P_CODEMPORIG, P_CODEMPDEST,
 * P_CODLOCALORIG, P_CODLOCALDEST</p>
 * <p><b>Pré-condições:</b> pedido deve ser TIPMOV='P', com conferência finalizada
 * e sem transferência prévia gerada.</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.0-PROTOTYPE
 * @since 2026
 * @see br.com.spark.transferencia.GerarTransferencia
 * @see br.com.spark.transferencia.teste.util.ReformaTribUtils
 */

import br.com.sankhya.extensions.actionbutton.AcaoRotinaJava;
import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.Registro;
import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.core.JapeSession.SessionHandle;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.vo.PrePersistEntityState;
import br.com.sankhya.modelcore.MGEModelException;
import br.com.sankhya.modelcore.auth.AuthenticationInfo;
import br.com.sankhya.modelcore.comercial.BarramentoRegra;
import br.com.sankhya.modelcore.comercial.centrais.CACHelper;
import br.com.sankhya.modelcore.util.DynamicEntityNames;
import br.com.sankhya.modelcore.util.EntityFacadeFactory;
import br.com.sankhya.jape.util.JapeSessionContext;
import br.com.sankhya.util.troubleshooting.SKError;
import br.com.sankhya.util.troubleshooting.TSLevel;
import br.com.spark.transferencia.enuns.Tipo;
import br.com.spark.transferencia.util.TransferenciaUtils;
import br.com.spark.transferencia.teste.util.ReformaTribUtils;
import com.sankhya.util.BigDecimalUtil;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map.Entry;

public class GerarTransferenciaReformaTrib implements AcaoRotinaJava {

    int totalEntradas = 0;

    public void doAction(ContextoAcao ctx) throws Exception {

        BigDecimal codEmpOrig      = BigDecimalUtil.valueOf((String) ctx.getParam("P_CODEMPORIG"));
        BigDecimal codEmpDestino   = BigDecimalUtil.valueOf((String) ctx.getParam("P_CODEMPDEST"));
        BigDecimal codLocalOrig    = BigDecimalUtil.valueOf((String) ctx.getParam("P_CODLOCALORIG"));
        BigDecimal codLocalDestino = BigDecimalUtil.valueOf((String) ctx.getParam("P_CODLOCALDEST"));

        HashMap<BigDecimal, BigDecimal> notasSaida        = new HashMap<>();
        HashMap<BigDecimal, HashMap<BigDecimal, BigDecimal>> documentos = new HashMap<>();
        Collection<BigDecimal> documentosSaidas   = new ArrayList<>();
        Collection<BigDecimal> documentosEntradas = new ArrayList<>();

        // ── 1. GERAÇÃO DE SAÍDAS ────────────────────────────────────────────────
        SessionHandle hnd = null;
        try {
            hnd = JapeSession.open();
            hnd.execWithTX(new JapeSession.TXBlock() {
                public void doWithTx() throws Exception {
                    for (int i = 0; i < ctx.getLinhas().length; i++) {
                        Registro line = ctx.getLinhas()[i];
                        EntityFacade ewf = EntityFacadeFactory.getDWFFacade();
                        BigDecimal nuNota = (BigDecimal) line.getCampo("NUNOTA");

                        DynamicVO cabVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(
                                DynamicEntityNames.CABECALHO_NOTA, new Object[]{nuNota});
                        TransferenciaUtils.ehPedido(cabVO);
                        TransferenciaUtils.ehGerada(cabVO);
                        TransferenciaUtils.validaConferencia(cabVO);

                        DynamicVO modelSaidaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(
                                "CabecalhoNotaModelo", new Object[]{278268});
                        DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(
                                modelSaidaVO, codEmpOrig, codEmpDestino);

                        if (transferenciaVO == null)
                            throw (Exception) SKError.registry(TSLevel.ERROR, "CORE_SPARK",
                                    new Exception("Falha ao compilar modelo de saída para Nro. Único: " + nuNota));

                        CACHelper cacHelper = new CACHelper();
                        AuthenticationInfo auth = AuthenticationInfo.getCurrent();
                        JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);

                        PrePersistEntityState cabPreState = PrePersistEntityState.build(
                                ewf, "CabecalhoNota", transferenciaVO);
                        BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
                        DynamicVO saidaVO = bRegrasCab.getState().getNewVO();
                        BigDecimal nuNotaSaida = saidaVO.asBigDecimal("NUNOTA");

                        Collection<PrePersistEntityState> itensNota = TransferenciaUtils.buildItens(
                                nuNota, codLocalOrig);
                        cacHelper.incluirAlterarItem(nuNotaSaida, auth, itensNota, true);
                        TransferenciaUtils.gerarSerie(nuNota, nuNotaSaida);

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

        if (notasSaida.isEmpty())
            throw (Exception) SKError.registry(TSLevel.ERROR, "CORE_SPARK",
                    new Exception("Nenhuma nota de saída gerada."));

        // ── 2. IMPOSTOS CONVENCIONAIS + IBS/CBS DAS SAÍDAS ──────────────────────
        // calcularImpostos → TGFDIN (CODIMP 12/13/14) → totalizarImpostosCbsIbsIs → TGFREFIMP
        // Sem inner catch: falha aqui aborta a transferência antes da transmissão NF-e.
        if (!documentosSaidas.isEmpty()) {
            SessionHandle hndCalcSai = null;
            try {
                hndCalcSai = JapeSession.open();
                for (BigDecimal nuNotaSaida : documentosSaidas) {
                    ReformaTribUtils.calcularImpostosReformaTrib(nuNotaSaida);
                }
            } catch (Exception e) {
                MGEModelException.throwMe(e);
            } finally {
                JapeSession.close(hndCalcSai);
            }
        }

        // ── 3. GERAÇÃO DE ENTRADAS ───────────────────────────────────────────────
        if (!notasSaida.isEmpty()) {
            SessionHandle hndEnt = null;
            try {
                hndEnt = JapeSession.open();
                hndEnt.execWithTX(new JapeSession.TXBlock() {
                    public void doWithTx() throws Exception {
                        int qtdEntradas = 0;
                        for (Entry<BigDecimal, BigDecimal> saida : notasSaida.entrySet()) {
                            EntityFacade ewf = EntityFacadeFactory.getDWFFacade();

                            DynamicVO modelEntradaVO = (DynamicVO) ewf.findEntityByPrimaryKeyAsVO(
                                    "CabecalhoNotaModelo", new Object[]{278275});
                            DynamicVO transferenciaVO = TransferenciaUtils.buildCabecalho(
                                    modelEntradaVO, codEmpDestino, codEmpOrig);

                            if (transferenciaVO == null)
                                throw (Exception) SKError.registry(TSLevel.ERROR, "CORE_SPARK",
                                        new Exception("Falha ao compilar modelo de entrada para saída: " + saida.getValue()));

                            CACHelper cacHelper = new CACHelper();
                            AuthenticationInfo auth = AuthenticationInfo.getCurrent();
                            JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);

                            PrePersistEntityState cabPreState = PrePersistEntityState.build(
                                    ewf, "CabecalhoNota", transferenciaVO);
                            BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
                            DynamicVO entradaVO = bRegrasCab.getState().getNewVO();
                            BigDecimal nuNotaEntrada = entradaVO.asBigDecimal("NUNOTA");

                            // buildItens lê a saída que já tem impostos do passo 2
                            Collection<PrePersistEntityState> itensNota = TransferenciaUtils.buildItens(
                                    saida.getValue(), codLocalDestino);
                            cacHelper.incluirAlterarItem(nuNotaEntrada, auth, itensNota, true);
                            TransferenciaUtils.gerarSerie(saida.getValue(), nuNotaEntrada);

                            documentos.put(saida.getKey(), new HashMap<BigDecimal, BigDecimal>() {{
                                put(saida.getValue(), nuNotaEntrada);
                            }});
                            documentosEntradas.add(nuNotaEntrada);
                            qtdEntradas++;
                        }

                        totalEntradas = qtdEntradas;

                        if (totalEntradas > 0) {
                            documentos.forEach((pedido, value) -> {
                                value.forEach((saida, entrada) -> {
                                    try {
                                        TransferenciaUtils.salvarOrigem(pedido, saida, entrada, Tipo.PEDIDO);
                                        TransferenciaUtils.salvarOrigem(pedido, saida, entrada, Tipo.SAIDA);
                                        TransferenciaUtils.salvarOrigem(pedido, saida, entrada, Tipo.ENTRADA);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                });
                            });
                        } else {
                            throw (Exception) SKError.registry(TSLevel.ERROR, "CORE_SPARK",
                                    new Exception("Nenhuma nota de entrada gerada a partir das saídas."));
                        }
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                MGEModelException.throwMe(e);
            } finally {
                JapeSession.close(hndEnt);
            }
        }

        // ── 4. IMPOSTOS CONVENCIONAIS + IBS/CBS DAS ENTRADAS ────────────────────
        // Mesma regra do passo 2: sem inner catch.
        if (!documentosEntradas.isEmpty()) {
            SessionHandle hndCalcEnt = null;
            try {
                hndCalcEnt = JapeSession.open();
                for (BigDecimal nuNotaEntrada : documentosEntradas) {
                    ReformaTribUtils.calcularImpostosReformaTrib(nuNotaEntrada);
                }
            } catch (Exception e) {
                MGEModelException.throwMe(e);
            } finally {
                JapeSession.close(hndCalcEnt);
            }
        }

        // ── 5. CONFIRMAÇÃO E TRANSMISSÃO NF-e ───────────────────────────────────
        if (!documentosSaidas.isEmpty()) {
            try {
                TransferenciaUtils.confirmarETransmitir(documentosSaidas);
            } catch (Exception e) {
                e.printStackTrace();
                MGEModelException.throwMe(e);
            }
        }

        if (!documentosEntradas.isEmpty()) {
            try {
                TransferenciaUtils.confirmarETransmitir(documentosEntradas);
            } catch (Exception e) {
                e.printStackTrace();
                MGEModelException.throwMe(e);
            }
        }

        ctx.setMensagemRetorno("Transferência com Reforma Tributária realizada com sucesso!");
    }
}
