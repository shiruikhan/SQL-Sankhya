package botaoAcao;

import br.com.sankhya.extensions.actionbutton.Registro;

import java.math.BigDecimal;

/**
 * Utilitários compartilhados pelos botões/estratégias de cotação de frete
 * ({@link CotaFreteMultiTransp}, {@link BraspressCotador}, {@link RodonavesCotador}).
 * Extraídos dos helpers duplicados que existiam em CotaFrete.java e CotaFreteRodonaves.java.
 */
final class FreteUtils {

    private FreteUtils() {
    }

    static boolean isNullOrZero(BigDecimal v) {
        return v == null || v.compareTo(BigDecimal.ZERO) == 0;
    }

    static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    static BigDecimal getBigDecimalSafe(Registro r, String campo) {
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

    static String onlyDigits(String s) {
        if (s == null) return "";
        return s.replaceAll("\\D", "");
    }

    static String formatDecimal(BigDecimal v) {
        if (v == null) return "0.00";
        String result = v.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
        return result.replace(',', '.');
    }

    static void appendMsg(StringBuilder sb, String msg) {
        if (sb.length() > 0) sb.append("\n");
        sb.append(msg);
    }
}
