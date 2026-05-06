package br.com.spark.transferencia.teste.util;

/**
 * <b>Nome:</b> ReformaTribUtils<br>
 * <b>Tipo:</b> Classe utilitária (static helpers)<br>
 * <b>Descrição:</b> Suporte ao cálculo dos impostos da Reforma Tributária (IBS/CBS)
 * para notas de transferência. Encapsula as duas fases de cálculo em torno do
 * limite de transação exigido por {@code totalizarImpostosCbsIbsIs}.
 *
 * <h3>Por que dois ImpostosHelpper e duas fases?</h3>
 * <ul>
 *   <li>{@code calcularImpostos} usa {@code NativeSql}/JDBC direto → <b>não requer TX</b>,
 *       é chamado fora de {@code execWithTX} (padrão de produção em
 *       {@code GerarTransferencia.java}).</li>
 *   <li>{@code totalizarImpostosCbsIbsIs} chama {@code dwfEntityFacade.removeEntity} e
 *       {@code dwfEntityFacade.createEntity} → <b>requer TX ativa</b>; sem ela Sankhya
 *       lança "Operação requer uma transação ativa".</li>
 *   <li>As duas fases não podem compartilhar a mesma instância dentro do mesmo
 *       {@code execWithTX} porque {@code calcularImpostos} (Fase 1) deve commitar
 *       o TGFDIN via JDBC antes de {@code totalizaImpostos} (Fase 2) ler esses dados.</li>
 *   <li>A Fase 2 usa {@code carregarNota(nuNota)} para inicializar {@code notaVO}
 *       na nova instância — campo interno exigido por {@code totalizarImpostosCbsIbsIs}
 *       para buscar {@code NUREFIMP} em {@code TGFREFIMP}.</li>
 * </ul>
 *
 * <h3>Fluxo de dados confirmado via inspeção de JAR (mgecom-model-4.35b448)</h3>
 * <pre>
 * ── TX-1 (execWithTX #1) ──────────────────────────────────────────────────
 * calcularImpostos(nuNota)
 *   └─ calcularImpostosReforma(item, false) ← bloqueado por "ja.calculou"¹
 *
 * calcularImpostosReforma()              ← iconst_1=true por item → bypass "ja.calculou"
 *   └─ armazenarImpostosCalculadoSistema → TGFDIN [CODIMP 12=IBS-UF, 13=IBS-MUN, 14=CBS]
 *      (entity facade — escrita pendente na TX-1)
 *                   COMMIT TX-1  →  IBS/CBS agora visíveis via JDBC
 *
 * ── TX-2 (execWithTX #2) ──────────────────────────────────────────────────
 * carregarNota(nuNota)                   ← inicializa notaVO na nova instância
 *
 * totalizarImpostosCbsIbsIs(nuNota)
 *   └─ ImpostosFacade.totalizaImpostos(nuNota)  ← NativeSql: lê TGFDIN committed ✓
 *   └─ dwfEntityFacade.createEntity("ImpostosReformaTrib")  →  TGFREFIMP
 *                   COMMIT TX-2
 *                                                         ↓
 * confirmarETransmitir → GeradorXmlNFe2
 *   └─ SELECT VTOTDFE,VNFTOT,VIBS,VCBS FROM TGFREFIMP WHERE NUNOTA = :NUNOTA
 *
 * ¹ "ja.calculou.impostos.reforma.tributaria:NUNOTA:SEQ" setada por
 *   adiantarCalculoImpostosReforma durante incluirAlterarItem (mesmo JapeSession).
 * </pre>
 *
 * <h3>Causas conhecidas de falha em {@code totalizarImpostosCbsIbsIs}</h3>
 * <ol>
 *   <li><b>Saída silenciosa</b>: {@code ImpostosFacade.getInstance() == null} —
 *       parâmetro {@code CALCULA_REFORMA_PELA_DIN} desabilitado ou serviço não deployado.</li>
 *   <li><b>ORA-00942</b>: tabela {@code TGFREFIMP} inexistente — migration não aplicada.</li>
 *   <li><b>PersistenceException</b>: entidade {@code ImpostosReformaTrib} não registrada
 *       no EJB — {@code mgecom-model-4.35b448.jar} não deployado.</li>
 *   <li><b>DTO zerado</b>: produto/TOP não configurado para IBS/CBS — sem erro,
 *       {@code TGFREFIMP} gravado com zeros. Comportamento esperado.</li>
 *   <li><b>{@code isVersaoNT2029001 = false}</b>: NT 2029/001 não habilitada —
 *       {@code calcularImpostosReforma} retorna sem calcular.</li>
 * </ol>
 *
 * <p><b>Import obrigatório</b>: {@code br.com.sankhya.mgecomercial.model.impostos.ImpostosHelpper}
 * ({@code mgecom-model-4.35b448.jar}). O proxy {@code mge-modelcore} não expõe
 * {@code totalizarImpostosCbsIbsIs} nas versões 4.10/4.1.</p>
 *
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.2
 * @since 2026
 * @see br.com.spark.transferencia.teste.GerarTransferenciaReformaTrib
 */

