package botaoAcao;

/**
 * <b>Nome:</b> CotaFreteRodonaves<br>
 * <b>Tipo:</b> Botão de Ação ({@link br.com.sankhya.extensions.actionbutton.AcaoRotinaJava})<br>
 * <b>Descrição:</b> Realiza a cotação de frete via API REST da Rodonaves para os embarques
 * selecionados. Fluxo por registro em {@code AD_TGSCTF}:
 * <ol>
 *   <li>Autentica via OAuth2 (POST form-urlencoded) em {@code ENDPOINTAUTH} de {@code AD_TGSAPI}
 *       e obtém Bearer token.</li>
 *   <li>Resolve {@code OriginCityId} e {@code DestinationCityId} chamando o endpoint
 *       {@code ENDPOINTCIDADE} com os CEPs de origem e destino (usados apenas em
 *       memória para montar o payload; não são persistidos).</li>
 *   <li>Monta payload JSON com dados do remetente, destinatário, peso, valor e dimensões
 *       ({@code AD_TGSLCB}); chama {@code ENDPOINT} (gera-cotacao).</li>
 *   <li>Grava {@code VLRFRETE} em {@code AD_TGSCTF}. Atualização de {@code TGFCAB} e
 *       recálculo de impostos (via {@link br.com.sankhya.modelcore.comercial.impostos.ImpostosHelpper})
 *       estão temporariamente desativados para testes em ambiente de homologação —
 *       ver bloco comentado em {@code processarLinha}.</li>
 * </ol>
 *
 * <p><b>Tabelas acessadas:</b> AD_TGSCTF, AD_TGSLCB, AD_TGSAPI</p>
 * <p><b>API externa:</b> Rodonaves — autenticação OAuth2 Bearer token</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.0
 * @since 2025
 */

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.PreparedStatement;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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

public class CotaFreteRodonaves implements AcaoRotinaJava {

    // Campos de contato hardcoded para todos os cenários
    private static final String CONTACT_NAME  = "SPARK";
    private static final String CONTACT_PHONE = "33511256";
    private static final String CONTACT_EMAIL = "pedidos@spark.ind.br";

    // Parsers de resposta JSON (sem dependência de biblioteca externa)
    private static final Pattern ACCESS_TOKEN_PATTERN  = Pattern.compile("\"access_token\"\\s*:\\s*\"([^\"]+)\"");
    private static final Pattern FREIGHT_VALUE_PATTERN = Pattern.compile("\"Value\"\\s*:\\s*(-?[0-9]+(?:\\.[0-9]+)?)");
    private static final Pattern PROTOCOL_NUMBER_PATTERN = Pattern.compile("\"ProtocolNumber\"\\s*:\\s*\"([^\"]*)\"");
    private static final Pattern CITY_ID_PATTERN       = Pattern.compile("\"Id\"\\s*:\\s*(\\d+)");

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

            // Carrega configuração da API Rodonaves
            ApiConfig cfg = loadApiConfig(contexto);
            if (cfg == null || isBlank(cfg.endpoint)) {
                throw new Exception("Endpoint da Rodonaves não encontrado. Preencha AD_TGSAPI com API='Rodonaves' e AMBIENTE='P'.");
            }
            if (isBlank(cfg.endpointAuth)) {
                throw new Exception("ENDPOINTAUTH da Rodonaves não preenchido em AD_TGSAPI.");
            }
            if (isBlank(cfg.endpointCidade)) {
                throw new Exception("ENDPOINTCIDADE da Rodonaves não preenchido em AD_TGSAPI.");
            }

            // Autentica uma única vez para todas as linhas do lote
            String token = authenticate(cfg);
            if (isBlank(token)) {
                throw new Exception("Falha ao obter token de acesso da Rodonaves. Verifique as credenciais em AD_TGSAPI.");
            }

            Registro[] linhas = contexto.getLinhas();
            if (linhas == null || linhas.length == 0) {
                throw new Exception("Nenhuma linha selecionada para cotação.");
            }

            for (Registro linha : linhas) {
                try {
                    processarLinha(linha, contexto, jdbc, entityFacade, cfg, token, retorno);
                } catch (Exception eInner) {
                    StringBuilder st = new StringBuilder();
                    for (StackTraceElement el : eInner.getStackTrace()) st.append(el).append("\n");
                    appendMsg(retorno, "Erro ao processar linha (NUCTF: "
                            + getBigDecimalSafe(linha, "NUCTF") + "): "
                            + eInner.getMessage() + "\n" + st);
                }
            }

