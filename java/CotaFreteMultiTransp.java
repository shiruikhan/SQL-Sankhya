package botaoAcao;

/**
 * <b>Nome:</b> CotaFreteMultiTransp<br>
 * <b>Tipo:</b> Botão de Ação ({@link br.com.sankhya.extensions.actionbutton.AcaoRotinaJava})<br>
 * <b>Descrição:</b> Botão único de cotação de frete que substitui CotaFrete.java (Braspress)
 * e CotaFreteRodonaves.java (Rodonaves). Para cada linha selecionada, lê o cabeçalho em
 * {@code AD_TGSCTF} (incluindo {@code APIDEST}, já preenchida pela trigger
 * {@code TRG_COTAFRETE_SPARK} a partir de {@code TGFCAB.CODPARCTRANSP}) e despacha para o
 * {@link CotadorTransportadora} correspondente ('B' → {@link BraspressCotador},
 * 'R' → {@link RodonavesCotador}), que cuida apenas de autenticação, endpoint, payload e
 * parse de resposta daquela API.
 *
 * <p>As validações, a gravação de {@code AD_TGSCTF.VLRFRETE}/{@code TGFCAB.VLRFRETE}/
 * {@code AD_ESTENTR} e o recálculo de impostos via
 * {@link br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper} são únicos para
 * todas as transportadoras — lógica copiada fielmente do CotaFrete.java (Braspress) de
 * produção, agora também aplicada às cotações Rodonaves.</p>
 *
 * <p><b>Tabelas acessadas:</b> AD_TGSCTF, AD_TGSLCB, AD_TGSAPI, TGFCAB</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.0
 * @since 2026
 */

import br.com.sankhya.extensions.actionbutton.AcaoRotinaJava;
import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.QueryExecutor;
import br.com.sankhya.extensions.actionbutton.Registro;
import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.bmp.PersistentLocalEntity;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.core.JapeSession.SessionHandle;
import br.com.sankhya.jape.dao.JdbcWrapper;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.vo.EntityVO;
import br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper;
import br.com.sankhya.modelcore.util.EntityFacadeFactory;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static botaoAcao.FreteUtils.appendMsg;
import static botaoAcao.FreteUtils.getBigDecimalSafe;
import static botaoAcao.FreteUtils.isNullOrZero;
import static botaoAcao.FreteUtils.onlyDigits;

public class CotaFreteMultiTransp implements AcaoRotinaJava {

    private final Map<String, CotadorTransportadora> cotadores = new HashMap<>();
    {
        cotadores.put("B", new BraspressCotador());
        cotadores.put("R", new RodonavesCotador());
    }

    @Override
    public void doAction(ContextoAcao contexto) throws Exception {
        SessionHandle hnd = null;
        JdbcWrapper jdbc = null;
        StringBuilder retorno = new StringBuilder();
        try {
            hnd = JapeSession.open();
            EntityFacade entityFacade = EntityFacadeFactory.getDWFFacade();
            jdbc = entityFacade.getJdbcWrapper();
            jdbc.openSession();

            Registro[] linhas = contexto.getLinhas();
            if (linhas == null || linhas.length == 0) {
                throw new Exception("Nenhuma linha selecionada para cotação.");
            }

            for (Registro linha : linhas) {
                try {
                    processarLinha(linha, contexto, jdbc, entityFacade, retorno);
                } catch (Exception eInner) {
                    StringBuilder stackTrace = new StringBuilder();
                    for (StackTraceElement element : eInner.getStackTrace()) {
                        stackTrace.append(element.toString()).append("\n");
                    }
                    appendMsg(retorno, "Erro ao processar linha (NUCTF: " + getBigDecimalSafe(linha, "NUCTF") + "): " + eInner.getMessage() + "\n" + stackTrace.toString());
                }
            }

            contexto.setMensagemRetorno(retorno.toString());
        } catch (Exception e) {
            throw e;
        } finally {
            if (jdbc != null) {
                JdbcWrapper.closeSession(jdbc);
            }
            if (hnd != null) {
                JapeSession.close(hnd);
            }
        }
    }

