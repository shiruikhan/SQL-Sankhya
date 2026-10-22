package botaoAcao;

import br.com.sankhya.extensions.actionbutton.ContextoAcao;

/**
 * Estratégia de cotação específica de uma transportadora: autenticação, resolução
 * de endpoint, montagem de payload e parse de resposta. Não deve tocar em
 * AD_TGSCTF/TGFCAB nem disparar recálculo de impostos — isso é responsabilidade
 * exclusiva de {@link CotaFreteMultiTransp}.
 *
 * <p>Implementações mantêm em campos de instância qualquer configuração/autenticação
 * carregada (ex.: credenciais de AD_TGSAPI, token OAuth2), carregando-a apenas na
 * primeira chamada de {@link #cotar} — já que a mesma instância é reaproveitada para
 * todas as linhas do lote que pertencem a essa transportadora.</p>
 */
interface CotadorTransportadora {
    CotacaoResultado cotar(ContextoAcao contexto, DadosCotacaoLinha dados) throws Exception;
}
