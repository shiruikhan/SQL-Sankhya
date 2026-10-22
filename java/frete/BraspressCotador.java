package botaoAcao;

import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.QueryExecutor;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static botaoAcao.FreteUtils.formatDecimal;
import static botaoAcao.FreteUtils.isBlank;
import static botaoAcao.FreteUtils.onlyDigits;

/**
 * Cotação via API REST da Braspress (HTTP Basic Auth). Lógica extraída de
 * CotaFrete.java (produção), sem alteração de comportamento: mesma montagem de
 * cubagem, mesmo payload, mesma chamada HTTP e mesmo parsing de totalFrete/prazo.
 */
class BraspressCotador implements CotadorTransportadora {

    private static final Pattern TOTAL_FRETE_PATTERN = Pattern.compile("\"totalFrete\"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)");
    private static final Pattern PRAZO_PATTERN = Pattern.compile("\\\"prazo\\\"\\s*:\\s*(\\d+)");

    private ApiConfig cfg;
    private String authHeader;

    @Override
    public CotacaoResultado cotar(ContextoAcao contexto, DadosCotacaoLinha dados) throws Exception {
        garantirConfig(contexto);

        StringBuilder cubagemJson = new StringBuilder("[");
        boolean firstCub = true;
        for (PacoteDimensao pacote : dados.pacotes) {
            BigDecimal comprimento = pacote.comprimento;
            BigDecimal largura = pacote.largura;
            BigDecimal altura = pacote.altura;
            BigDecimal voltot = pacote.voltot;
            if (comprimento != null && largura != null && altura != null
                    && comprimento.compareTo(BigDecimal.ZERO) > 0
                    && largura.compareTo(BigDecimal.ZERO) > 0
                    && altura.compareTo(BigDecimal.ZERO) > 0) {
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
        cubagemJson.append("]");

        StringBuilder payload = new StringBuilder();
        payload.append("{")
                .append("\"cnpjRemetente\":\"").append(onlyDigits(dados.docOrig)).append("\",")
                .append("\"cnpjDestinatario\":\"").append(onlyDigits(dados.docDest)).append("\",")
                .append("\"modal\":\"").append((dados.modal != null && !dados.modal.isEmpty()) ? dados.modal : "R").append("\",")
                .append("\"tipoFrete\":").append(dados.tipoFrete != null ? dados.tipoFrete.intValue() : 1).append(",")
                .append("\"cepOrigem\":\"").append(onlyDigits(dados.cepOrigem)).append("\",")
                .append("\"cepDestino\":\"").append(onlyDigits(dados.cepDestino)).append("\",")
                .append("\"vlrMercadoria\":").append(formatDecimal(dados.vlrMercadoria)).append(",")
                .append("\"peso\":").append(formatDecimal(dados.peso)).append(",")
                .append("\"volumes\":").append(dados.volumes != null ? dados.volumes.intValue() : 0).append(",")
                .append("\"cubagem\":").append(cubagemJson)
                .append("}");

        BigDecimal valorFrete = null;
        Integer prazoDias = null;
        String responseStr = null;
        HttpURLConnection conn = null;
        try {
            URL url = new URL(cfg.endpoint);
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
            InputStream stream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
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
                throw new Exception("NUCTF " + dados.nuctf + ": Erro na API Braspress (HTTP " + code + "). Detalhes: " + responseStr);
            }

            valorFrete = parseTotalFrete(responseStr);
            prazoDias = parsePrazo(responseStr);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }

        if (valorFrete == null) {
            throw new Exception("NUCTF " + dados.nuctf + ": Falha ao ler valor do frete. Resposta da API: " + responseStr);
        }

        return new CotacaoResultado(valorFrete, prazoDias, null);
    }

    private void garantirConfig(ContextoAcao contexto) throws Exception {
        if (cfg != null) return;
        cfg = loadApiConfig(contexto);
        if (cfg == null || isBlank(cfg.endpoint)) {
            throw new Exception("Endpoint da Braspress não encontrado. Preencha AD_TGSAPI com API='Braspress' e AMBIENTE='P'.");
        }
        authHeader = buildAuthorization(cfg);
        if (authHeader == null) {
            throw new Exception("Credenciais da Braspress não encontradas. Preencha USUARIO e PASSWORD em AD_TGSAPI.");
        }
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
        if (isBlank(cfg.user) || isBlank(cfg.pass)) {
            return null;
        }
        String basic = cfg.user + ":" + cfg.pass;
        String b64 = Base64.getEncoder().encodeToString(basic.getBytes(StandardCharsets.UTF_8));
        return "Basic " + b64;
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
}
