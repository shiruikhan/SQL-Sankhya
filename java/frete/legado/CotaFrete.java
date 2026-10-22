package botaoAcao;

/**
 * <b>Nome:</b> CotaFrete<br>
 * <b>Tipo:</b> Botão de Ação ({@link br.com.sankhya.extensions.actionbutton.AcaoRotinaJava})<br>
 * <b>Descrição:</b> Realiza a cotação de frete via API REST da Braspress para os embarques
 * selecionados. Para cada registro em {@code AD_TGSCTF}, monta o payload JSON com dados do
 * remetente, destinatário, modal, CEP, peso, volumes e cubagem; chama o endpoint configurado
 * em {@code AD_TGSAPI}; e atualiza {@code VLRFRETE} em {@code AD_TGSCTF} e {@code TGFCAB},
 * recalculando impostos via {@link br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper}.
 *
 * <p><b>Tabelas acessadas:</b> AD_TGSCTF, AD_TGSLCB, AD_TGSAPI, TGFCAB</p>
 * <p><b>API externa:</b> Braspress — autenticação HTTP Basic (credenciais em AD_TGSAPI)</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.0
 * @since 2024
 */
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import br.com.sankhya.extensions.actionbutton.AcaoRotinaJava;
import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.QueryExecutor;
import br.com.sankhya.extensions.actionbutton.Registro;
import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.core.JapeSession.SessionHandle;
import br.com.sankhya.jape.dao.JdbcWrapper;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.vo.EntityVO;
import br.com.sankhya.jape.bmp.PersistentLocalEntity;
import java.sql.PreparedStatement;

import br.com.sankhya.modelcore.util.EntityFacadeFactory;
import br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper;

public class CotaFrete implements AcaoRotinaJava {

    private static final Pattern TOTAL_FRETE_PATTERN = Pattern.compile("\"totalFrete\"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)");
    private static final Pattern PRAZO_PATTERN = Pattern.compile("\\\"prazo\\\"\\s*:\\s*(\\d+)");

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

            ApiConfig cfg = loadApiConfig(contexto);
            if (cfg == null || cfg.endpoint == null || cfg.endpoint.trim().isEmpty()) {
                throw new Exception("Endpoint da Braspress não encontrado. Preencha AD_TGSAPI com API='Braspress' e AMBIENTE='P'.");
            }
            String authHeader = buildAuthorization(cfg);
            if (authHeader == null) {
                throw new Exception("Credenciais da Braspress não encontradas. Preencha USUARIO e PASSWORD em AD_TGSAPI.");
            }
            String targetUrl = cfg.endpoint;

            Registro[] linhas = contexto.getLinhas();
            if (linhas == null || linhas.length == 0) {
                throw new Exception("Nenhuma linha selecionada para cotação.");
            }

            for (Registro linha : linhas) {
                try {
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
                    continue;
                }

                String docOrig;
                String docDest;
                String modal;
                BigDecimal tipoFrete;
                String cepOrigem;
                String cepDestino;
                BigDecimal vlrMercadoria;
                BigDecimal peso;
                BigDecimal volumes;

                QueryExecutor qCab = contexto.getQuery();
                qCab.nativeSelect("SELECT DOCORIG, DOCDEST, MODAL, TIPFRETE, CEPORIG, CEPDEST, VLRTOT, PESOTOT, VOLTOT, NUNOTASIT, NUNOTA " +
                        "FROM AD_TGSCTF WHERE NUCTF = " + nuctf.toPlainString());
                if (!qCab.next()) {
                    qCab.close();
                    appendMsg(retorno, "NUCTF " + nuctf + ": registro não encontrado em AD_TGSCTF.");
                    continue;
                }
                docOrig = qCab.getString("DOCORIG");
                docDest = qCab.getString("DOCDEST");
                modal = qCab.getString("MODAL");
                tipoFrete = qCab.getBigDecimal("TIPFRETE");
                cepOrigem = qCab.getString("CEPORIG");
                cepDestino = qCab.getString("CEPDEST");
                vlrMercadoria = qCab.getBigDecimal("VLRTOT");
                peso = qCab.getBigDecimal("PESOTOT");
                volumes = qCab.getBigDecimal("VOLTOT");
                String statusVar = qCab.getString("NUNOTASIT");
                BigDecimal nunotaCab = qCab.getBigDecimal("NUNOTA");
                qCab.close();

                if (isNullOrZero(nunota) && !isNullOrZero(nunotaCab)) {
                    nunota = nunotaCab;
                }

                if (statusVar == null || !"A".equalsIgnoreCase(statusVar.trim())) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois NUNOTASIT não é 'A' (atual: " + statusVar + ").");
                    continue;
                }

