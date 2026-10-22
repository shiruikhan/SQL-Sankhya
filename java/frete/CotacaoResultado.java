package botaoAcao;

import java.math.BigDecimal;

/**
 * Resultado de uma cotação, devolvido por um {@link CotadorTransportadora} para o
 * botão único ({@link CotaFreteMultiTransp}) persistir e recalcular impostos.
 */
class CotacaoResultado {
    final BigDecimal valorFrete;
    final Integer prazoDias;
    final String detalheExtra;

    CotacaoResultado(BigDecimal valorFrete, Integer prazoDias, String detalheExtra) {
        this.valorFrete = valorFrete;
        this.prazoDias = prazoDias;
        this.detalheExtra = detalheExtra;
    }
}
