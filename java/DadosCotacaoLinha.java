package botaoAcao;

import java.math.BigDecimal;
import java.util.List;

/**
 * Dados do cabeçalho de AD_TGSCTF (já validados) + pacotes de AD_TGSLCB para uma
 * cotação, repassados a um {@link CotadorTransportadora} para montar seu próprio payload.
 */
class DadosCotacaoLinha {
    final BigDecimal nuctf;
    final BigDecimal nunota;
    final String docOrig;
    final String docDest;
    final String modal;
    final BigDecimal tipoFrete;
    final String cepOrigem;
    final String cepDestino;
    final BigDecimal vlrMercadoria;
    final BigDecimal peso;
    final BigDecimal volumes;
    final List<PacoteDimensao> pacotes;

    DadosCotacaoLinha(BigDecimal nuctf, BigDecimal nunota, String docOrig, String docDest, String modal,
                       BigDecimal tipoFrete, String cepOrigem, String cepDestino, BigDecimal vlrMercadoria,
                       BigDecimal peso, BigDecimal volumes, List<PacoteDimensao> pacotes) {
        this.nuctf = nuctf;
        this.nunota = nunota;
        this.docOrig = docOrig;
        this.docDest = docDest;
        this.modal = modal;
        this.tipoFrete = tipoFrete;
        this.cepOrigem = cepOrigem;
        this.cepDestino = cepDestino;
        this.vlrMercadoria = vlrMercadoria;
        this.peso = peso;
        this.volumes = volumes;
        this.pacotes = pacotes;
    }
}