    private void processarLinha(Registro linha, ContextoAcao contexto, JdbcWrapper jdbc,
                                 EntityFacade entityFacade, StringBuilder retorno) throws Exception {

        BigDecimal nuctf = getBigDecimalSafe(linha, "NUCTF");
        BigDecimal nunota = getBigDecimalSafe(linha, "NUNOTA");

        if (isNullOrZero(nuctf) && !isNullOrZero(nunota)) {
            QueryExecutor qFind = contexto.getQuery();
            qFind.nativeSelect("SELECT NUCTF FROM AD_TGSCTF WHERE NUNOTA = " + nunota.toPlainString());
            if (qFind.next()) {
                nuctf = qFind.getBigDecimal("NUCTF");
            }
            qFind.close();
        }

        if (isNullOrZero(nuctf)) {
            appendMsg(retorno, "Linha ignorada: sem NUCTF/NUNOTA válido.");
            return;
        }

        QueryExecutor qCab = contexto.getQuery();
        qCab.nativeSelect("SELECT DOCORIG, DOCDEST, APIDEST, MODAL, TIPFRETE, CEPORIG, CEPDEST, VLRTOT, PESOTOT, VOLTOT, NUNOTASIT, NUNOTA " +
                "FROM AD_TGSCTF WHERE NUCTF = " + nuctf.toPlainString());
        if (!qCab.next()) {
            qCab.close();
            appendMsg(retorno, "NUCTF " + nuctf + ": registro não encontrado em AD_TGSCTF.");
            return;
        }
        String docOrig = qCab.getString("DOCORIG");
        String docDest = qCab.getString("DOCDEST");
        String apiDest = qCab.getString("APIDEST");
        String modal = qCab.getString("MODAL");
        BigDecimal tipoFrete = qCab.getBigDecimal("TIPFRETE");
        String cepOrigem = qCab.getString("CEPORIG");
        String cepDestino = qCab.getString("CEPDEST");
        BigDecimal vlrMercadoria = qCab.getBigDecimal("VLRTOT");
        BigDecimal peso = qCab.getBigDecimal("PESOTOT");
        BigDecimal volumes = qCab.getBigDecimal("VOLTOT");
        String statusVar = qCab.getString("NUNOTASIT");
        BigDecimal nunotaCab = qCab.getBigDecimal("NUNOTA");
        qCab.close();

        if (isNullOrZero(nunota) && !isNullOrZero(nunotaCab)) {
            nunota = nunotaCab;
        }

        if (statusVar == null || !"A".equalsIgnoreCase(statusVar.trim())) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois NUNOTASIT não é 'A' (atual: " + statusVar + ").");
            return;
        }

