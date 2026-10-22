package botaoAcao;

import java.math.BigDecimal;

/**
 * Dados crus de uma caixa/volume de AD_TGSLCB. Cada {@link CotadorTransportadora}
 * decide como formatar isso no payload da sua própria API (cubagem para Braspress,
 * Packs[] para Rodonaves).
 */
class PacoteDimensao {
    final BigDecimal comprimento;
    final BigDecimal largura;
    final BigDecimal altura;
    final BigDecimal voltot;
    final BigDecimal pesoItem;

    PacoteDimensao(BigDecimal comprimento, BigDecimal largura, BigDecimal altura, BigDecimal voltot, BigDecimal pesoItem) {
        this.comprimento = comprimento;
        this.largura = largura;
        this.altura = altura;
        this.voltot = voltot;
        this.pesoItem = pesoItem;
    }
}
