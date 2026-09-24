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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static botaoAcao.FreteUtils.formatDecimal;
import static botaoAcao.FreteUtils.isBlank;
import static botaoAcao.FreteUtils.isNullOrZero;
import static botaoAcao.FreteUtils.onlyDigits;

/**
 * Cotação via API REST da Rodonaves (OAuth2 Bearer token). Lógica extraída de
 * CotaFreteRodonaves.java, sem alteração de comportamento: mesma autenticação,
 * mesma resolução de CityId por CEP, mesmo payload Packs[] e mesmo parsing de
 * Value/ProtocolNumber. O bloco de TGFCAB/recálculo de impostos que existia
 * (comentado, nunca testado) NÃO foi reaproveitado — a persistência agora é
 * responsabilidade única de {@link CotaFreteMultiTransp}, igual à Braspress.
 *
 * <p><b>Prazo de entrega:</b> a resposta da cotação (gera-cotacao) não traz prazo
 * (diferente da Braspress, que já devolve "prazo" no mesmo response). A Rodonaves
 * expõe isso num endpoint separado ({@code POST .../prazo-entrega}, configurado em
 * {@code AD_TGSAPI.ENDPOINTPRAZO}), que recebe nome de cidade + UF (não CEP/CityId)
 * de origem e destino. A origem é sempre a matriz da empresa (Sacramento/MG,
 * fixo — mesmo padrão de constante hardcoded já usado para os dados de contato); o
 * destino é resolvido a partir do parceiro da nota
 * ({@code TGFCAB.CODPARC → TGFPAR.CODCID → TSICID.NOMECID/UF → TSIUFS.UF}), o mesmo
 * parceiro que a trigger {@code TRG_COTAFRETE_SPARK} já usa para CNPJ/CEP.</p>
 *
 * <p>Buscar o prazo é <b>best-effort</b>: qualquer falha (config ausente, parceiro
 * sem cidade cadastrada, erro HTTP) não impede a gravação do valor do frete — só
 * deixa {@link CotacaoResultado#prazoDias} nulo e acrescenta um aviso na mensagem
 * de retorno.</p>
 */
class RodonavesCotador implements CotadorTransportadora {

    private static final String CONTACT_NAME = "SPARK";
    private static final String CONTACT_PHONE = "33511256";
    private static final String CONTACT_EMAIL = "pedidos@spark.ind.br";

    // Origem fixa: matriz da empresa. Usada só no endpoint de prazo (nome de cidade + UF,
    // diferente do CityId/CEP usado na cotação de valor).
    private static final String ORIGIN_CITY_DESCRIPTION = "SACRAMENTO";
    private static final String ORIGIN_UF_DESCRIPTION = "MG";

    private static final Pattern ACCESS_TOKEN_PATTERN = Pattern.compile("\"access_token\"\\s*:\\s*\"([^\"]+)\"");
    private static final Pattern FREIGHT_VALUE_PATTERN = Pattern.compile("\"Value\"\\s*:\\s*(-?[0-9]+(?:\\.[0-9]+)?)");
    private static final Pattern PROTOCOL_NUMBER_PATTERN = Pattern.compile("\"ProtocolNumber\"\\s*:\\s*\"([^\"]*)\"");
    private static final Pattern CITY_ID_PATTERN = Pattern.compile("\"Id\"\\s*:\\s*(\\d+)");
    private static final Pattern DELIVERY_TIME_PATTERN = Pattern.compile("\"DeliveryTime\"\\s*:\\s*(\\d+)");

    private ApiConfig cfg;
    private String token;