        if (docOrig == null || onlyDigits(docOrig).length() != 14) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois DOCORIG (CNPJ Remetente) não tem 14 dígitos.");
            return;
        }

        if (docDest == null || docDest.trim().isEmpty()) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois DOCDEST está vazio.");
            return;
        }
        String cnpjDestDigits = onlyDigits(docDest);
        if (cnpjDestDigits.length() != 14 && cnpjDestDigits.length() != 11) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois DOCDEST não tem 11 ou 14 dígitos.");
            return;
        }

        if (modal == null || modal.trim().isEmpty()) {
            modal = "R";
        } else if (!"R".equalsIgnoreCase(modal.trim()) && !"A".equalsIgnoreCase(modal.trim())) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois MODAL é inválido (deve ser R ou A).");
            return;
        }

        if (tipoFrete == null || tipoFrete.intValue() < 1 || tipoFrete.intValue() > 3) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois TIPFRETE é inválido (deve ser 1, 2 ou 3).");
            return;
        }

        if (cepOrigem == null || onlyDigits(cepOrigem).length() != 8) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois CEPORIG não tem 8 dígitos.");
            return;
        }

        if (cepDestino == null || onlyDigits(cepDestino).length() != 8) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois CEPDEST não tem 8 dígitos.");
            return;
        }

        if (isNullOrZero(vlrMercadoria)) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois VLRTOT (Valor Mercadoria) está zerado.");
            return;
        }

        if (isNullOrZero(peso)) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois PESOTOT (Peso) está zerado.");
            return;
        }

        if (volumes == null || volumes.intValue() <= 0) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois VOLTOT (Volumes) está zerado.");
            return;
        }

        String apiDestKey = apiDest == null ? null : apiDest.trim().toUpperCase();
        CotadorTransportadora cotador = cotadores.get(apiDestKey);
        if (cotador == null) {
            appendMsg(retorno, "NUCTF " + nuctf + ": transportadora não suportada (APIDEST=" + apiDest + ").");
            return;
        }

        List<PacoteDimensao> pacotes = new ArrayList<>();
        QueryExecutor qDim = contexto.getQuery();
        qDim.nativeSelect("SELECT COMPRIMENTO, LARGURA, ALTURA, VOLTOT, PESOITEM FROM AD_TGSLCB WHERE NUCTF = " + nuctf.toPlainString() + " ORDER BY IDEMB");
        while (qDim.next()) {
            pacotes.add(new PacoteDimensao(
                    qDim.getBigDecimal("COMPRIMENTO"),
                    qDim.getBigDecimal("LARGURA"),
                    qDim.getBigDecimal("ALTURA"),
                    qDim.getBigDecimal("VOLTOT"),
                    qDim.getBigDecimal("PESOITEM")
            ));
        }
        qDim.close();

        DadosCotacaoLinha dados = new DadosCotacaoLinha(nuctf, nunota, docOrig, docDest, modal, tipoFrete,
                cepOrigem, cepDestino, vlrMercadoria, peso, volumes, pacotes);

        CotacaoResultado resultado;
        try {
            resultado = cotador.cotar(contexto, dados);
        } catch (Exception eCotacao) {
            appendMsg(retorno, eCotacao.getMessage());
            return;
        }

        if (resultado == null || resultado.valorFrete == null) {
            appendMsg(retorno, "NUCTF " + nuctf + ": falha ao obter o valor do frete.");
            return;
        }

        BigDecimal valorFrete = resultado.valorFrete;
        Integer prazoDias = resultado.prazoDias;

        try (PreparedStatement pstmt = jdbc.getConnection().prepareStatement("UPDATE AD_TGSCTF SET VLRFRETE = ? WHERE NUCTF = ?")) {
            pstmt.setBigDecimal(1, valorFrete);
            pstmt.setBigDecimal(2, nuctf);
            pstmt.executeUpdate();
        }

        // Também atualiza o VLRFRETE em TGFCAB baseado pelo NUNOTA
        if (!isNullOrZero(nunota)) {
            PersistentLocalEntity entity = entityFacade.findEntityByPrimaryKey("CabecalhoNota", nunota);
            if (entity != null) {
                DynamicVO cabVO = (DynamicVO) entity.getValueObject();
                if (cabVO != null) {
                    cabVO.setProperty("VLRFRETE", valorFrete);
                    if (prazoDias != null) {
                        cabVO.setProperty("AD_ESTENTR", String.valueOf(prazoDias));
                    }
                    entity.setValueObject((EntityVO) cabVO);
                }
            }

            // Recalculo de impostos e totais via ImpostosHelpper
            // Utilizando calcularImpostos(nunota) com forcarRecalculo para garantir atualização correta
            br.com.sankhya.modelcore.auth.AuthenticationInfo authInfo = (br.com.sankhya.modelcore.auth.AuthenticationInfo) br.com.sankhya.jape.util.JapeSessionContext.getProperty("authInfo");
            if (authInfo == null) {
                try {
                    br.com.sankhya.modelcore.auth.AuthenticationInfo auth = new br.com.sankhya.modelcore.auth.AuthenticationInfo("Sankhya", BigDecimal.ZERO, BigDecimal.ZERO, 0);
                    br.com.sankhya.jape.util.JapeSessionContext.putProperty("authInfo", auth);
                } catch (Exception ignored) {
                }
            }

            ImpostosHelpper helper = new ImpostosHelpper();
            helper.setForcarRecalculo(true);

            try {
                helper.calcularImpostos(nunota);
            } catch (Exception eRecalculo) {
                appendMsg(retorno, "Atenção (NUCTF: " + nuctf + "): Frete gravado (R$ " + valorFrete.toPlainString() + "), porém erro interno ao recalcular os impostos da nota: " + eRecalculo.getMessage());
            }
        }

        StringBuilder msg = new StringBuilder("Valor do frete: R$ " + valorFrete.toPlainString());
        if (prazoDias != null && prazoDias > 0) {
            msg.append(" | Prazo estimado: até ").append(prazoDias).append(" dia(s).");
        }
        if (resultado.detalheExtra != null && !resultado.detalheExtra.trim().isEmpty()) {
            msg.append(" | ").append(resultado.detalheExtra);
        }
        appendMsg(retorno, msg.toString());
    }
}