import java.math.BigDecimal;

import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.modelcore.MGEModelException;
import br.com.sankhya.mgecomercial.model.impostos.ImpostosHelpper;

public class ReformaTribUtils {

    /**
     * Executa o cálculo completo de impostos (ICMS + IBS/CBS) para a nota informada
     * em dois blocos de transação sequenciais com um commit implícito entre eles.
     *
     * <h3>Por que dois execWithTX separados?</h3>
     * <p>{@code calcularImpostosReforma()} grava IBS/CBS em {@code TGFDIN} via
     * {@code dwfEntityFacade} (entity ops). Essas escritas ficam <b>não-commitadas</b>
     * dentro do mesmo {@code execWithTX}. {@code totalizarImpostosCbsIbsIs} lê
     * {@code TGFDIN} internamente via {@code ImpostosFacade.totalizaImpostos(nuNota)}
     * (NativeSql/JDBC), que enxerga apenas dados <b>committed</b> — e portanto leria
     * zeros enquanto as escritas de entity facade estivessem pendentes na mesma TX.</p>
     *
     * <p>O primeiro {@code execWithTX} commita os IBS/CBS em {@code TGFDIN}; o segundo
     * lê esse estado committed e persiste os totalizadores em {@code TGFREFIMP}.</p>
     *
     * <h3>Fluxo interno do TX-1</h3>
     * <ol>
     *   <li>{@code calcularImpostos} — ICMS/IPI via NativeSql; reforma bloqueada pela
     *       guard de sessão {@code "ja.calculou.impostos.reforma.tributaria"} (setada por
     *       {@code adiantarCalculoImpostosReforma} durante {@code incluirAlterarItem}).</li>
     *   <li>{@code calcularImpostosReforma()} — método público que passa {@code true}
     *       (iconst_1) por item, ativando {@code "forcar.recalculo.reforma.tributaria"}
     *       como bypass da guard → IBS/CBS gravados em {@code TGFDIN} via entity facade.</li>
     * </ol>
     *
     * <h3>Fluxo interno do TX-2</h3>
     * <ol>
     *   <li>{@code carregarNota} — inicializa {@code notaVO} na nova instância.</li>
     *   <li>{@code totalizarImpostosCbsIbsIs} — lê {@code TGFDIN} (committed), totaliza
     *       IBS/CBS e persiste em {@code TGFREFIMP} via {@code dwfEntityFacade.createEntity}
     *       (exige TX ativa).</li>
     * </ol>
     *
     * @param nuNota número único da nota (TGFCAB.NUNOTA)
     * @param hnd    handle da sessão ativa — reutilizado nos dois {@code execWithTX}
     * @throws MGEModelException propagado de qualquer falha nos dois blocos
     */
    public static void calcularImpostosReformaTrib(BigDecimal nuNota,
                                                   JapeSession.SessionHandle hnd)
            throws MGEModelException {
        try {
            // TX-1: ICMS + IBS/CBS → commita TGFDIN
            hnd.execWithTX(new JapeSession.TXBlock() {
                public void doWithTx() throws Exception {
                    ImpostosHelpper helper = new ImpostosHelpper();
                    helper.setForcarRecalculo(true);
                    helper.calcularImpostos(nuNota);        // ICMS/IPI via NativeSql
                    helper.calcularImpostosReforma();       // IBS/CBS via entity facade (iconst_1=true → força bypass da guard ja.calculou)
                }
            });

            // TX-2: lê TGFDIN committed → persiste TGFREFIMP
            hnd.execWithTX(new JapeSession.TXBlock() {
                public void doWithTx() throws Exception {
                    ImpostosHelpper helper = new ImpostosHelpper();
                    helper.carregarNota(nuNota);            // inicializa notaVO exigido por totalizarImpostosCbsIbsIs
                    helper.totalizarImpostosCbsIbsIs(nuNota);
                }
            });
        } catch (Exception e) {
            MGEModelException.throwMe(e);
        }
    }
}