                if (docOrig == null || onlyDigits(docOrig).length() != 14) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois DOCORIG (CNPJ Remetente) não tem 14 dígitos.");
                    continue;
                }

                if (docDest == null || docDest.trim().isEmpty()) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois DOCDEST está vazio.");
                    continue;
                }
                String cnpjDestDigits = onlyDigits(docDest);
                if (cnpjDestDigits.length() != 14 && cnpjDestDigits.length() != 11) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois DOCDEST não tem 11 ou 14 dígitos.");
                    continue;
                }

                if (modal == null || modal.trim().isEmpty()) {
                    modal = "R";
                } else if (!"R".equalsIgnoreCase(modal.trim()) && !"A".equalsIgnoreCase(modal.trim())) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois MODAL é inválido (deve ser R ou A).");
                    continue;
                }

                if (tipoFrete == null || tipoFrete.intValue() < 1 || tipoFrete.intValue() > 3) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois TIPFRETE é inválido (deve ser 1, 2 ou 3).");
                    continue;
                }

                if (cepOrigem == null || onlyDigits(cepOrigem).length() != 8) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois CEPORIG não tem 8 dígitos.");
                    continue;
                }

                if (cepDestino == null || onlyDigits(cepDestino).length() != 8) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois CEPDEST não tem 8 dígitos.");
                    continue;
                }

                if (isNullOrZero(vlrMercadoria)) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois VLRTOT (Valor Mercadoria) está zerado.");
                    continue;
                }

                if (isNullOrZero(peso)) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois PESOTOT (Peso) está zerado.");
                    continue;
                }

                if (volumes == null || volumes.intValue() <= 0) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": ignorado pois VOLTOT (Volumes) está zerado.");
                    continue;
                }

                StringBuilder cubagemJson = new StringBuilder();
                cubagemJson.append("[");
                boolean firstCub = true;
                QueryExecutor qDim = contexto.getQuery();
                qDim.nativeSelect("SELECT COMPRIMENTO, LARGURA, ALTURA, VOLTOT FROM AD_TGSLCB WHERE NUCTF = " + nuctf.toPlainString() + " ORDER BY IDEMB");
                while (qDim.next()) {
                    BigDecimal comprimento = qDim.getBigDecimal("COMPRIMENTO");
                    BigDecimal largura = qDim.getBigDecimal("LARGURA");
                    BigDecimal altura = qDim.getBigDecimal("ALTURA");
                    BigDecimal voltot = qDim.getBigDecimal("VOLTOT");

                    if (comprimento != null && largura != null && altura != null &&
                        comprimento.compareTo(BigDecimal.ZERO) > 0 &&
                        largura.compareTo(BigDecimal.ZERO) > 0 &&
                        altura.compareTo(BigDecimal.ZERO) > 0) {
                        
                        if (!firstCub) cubagemJson.append(",");
                        cubagemJson.append("{")
                                   .append("\"comprimento\":").append(formatDecimal(comprimento)).append(",")
                                   .append("\"largura\":").append(formatDecimal(largura)).append(",")
                                   .append("\"altura\":").append(formatDecimal(altura)).append(",");
                        
                        if (voltot != null && voltot.compareTo(BigDecimal.ZERO) > 0) {
                            cubagemJson.append("\"volumes\":").append(voltot.intValue());
                        } else {
                            cubagemJson.append("\"volumes\":1");
                        }
                        
                        cubagemJson.append("}");
                        firstCub = false;
                    }
                }
                qDim.close();
                cubagemJson.append("]");

                StringBuilder payload = new StringBuilder();
                payload.append("{")
                       .append("\"cnpjRemetente\":\"").append(onlyDigits(docOrig)).append("\",")
                       .append("\"cnpjDestinatario\":\"").append(onlyDigits(docDest)).append("\",")
                       .append("\"modal\":\"").append((modal != null && !modal.isEmpty()) ? modal : "R").append("\",")
                       .append("\"tipoFrete\":").append(tipoFrete != null ? tipoFrete.intValue() : 1).append(",")
                       .append("\"cepOrigem\":\"").append(onlyDigits(cepOrigem)).append("\",")
                       .append("\"cepDestino\":\"").append(onlyDigits(cepDestino)).append("\",")
                       .append("\"vlrMercadoria\":").append(formatDecimal(vlrMercadoria)).append(",")
                       .append("\"peso\":").append(formatDecimal(peso)).append(",")
                       .append("\"volumes\":").append(volumes != null ? volumes.intValue() : 0).append(",")
                       .append("\"cubagem\":").append(cubagemJson)
                       .append("}");

                BigDecimal valorFrete = null;
                Integer prazoDias = null;
                String responseStr = null;
                HttpURLConnection conn = null;
                try {
                    URL url = new URL(targetUrl);
                    conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("POST");
                    conn.setDoOutput(true);
                    conn.setRequestProperty("Authorization", authHeader);
                    conn.setRequestProperty("Content-Type", "application/json");

                    byte[] payloadBytes = payload.toString().getBytes(StandardCharsets.UTF_8);
                    conn.setFixedLengthStreamingMode(payloadBytes.length);
                    try (OutputStream os = conn.getOutputStream()) {
                        os.write(payloadBytes);
                    }

                    int code = conn.getResponseCode();
                    StringBuilder sbResp = new StringBuilder();
                    java.io.InputStream stream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
                    if (stream != null) {
                        try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                            String line;
                            while ((line = br.readLine()) != null) {
                                sbResp.append(line);
                            }
                        }
                    }
                    responseStr = sbResp.toString();
                    if (code < 200 || code >= 300) {
                        appendMsg(retorno, "NUCTF " + nuctf + ": Erro na API Braspress (HTTP " + code + "). Detalhes: " + responseStr);
                        continue;
                    }

                    valorFrete = parseTotalFrete(responseStr);
                    Integer prazoDiasLocal = parsePrazo(responseStr);
                    prazoDias = prazoDiasLocal;
                } finally {
                    if (conn != null) {
                        conn.disconnect();
                    }
                }

                if (valorFrete == null) {
                    appendMsg(retorno, "NUCTF " + nuctf + ": Falha ao ler valor do frete. Resposta da API: " + responseStr);
                    continue;
                }

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
                    
                    // Configurando ambiente transacional pro Recálculo de Impostos do Sankhya 
                    // Muitas vezes o ImpostosHelpper falha se chamado via reflection fora de contexto Jape adequado
                    try {
                        helper.calcularImpostos(nunota);
                    } catch (Exception eRecalculo) {
                        appendMsg(retorno, "Atenção (NUCTF: " + nuctf + "): Frete gravado (R$ " + valorFrete.toPlainString() + "), porém erro interno ao recalcular os impostos da nota: " + eRecalculo.getMessage());
                        // Opcional: Aqui poderiamos lançar erro ou só engolir e avisar, 
                        // decidi avisar e permitir que a rotina siga o processamento.
                    }
                }
                
                if (prazoDias != null && prazoDias > 0) {
                    appendMsg(retorno, "Valor do frete: R$ " + valorFrete.toPlainString() + " | Prazo estimado: até " + prazoDias + " dia(s).");
                } else {
                    appendMsg(retorno, "Valor do frete: R$ " + valorFrete.toPlainString());
                }

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

    private static boolean isNullOrZero(BigDecimal v) {
        return v == null || v.compareTo(BigDecimal.ZERO) == 0;
    }

    private static BigDecimal getBigDecimalSafe(Registro r, String campo) {
        try {
            if (r == null || campo == null) return null;
            Object o = r.getCampo(campo);
            if (o == null) return null;
            if (o instanceof BigDecimal) return (BigDecimal) o;
            if (o instanceof Number) return new BigDecimal(((Number) o).toString());
            if (o instanceof String) return new BigDecimal((String) o);
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    private static String onlyDigits(String s) {
        if (s == null) return "";
        return s.replaceAll("\\D", "");
    }

    private static String formatDecimal(BigDecimal v) {
        if (v == null) return "0.00";

        String result = v.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();

        return result.replace(',', '.');
    }

    private static void appendMsg(StringBuilder sb, String msg) {
        if (sb.length() > 0) sb.append("\n");
        sb.append(msg);
    }

    private static BigDecimal parseTotalFrete(String json) {
        if (json == null) return null;
        Matcher m = TOTAL_FRETE_PATTERN.matcher(json);
        if (m.find()) {
            try {
                return new BigDecimal(m.group(1));
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private static Integer parsePrazo(String json) {
        if (json == null) return null;
        Matcher m = PRAZO_PATTERN.matcher(json);
        if (m.find()) {
            try {
                return Integer.parseInt(m.group(1));
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private static class ApiConfig {
        String endpoint;
        String user;
        String pass;
    }

    private static ApiConfig loadApiConfig(ContextoAcao contexto) {
        ApiConfig cfg = new ApiConfig();
        try {
            QueryExecutor qCred = contexto.getQuery();
            qCred.nativeSelect(
                "SELECT ENDPOINT, USUARIO, PASSWORD FROM AD_TGSAPI " +
                "WHERE API = 'Braspress' AND AMBIENTE = 'P' AND ROWNUM = 1"
            );
            if (qCred.next()) {
                cfg.endpoint = qCred.getString("ENDPOINT");
                cfg.user = qCred.getString("USUARIO");
                cfg.pass = qCred.getString("PASSWORD");
            }
            qCred.close();
        } catch (Exception ignored) {

        }
        return cfg;
    }

    private static String buildAuthorization(ApiConfig cfg) {
        String user = (cfg != null) ? cfg.user : null;
        String pass = (cfg != null) ? cfg.pass : null;
        if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
            return null;
        }
        String basic = user + ":" + pass;
        String b64 = Base64.getEncoder().encodeToString(basic.getBytes(StandardCharsets.UTF_8));
        return "Basic " + b64;
    }


}