    @Override
    public CotacaoResultado cotar(ContextoAcao contexto, DadosCotacaoLinha dados) throws Exception {
        garantirAutenticado(contexto);

        int cidOrigId = getCityId(onlyDigits(dados.cepOrigem), token, cfg.endpointCidade);
        if (cidOrigId <= 0) {
            throw new Exception("NUCTF " + dados.nuctf + ": não foi possível obter CityId para CEP origem " + dados.cepOrigem + ".");
        }
        int cidDestId = getCityId(onlyDigits(dados.cepDestino), token, cfg.endpointCidade);
        if (cidDestId <= 0) {
            throw new Exception("NUCTF " + dados.nuctf + ": não foi possível obter CityId para CEP destino " + dados.cepDestino + ".");
        }

        StringBuilder packsJson = new StringBuilder("[");
        boolean firstPack = true;
        for (PacoteDimensao pacote : dados.pacotes) {
            BigDecimal comp = pacote.comprimento;
            BigDecimal larg = pacote.largura;
            BigDecimal alt = pacote.altura;
            BigDecimal voltot = pacote.voltot;
            BigDecimal pesoItem = pacote.pesoItem;

            if (comp != null && larg != null && alt != null
                    && comp.compareTo(BigDecimal.ZERO) > 0
                    && larg.compareTo(BigDecimal.ZERO) > 0
                    && alt.compareTo(BigDecimal.ZERO) > 0) {

                if (!firstPack) packsJson.append(",");
                packsJson.append("{")
                        .append("\"AmountPackages\":").append(voltot != null && voltot.intValue() > 0 ? voltot.intValue() : 1).append(",")
                        .append("\"Weight\":").append(formatWeightKg(pesoItem != null ? pesoItem : BigDecimal.ZERO)).append(",")
                        .append("\"Length\":").append(formatDecimal(comp)).append(",")
                        .append("\"Height\":").append(formatDecimal(alt)).append(",")
                        .append("\"Width\":").append(formatDecimal(larg))
                        .append("}");
                firstPack = false;
            }
        }
        packsJson.append("]");

        int totalPackages = dados.volumes != null ? dados.volumes.intValue() : 0;

        String payload = "{" +
                "\"OriginZipCode\":\"" + onlyDigits(dados.cepOrigem) + "\"," +
                "\"OriginCityId\":" + cidOrigId + "," +
                "\"DestinationZipCode\":\"" + onlyDigits(dados.cepDestino) + "\"," +
                "\"DestinationCityId\":" + cidDestId + "," +
                "\"TotalWeight\":" + formatWeightKg(dados.peso) + "," +
                "\"EletronicInvoiceValue\":" + formatDecimal(dados.vlrMercadoria) + "," +
                "\"CustomerTaxIdRegistration\":\"" + onlyDigits(dados.docOrig) + "\"," +
                "\"ReceiverCpfcnp\":\"" + onlyDigits(dados.docDest) + "\"," +
                "\"ContactName\":\"" + CONTACT_NAME + "\"," +
                "\"ContactPhoneNumber\":\"" + CONTACT_PHONE + "\"," +
                "\"CustomerEmail\":\"" + CONTACT_EMAIL + "\"," +
                "\"TotalPackages\":" + totalPackages + "," +
                "\"Packs\":" + packsJson +
                "}";

        String responseStr = null;
        BigDecimal valorFrete;
        String protocolNumber;
        HttpURLConnection conn = null;

        try {
            URL url = new URL(cfg.endpoint);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Authorization", "Bearer " + token);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");

            byte[] payloadBytes = payload.getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(payloadBytes.length);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(payloadBytes);
            }

