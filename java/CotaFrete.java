package botaoAcao;

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
import br.com.sankhya.jape.sql.NativeSql;

import br.com.sankhya.modelcore.util.EntityFacadeFactory;

public class CotaFrete implements AcaoRotinaJava {

    private static final Pattern TOTAL_FRETE_PATTERN = Pattern.compile("\"totalFrete\"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)");

    @Override
    public void doAction(ContextoAcao contexto) throws Exception {
        SessionHandle hnd = JapeSession.open();
        StringBuilder retorno = new StringBuilder();
        try {
            EntityFacade entityFacade = EntityFacadeFactory.getDWFFacade();
            JdbcWrapper jdbc = entityFacade.getJdbcWrapper();
            NativeSql nativeSql = new NativeSql(jdbc);

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
                qCab.nativeSelect("SELECT DOCORIG, DOCDEST, MODAL, TIPFRETE, CEPORIG, CEPDEST, VLRTOT, PESOTOT, VOLTOT, NUNOTASIT " +
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
                qCab.close();

                if (statusVar == null || !"A".equalsIgnoreCase(statusVar.trim())) {
                    continue;
                }

                if (docOrig == null || onlyDigits(docOrig).length() != 14) {
                    continue;
                }

                if (docDest == null || docDest.trim().isEmpty()) {
                    continue;
                }
                String cnpjDestDigits = onlyDigits(docDest);
                if (cnpjDestDigits.length() != 14 && cnpjDestDigits.length() != 11) {
                    continue;
                }

                if (modal == null || modal.trim().isEmpty()) {
                    modal = "R";
                } else if (!"R".equalsIgnoreCase(modal.trim()) && !"A".equalsIgnoreCase(modal.trim())) {
                    continue;
                }

                if (tipoFrete == null || tipoFrete.intValue() < 1 || tipoFrete.intValue() > 3) {
                    continue;
                }

                if (cepOrigem == null || onlyDigits(cepOrigem).length() != 8) {
                    continue;
                }

                if (cepDestino == null || onlyDigits(cepDestino).length() != 8) {
                    continue;
                }

                if (isNullOrZero(vlrMercadoria)) {
                    continue;
                }

                if (isNullOrZero(peso)) {
                    continue;
                }

                if (volumes == null || volumes.intValue() <= 0) {
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
                    try (BufferedReader br = new BufferedReader(new InputStreamReader(
                            (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream(), StandardCharsets.UTF_8))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            sbResp.append(line);
                        }
                    }
                    responseStr = sbResp.toString();
                    if (code < 200 || code >= 300) {
                        continue;
                    }

                    valorFrete = parseTotalFrete(responseStr);
                } finally {
                    if (conn != null) {
                        conn.disconnect();
                    }
                }

                if (valorFrete == null) {
                    continue;
                }

                nativeSql.executeUpdate("UPDATE AD_TGSCTF SET VLRFRETE = " + valorFrete.toPlainString() + " WHERE NUCTF = " + nuctf.toPlainString());
                appendMsg(retorno, "Valor do frete: R$ " + valorFrete.toPlainString());
            }

            contexto.setMensagemRetorno(retorno.toString());
        } catch (Exception e) {
            throw e;
        }
    }

    private static boolean isNullOrZero(BigDecimal v) {
        return v == null || v.compareTo(BigDecimal.ZERO) == 0;
    }

    private static BigDecimal getBigDecimalSafe(Registro r, String campo) {
        try {
            Object o = r.getCampo(campo);
            return (o instanceof BigDecimal) ? (BigDecimal) o : null;
        } catch (Exception e) {
            return null;
        }
    }

    private static String onlyDigits(String s) {
        if (s == null) return "";
        return s.replaceAll("\\D", "");
    }

    private static String toPlain(BigDecimal v) {
        return v != null ? v.toPlainString() : "0";
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