            contexto.setMensagemRetorno(retorno.toString());

        } finally {
            if (jdbc != null) JdbcWrapper.closeSession(jdbc);
            if (hnd != null) JapeSession.close(hnd);
        }
    }

    // ─── Processamento de uma linha ───────────────────────────────────────────

    private void processarLinha(Registro linha, ContextoAcao contexto, JdbcWrapper jdbc,
                                EntityFacade entityFacade, ApiConfig cfg, String token,
                                StringBuilder retorno) throws Exception {

        BigDecimal nuctf  = getBigDecimalSafe(linha, "NUCTF");
        BigDecimal nunota = getBigDecimalSafe(linha, "NUNOTA");

        // Tenta resolver NUCTF pelo NUNOTA quando não vier direto na linha
        if (isNullOrZero(nuctf) && !isNullOrZero(nunota)) {
            QueryExecutor q = contexto.getQuery();
            q.nativeSelect("SELECT NUCTF FROM AD_TGSCTF WHERE NUNOTA = " + nunota.toPlainString());
            if (q.next()) nuctf = q.getBigDecimal("NUCTF");
            q.close();
        }

        if (isNullOrZero(nuctf)) {
            appendMsg(retorno, "Linha ignorada: sem NUCTF/NUNOTA válido.");
            return;
        }

        // Lê dados do cabeçalho da cotação
        String    docOrig, docDest, cepOrigem, cepDestino, statusVar;
        BigDecimal vlrMercadoria, peso, volumes, nunotaCab;

        QueryExecutor qCab = contexto.getQuery();
        qCab.nativeSelect(
            "SELECT DOCORIG, DOCDEST, CEPORIG, CEPDEST, VLRTOT, PESOTOT, VOLTOT, NUNOTASIT, NUNOTA " +
            "FROM AD_TGSCTF WHERE NUCTF = " + nuctf.toPlainString()
        );
        if (!qCab.next()) {
            qCab.close();
            appendMsg(retorno, "NUCTF " + nuctf + ": registro não encontrado em AD_TGSCTF.");
            return;
        }
        docOrig       = qCab.getString("DOCORIG");
        docDest       = qCab.getString("DOCDEST");
        cepOrigem     = qCab.getString("CEPORIG");
        cepDestino    = qCab.getString("CEPDEST");
        vlrMercadoria = qCab.getBigDecimal("VLRTOT");
        peso          = qCab.getBigDecimal("PESOTOT");
        volumes       = qCab.getBigDecimal("VOLTOT");
        statusVar     = qCab.getString("NUNOTASIT");
        nunotaCab     = qCab.getBigDecimal("NUNOTA");
        qCab.close();

        if (isNullOrZero(nunota) && !isNullOrZero(nunotaCab)) nunota = nunotaCab;

        // ── Validações ──────────────────────────────────────────────────────

        if (statusVar == null || !"A".equalsIgnoreCase(statusVar.trim())) {
            appendMsg(retorno, "NUCTF " + nuctf + ": ignorado — NUNOTASIT não é 'A' (atual: " + statusVar + ").");
            return;
        }
        if (onlyDigits(docOrig).length() != 14) {
            appendMsg(retorno, "NUCTF " + nuctf + ": DOCORIG inválido (deve ter 14 dígitos).");
            return;
        }
        String docDestDigits = onlyDigits(docDest);
        if (docDestDigits.length() != 11 && docDestDigits.length() != 14) {
            appendMsg(retorno, "NUCTF " + nuctf + ": DOCDEST inválido (deve ter 11 ou 14 dígitos).");
            return;
        }
        if (onlyDigits(cepOrigem).length() != 8) {
            appendMsg(retorno, "NUCTF " + nuctf + ": CEPORIG inválido.");
            return;
        }
        if (onlyDigits(cepDestino).length() != 8) {
            appendMsg(retorno, "NUCTF " + nuctf + ": CEPDEST inválido.");
            return;
        }
        if (isNullOrZero(vlrMercadoria)) {
            appendMsg(retorno, "NUCTF " + nuctf + ": VLRTOT zerado.");
            return;
        }
        if (isNullOrZero(peso)) {
            appendMsg(retorno, "NUCTF " + nuctf + ": PESOTOT zerado.");
            return;
        }

        // ── Resolve CityIds via busca-cidade ────────────────────────────────

        int cidOrigId = getCityId(onlyDigits(cepOrigem), token, cfg.endpointCidade);
        if (cidOrigId <= 0) {
            appendMsg(retorno, "NUCTF " + nuctf + ": não foi possível obter CityId para CEP origem " + cepOrigem + ".");
            return;
        }
        int cidDestId = getCityId(onlyDigits(cepDestino), token, cfg.endpointCidade);
        if (cidDestId <= 0) {
            appendMsg(retorno, "NUCTF " + nuctf + ": não foi possível obter CityId para CEP destino " + cepDestino + ".");
            return;
        }

        // ── Monta array Packs a partir de AD_TGSLCB ─────────────────────────

        StringBuilder packsJson = new StringBuilder("[");
        boolean firstPack = true;
        QueryExecutor qDim = contexto.getQuery();
        qDim.nativeSelect(
            "SELECT COMPRIMENTO, LARGURA, ALTURA, VOLTOT, PESOITEM " +
            "FROM AD_TGSLCB WHERE NUCTF = " + nuctf.toPlainString() + " ORDER BY IDEMB"
        );
        while (qDim.next()) {
            BigDecimal comp     = qDim.getBigDecimal("COMPRIMENTO");
            BigDecimal larg     = qDim.getBigDecimal("LARGURA");
            BigDecimal alt      = qDim.getBigDecimal("ALTURA");
            BigDecimal voltot   = qDim.getBigDecimal("VOLTOT");
            BigDecimal pesoItem = qDim.getBigDecimal("PESOITEM");

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
        qDim.close();
        packsJson.append("]");

        // ── Payload gera-cotacao ─────────────────────────────────────────────

        int totalPackages = volumes != null ? volumes.intValue() : 0;

        String payload = "{" +
            "\"OriginZipCode\":\""            + onlyDigits(cepOrigem)    + "\"," +
            "\"OriginCityId\":"               + cidOrigId                + ","   +
            "\"DestinationZipCode\":\""       + onlyDigits(cepDestino)   + "\"," +
            "\"DestinationCityId\":"          + cidDestId                + ","   +
            "\"TotalWeight\":"                + formatWeightKg(peso)      + ","   +
            "\"EletronicInvoiceValue\":"      + formatDecimal(vlrMercadoria) + "," +
            "\"CustomerTaxIdRegistration\":\"" + onlyDigits(docOrig)     + "\"," +
            "\"ReceiverCpfcnp\":\""           + onlyDigits(docDest)      + "\"," +
            "\"ContactName\":\""             + CONTACT_NAME              + "\"," +
            "\"ContactPhoneNumber\":\""      + CONTACT_PHONE             + "\"," +
            "\"CustomerEmail\":\""           + CONTACT_EMAIL             + "\"," +
            "\"TotalPackages\":"             + totalPackages              + ","   +
            "\"Packs\":"                     + packsJson                 +
            "}";

        // ── Chamada gera-cotacao ─────────────────────────────────────────────

        String responseStr = null;
        BigDecimal valorFrete = null;
        String protocolNumber = null;
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
                appendMsg(retorno, "NUCTF " + nuctf + ": Erro na API Rodonaves (HTTP " + code + "). Detalhes: " + responseStr);
                return;
            }

            valorFrete = parseFreightValue(responseStr);
            protocolNumber = parseProtocolNumber(responseStr);

        } finally {
            if (conn != null) conn.disconnect();
        }

        if (valorFrete == null) {
            appendMsg(retorno, "NUCTF " + nuctf + ": Falha ao ler o valor do frete (campo \"Value\"). Resposta da API: " + responseStr);
            return;
        }

        // ── Grava VLRFRETE em AD_TGSCTF ─────────────────────────────────────

        try (PreparedStatement ps = jdbc.getConnection().prepareStatement(
                "UPDATE AD_TGSCTF SET VLRFRETE = ? WHERE NUCTF = ?")) {
            ps.setBigDecimal(1, valorFrete);
            ps.setBigDecimal(2, nuctf);
            ps.executeUpdate();
        }

        // ── Atualiza TGFCAB e recalcula impostos ────────────────────────────
        // DESATIVADO TEMPORARIAMENTE (ambiente de teste): manter a cotação
        // restrita a AD_TGSCTF, sem tocar em TGFCAB nem disparar recálculo de
        // impostos. Reativar removendo este comentário antes de ir para produção.
        /*
        if (!isNullOrZero(nunota)) {
            PersistentLocalEntity entity = entityFacade.findEntityByPrimaryKey("CabecalhoNota", nunota);
            if (entity != null) {
                DynamicVO cabVO = (DynamicVO) entity.getValueObject();
                if (cabVO != null) {
                    cabVO.setProperty("VLRFRETE", valorFrete);
                    entity.setValueObject((EntityVO) cabVO);
                }
            }

            // Garante authInfo no contexto Jape para o recálculo
            br.com.sankhya.modelcore.auth.AuthenticationInfo authInfo =
                (br.com.sankhya.modelcore.auth.AuthenticationInfo)
                br.com.sankhya.jape.util.JapeSessionContext.getProperty("authInfo");
            if (authInfo == null) {
                try {
                    br.com.sankhya.modelcore.auth.AuthenticationInfo auth =
                        new br.com.sankhya.modelcore.auth.AuthenticationInfo(
                            "Sankhya", BigDecimal.ZERO, BigDecimal.ZERO, 0);
                    br.com.sankhya.jape.util.JapeSessionContext.putProperty("authInfo", auth);
                } catch (Exception ignored) {}
            }

            ImpostosHelpper helper = new ImpostosHelpper();
            helper.setForcarRecalculo(true);
            try {
                helper.calcularImpostos(nunota);
            } catch (Exception eRecalculo) {
                appendMsg(retorno, "Atenção (NUCTF: " + nuctf + "): Frete gravado (R$ "
                        + valorFrete.toPlainString() + "), porém erro ao recalcular impostos: "
                        + eRecalculo.getMessage());
            }
        }
        */

        // ── Mensagem de retorno ──────────────────────────────────────────────

        String msg = "Valor do frete: R$ " + valorFrete.toPlainString();
        if (protocolNumber != null) msg += " | Protocolo Rodonaves: " + protocolNumber;
        appendMsg(retorno, msg);
    }

    // ─── Autenticação OAuth2 ──────────────────────────────────────────────────

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

    // ─── Busca CityId por CEP ─────────────────────────────────────────────────

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

    // ─── Carga de configuração ────────────────────────────────────────────────

    private static ApiConfig loadApiConfig(ContextoAcao contexto) {
        ApiConfig cfg = new ApiConfig();
        try {
            QueryExecutor q = contexto.getQuery();
            q.nativeSelect(
                "SELECT ENDPOINT, ENDPOINTAUTH, ENDPOINTCIDADE, USUARIO, PASSWORD, AUTH_TYPE " +
                "FROM AD_TGSAPI WHERE API = 'Rodonaves' AND AMBIENTE = 'P' AND ROWNUM = 1"
            );
            if (q.next()) {
                cfg.endpoint       = q.getString("ENDPOINT");
                cfg.endpointAuth   = q.getString("ENDPOINTAUTH");
                cfg.endpointCidade = q.getString("ENDPOINTCIDADE");
                cfg.user           = q.getString("USUARIO");
                cfg.pass           = q.getString("PASSWORD");
                cfg.authType       = q.getString("AUTH_TYPE");
                if (isBlank(cfg.authType)) cfg.authType = "DEV"; // default do endpoint /token de Cotação (Rodonaves)
            }
            q.close();
        } catch (Exception ignored) {}
        return cfg;
    }

    // ─── Parsers de resposta ──────────────────────────────────────────────────

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

    // ─── Utilitários ──────────────────────────────────────────────────────────

    private static boolean isNullOrZero(BigDecimal v) {
        return v == null || v.compareTo(BigDecimal.ZERO) == 0;
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
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
        return s == null ? "" : s.replaceAll("\\D", "");
    }

    private static String formatDecimal(BigDecimal v) {
        if (v == null) return "0.00";
        return v.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString().replace(',', '.');
    }

    // Peso em Kg inteiro, sempre arredondado para cima (exigência da API Rodonaves)
    private static String formatWeightKg(BigDecimal v) {
        if (v == null) return "0";
        return v.setScale(0, BigDecimal.ROUND_UP).toPlainString();
    }

    private static void appendMsg(StringBuilder sb, String msg) {
        if (sb.length() > 0) sb.append("\n");
        sb.append(msg);
    }

    private static String urlEncode(String s) {
        if (s == null) return "";
        try {
            return java.net.URLEncoder.encode(s, "UTF-8");
        } catch (Exception e) {
            return s;
        }
    }

    // ─── DTO de configuração ──────────────────────────────────────────────────

    private static class ApiConfig {
        String endpoint;
        String endpointAuth;
        String endpointCidade;
        String user;
        String pass;
        String authType;
    }
}