            int code = conn.getResponseCode();
            InputStream stream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
            StringBuilder sbResp = new StringBuilder();
            if (stream != null) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) sbResp.append(line);
                }
            }
            responseStr = sbResp.toString();

            if (code < 200 || code >= 300) {
                throw new Exception("NUCTF " + dados.nuctf + ": Erro na API Rodonaves (HTTP " + code + "). Detalhes: " + responseStr);
            }

            valorFrete = parseFreightValue(responseStr);
            protocolNumber = parseProtocolNumber(responseStr);

        } finally {
            if (conn != null) conn.disconnect();
        }

        if (valorFrete == null) {
            throw new Exception("NUCTF " + dados.nuctf + ": Falha ao ler o valor do frete (campo \"Value\"). Resposta da API: " + responseStr);
        }

        StringBuilder detalhe = new StringBuilder();
        if (protocolNumber != null) {
            detalhe.append("Protocolo Rodonaves: ").append(protocolNumber);
        }

        Integer prazoDias = null;
        try {
            prazoDias = buscarPrazoEntrega(contexto, dados);
        } catch (Exception ePrazo) {
            if (detalhe.length() > 0) detalhe.append(" | ");
            detalhe.append("Prazo de entrega não obtido: ").append(ePrazo.getMessage());
        }

        return new CotacaoResultado(valorFrete, prazoDias, detalhe.length() > 0 ? detalhe.toString() : null);
    }

    /**
     * Busca o prazo de entrega (em dias) em AD_TGSAPI.ENDPOINTPRAZO, a partir de
     * nome de cidade + UF de origem (fixo, matriz) e destino (resolvido do parceiro
     * da nota). Lança exceção em qualquer falha — o chamador trata isso como
     * best-effort e não bloqueia a gravação do frete.
     */
    private Integer buscarPrazoEntrega(ContextoAcao contexto, DadosCotacaoLinha dados) throws Exception {
        if (isBlank(cfg.endpointPrazo)) {
            throw new Exception("ENDPOINTPRAZO da Rodonaves não preenchido em AD_TGSAPI.");
        }
        if (isNullOrZero(dados.nunota)) {
            throw new Exception("NUNOTA não resolvido para localizar a cidade de destino.");
        }

        String[] cidadeUfDestino = resolverCidadeUfDestino(contexto, dados.nunota);

        String payload = "{" +
                "\"OriginCityDescription\":\"" + ORIGIN_CITY_DESCRIPTION + "\"," +
                "\"OriginUFDescription\":\"" + ORIGIN_UF_DESCRIPTION + "\"," +
                "\"DestinationCityDescription\":\"" + cidadeUfDestino[0] + "\"," +
                "\"DestinationUFDescription\":\"" + cidadeUfDestino[1] + "\"" +
                "}";

        HttpURLConnection conn = null;
        try {
            URL url = new URL(cfg.endpointPrazo);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Authorization", "Bearer " + token);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");

            byte[] payloadBytes = payload.getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(payloadBytes.length);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(payloadBytes);
            }

            int code = conn.getResponseCode();
            InputStream stream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
            StringBuilder sb = new StringBuilder();
            if (stream != null) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) sb.append(line);
                }
            }
            if (code < 200 || code >= 300) {
                throw new Exception("Erro na API de prazo da Rodonaves (HTTP " + code + "). Detalhes: " + sb);
            }
            Matcher m = DELIVERY_TIME_PATTERN.matcher(sb.toString());
            if (!m.find()) {
                throw new Exception("Campo \"DeliveryTime\" não encontrado na resposta: " + sb);
            }
            return Integer.parseInt(m.group(1));
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * Resolve nome da cidade (sem acentuação, maiúsculo) + sigla da UF do destino
     * físico da entrega. Espelha exatamente o CASE de TRG_COTAFRETE_SPARK: se
     * TGFCAB.CODPARCREDESPACHO estiver preenchido (<> 0), o destino é a
     * transportadora de redespacho; senão, é o parceiro de destino da nota
     * (CODPARC) — o mesmo parceiro que a trigger usa para CEPDEST/DOCDEST em
     * AD_TGSCTF, para não divergir do CEP/CNPJ já gravados na cotação.
     */
    private String[] resolverCidadeUfDestino(ContextoAcao contexto, BigDecimal nunota) throws Exception {
        QueryExecutor q = contexto.getQuery();
        q.nativeSelect(
                "SELECT CID.NOMECID, UFS.UF " +
                        "FROM TGFCAB CAB " +
                        "INNER JOIN TGFPAR PAR ON PAR.CODPARC = CASE WHEN NVL(CAB.CODPARCREDESPACHO, 0) <> 0 " +
                        "THEN CAB.CODPARCREDESPACHO ELSE CAB.CODPARC END " +
                        "INNER JOIN TSICID CID ON CID.CODCID = PAR.CODCID " +
                        "INNER JOIN TSIUFS UFS ON UFS.CODUF = CID.UF " +
                        "WHERE CAB.NUNOTA = " + nunota.toPlainString()
        );
        try {
            if (!q.next()) {
                throw new Exception("Cidade/UF do destinatário não cadastrada (NUNOTA " + nunota + ").");
            }
            String cidade = removerAcentos(q.getString("NOMECID")).trim().toUpperCase();
            String uf = q.getString("UF") == null ? "" : q.getString("UF").trim().toUpperCase();
            return new String[]{cidade, uf};
        } finally {
            q.close();
        }
    }

    private static String removerAcentos(String s) {
        if (s == null) return "";
        String normalizado = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        return normalizado.replaceAll("\\p{M}", "");
    }

    private void garantirAutenticado(ContextoAcao contexto) throws Exception {
        if (token != null) return;
        cfg = loadApiConfig(contexto);
        if (cfg == null || isBlank(cfg.endpoint)) {
            throw new Exception("Endpoint da Rodonaves não encontrado. Preencha AD_TGSAPI com API='Rodonaves' e AMBIENTE='P'.");
        }
        if (isBlank(cfg.endpointAuth)) {
            throw new Exception("ENDPOINTAUTH da Rodonaves não preenchido em AD_TGSAPI.");
        }
        if (isBlank(cfg.endpointCidade)) {
            throw new Exception("ENDPOINTCIDADE da Rodonaves não preenchido em AD_TGSAPI.");
        }
        token = authenticate(cfg);
        if (isBlank(token)) {
            throw new Exception("Falha ao obter token de acesso da Rodonaves. Verifique as credenciais em AD_TGSAPI.");
        }
    }

    private String authenticate(ApiConfig cfg) throws Exception {
        String formBody = "auth_type=" + urlEncode(cfg.authType)
                + "&grant_type=password"
                + "&username=" + urlEncode(cfg.user)
                + "&password=" + urlEncode(cfg.pass);

        HttpURLConnection conn = null;
        try {
            URL url = new URL(cfg.endpointAuth);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            byte[] body = formBody.getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(body.length);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body);
            }

            int code = conn.getResponseCode();
            InputStream stream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
            StringBuilder sb = new StringBuilder();
            if (stream != null) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) sb.append(line);
                }
            }
            if (code < 200 || code >= 300) {
                throw new Exception("Erro ao autenticar na Rodonaves (HTTP " + code + "): " + sb);
            }
            Matcher m = ACCESS_TOKEN_PATTERN.matcher(sb.toString());
            return m.find() ? m.group(1) : null;
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private int getCityId(String cep, String token, String endpointCidade) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(endpointCidade + "?zipCode=" + cep);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + token);
            conn.setRequestProperty("Accept", "application/json");

            int code = conn.getResponseCode();
            InputStream stream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
            StringBuilder sb = new StringBuilder();
            if (stream != null) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) sb.append(line);
                }
            }
            if (code < 200 || code >= 300) return -1;
            Matcher m = CITY_ID_PATTERN.matcher(sb.toString());
            return m.find() ? Integer.parseInt(m.group(1)) : -1;
        } catch (Exception e) {
            return -1;
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private static ApiConfig loadApiConfig(ContextoAcao contexto) {
        ApiConfig cfg = new ApiConfig();
        try {
            QueryExecutor q = contexto.getQuery();
            q.nativeSelect(
                    "SELECT ENDPOINT, ENDPOINTAUTH, ENDPOINTCIDADE, ENDPOINTPRAZO, USUARIO, PASSWORD, AUTH_TYPE " +
                            "FROM AD_TGSAPI WHERE API = 'Rodonaves' AND AMBIENTE = 'P' AND ROWNUM = 1"
            );
            if (q.next()) {
                cfg.endpoint = q.getString("ENDPOINT");
                cfg.endpointAuth = q.getString("ENDPOINTAUTH");
                cfg.endpointCidade = q.getString("ENDPOINTCIDADE");
                cfg.endpointPrazo = q.getString("ENDPOINTPRAZO");
                cfg.user = q.getString("USUARIO");
                cfg.pass = q.getString("PASSWORD");
                cfg.authType = q.getString("AUTH_TYPE");
                if (isBlank(cfg.authType)) cfg.authType = "DEV"; // default do endpoint /token de Cotação (Rodonaves)
            }
            q.close();
        } catch (Exception ignored) {
        }
        return cfg;
    }

    private static BigDecimal parseFreightValue(String json) {
        if (json == null) return null;
        Matcher m = FREIGHT_VALUE_PATTERN.matcher(json);
        if (!m.find()) return null;
        try {
            // "Value" já vem como número JSON puro (ponto decimal, sem milhar) — sem conversão de separador
            return new BigDecimal(m.group(1).trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static String parseProtocolNumber(String json) {
        if (json == null) return null;
        Matcher m = PROTOCOL_NUMBER_PATTERN.matcher(json);
        return m.find() ? m.group(1) : null;
    }

    // Peso em Kg inteiro, sempre arredondado para cima (exigência da API Rodonaves)
    private static String formatWeightKg(BigDecimal v) {
        if (v == null) return "0";
        return v.setScale(0, BigDecimal.ROUND_UP).toPlainString();
    }

    private static String urlEncode(String s) {
        if (s == null) return "";
        try {
            return java.net.URLEncoder.encode(s, "UTF-8");
        } catch (Exception e) {
            return s;
        }
    }

    private static class ApiConfig {
        String endpoint;
        String endpointAuth;
        String endpointCidade;
        String endpointPrazo;
        String user;
        String pass;
        String authType;
    }
}
