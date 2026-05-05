package br.com.spark.transferencia.teste.util;

/**
 * <b>Nome:</b> ReformaTribUtils<br>
 * <b>Tipo:</b> Classe utilitária (static helpers)<br>
 * <b>Descrição:</b> Suporte ao cálculo dos impostos da Reforma Tributária (IBS/CBS)
 * para notas de transferência. Encapsula as chamadas a
 * {@code ImpostosHelpper.calcularImpostos} e {@code totalizarImpostosCbsIbsIs},
 * que persiste os totalizadores na tabela {@code TGFREFIMP} via entidade
 * {@code ImpostosReformaTrib}.
 *
 * <h3>Arquitetura de classes (descoberta via inspeção de JAR)</h3>
 * <ul>
 *   <li>{@code br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper}
 *       — classe <b>proxy/delegate</b> em {@code mge-modelcore-4.35b448.jar}.
 *       É esta que deve ser instanciada (consistente com produção em
 *       {@code GerarTransferencia.java}).</li>
 *   <li>{@code br.com.sankhya.mgecomercial.model.impostos.ImpostosHelpper}
 *       — implementação real em {@code mgecom-model-4.35b448.jar}. O proxy
 *       delega para ela via {@code IImpostosHelpper delegate}.</li>
 * </ul>
 *
 * <h3>Fluxo interno de {@code totalizarImpostosCbsIbsIs}</h3>
 * <ol>
 *   <li>Guard: {@code if (nuNota == null || ImpostosFacade.getInstance() == null) return;}
 *       — sai silenciosamente se o serviço de Reforma não estiver deployado/habilitado.</li>
 *   <li>Obtém {@code TotalizadoresImpostosDTO} via {@code ImpostosFacade.getInstance().totalizaImpostos(nuNota)}.</li>
 *   <li>Busca {@code NUREFIMP} em {@code TGFREFIMP} onde {@code NUNOTA = nuNota}.</li>
 *   <li>Se encontrado, remove via {@code dwfEntityFacade.removeEntity("ImpostosReformaTrib", ...)}.</li>
 *   <li>Insere novo registro via {@code insertTGFREFIMP(dto)} + {@code dwfEntityFacade.createEntity(...)}.</li>
 * </ol>
 *
 * <h3>Campos IBS/CBS em TGFDIN (CODIMP)</h3>
 * <ul>
 *   <li>{@code 12} = IBS-UF (estadual)</li>
 *   <li>{@code 13} = IBS-MUN (municipal)</li>
 *   <li>{@code 14} = CBS (federal)</li>
 * </ul>
 *
 * <h3>Causas conhecidas de erro em {@code totalizarImpostosCbsIbsIs}</h3>
 * <ol>
 *   <li><b>Saída silenciosa</b>: {@code ImpostosFacade.getInstance()} retorna {@code null}
 *       quando o parâmetro {@code CALCULA_REFORMA_PELA_DIN} não está habilitado
 *       ou o serviço da Reforma Tributária não foi deployado. Nenhum erro é lançado,
 *       mas {@code TGFREFIMP} nunca é populado.</li>
 *   <li><b>NPE em {@code this.notaVO}</b>: se {@code calcularImpostos} lançar exceção
 *       que seja engolida antes de chamar {@code totalizarImpostosCbsIbsIs}, o campo
 *       interno {@code notaVO} permanece {@code null} e a busca de {@code NUREFIMP} explode.
 *       Por isso ambas as chamadas estão no mesmo {@code try} sem {@code catch} intermediário.</li>
 *   <li><b>ORA-00942 (TGFREFIMP)</b>: tabela ausente — migration da Reforma não aplicada.</li>
 *   <li><b>PersistenceException</b>: entidade {@code ImpostosReformaTrib} não registrada
 *       no EJB (JAR desatualizado ou não deployado corretamente).</li>
 *   <li><b>DTO zerado</b>: produtos/TOP não configurados para IBS/CBS — sem erro,
 *       mas registro em {@code TGFREFIMP} vem com zeros. Comportamento esperado.</li>
 *   <li><b>{@code isVersaoNT2029001 = false}</b>: NT 2029/001 (NF-e Reforma) não habilitada
 *       via parâmetro de sistema — {@code calcularImpostosReforma} retorna sem calcular.</li>
 * </ol>
 *
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.1
 * @since 2026
 * @see br.com.spark.transferencia.teste.GerarTransferenciaReformaTrib
 */

import java.math.BigDecimal;

import br.com.sankhya.modelcore.MGEModelException;
// Usa a implementação direta (mgecom-model-4.35b448.jar) em vez do proxy (mge-modelcore).
// O proxy não expõe totalizarImpostosCbsIbsIs nas versões 4.10/4.1 do modelcore.
import br.com.sankhya.mgecomercial.model.impostos.ImpostosHelpper;

public class ReformaTribUtils {

    /**
     * Calcula impostos convencionais e persiste os totalizadores IBS/CBS (Reforma Tributária)
     * para a nota informada em uma única chamada sequencial.
     *
     * <p><b>Importante</b>: {@code calcularImpostos} e {@code totalizarImpostosCbsIbsIs} são
     * executados no mesmo {@code try} sem {@code catch} intermediário. Isso garante que
     * {@code totalizarImpostosCbsIbsIs} nunca seja chamado com {@code notaVO == null}
     * (o que ocorreria se {@code calcularImpostos} falhasse silenciosamente).</p>
     *
     * <p>Se {@code ImpostosFacade.getInstance()} retornar {@code null} (Reforma desabilitada),
     * o método retorna sem erro e sem gravar {@code TGFREFIMP} — este é o comportamento
     * normal da Sankhya quando a feature ainda não está ativa.</p>
     *
     * @param nuNota número único da nota (TGFCAB.NUNOTA)
     * @throws MGEModelException propagado de {@code calcularImpostos} ou {@code totalizarImpostosCbsIbsIs}
     */
    public static void calcularImpostosReformaTrib(BigDecimal nuNota) throws MGEModelException {
        try {
            ImpostosHelpper helper = new ImpostosHelpper();
            helper.setForcarRecalculo(true);
            // calcularImpostos inicializa this.notaVO internamente (via inicializaNota).
            // totalizarImpostosCbsIbsIs depende de notaVO estar carregado — NÃO separe com try/catch.
            helper.calcularImpostos(nuNota);
            helper.totalizarImpostosCbsIbsIs(nuNota);
        } catch (Exception e) {
            MGEModelException.throwMe(e);
        }
    }
}
