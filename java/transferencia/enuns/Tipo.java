package br.com.spark.transferencia.enuns;

/**
 * <b>Nome:</b> Tipo<br>
 * <b>Tipo:</b> Enumeração (enum)<br>
 * <b>Descrição:</b> Define os tipos de movimento utilizados no processo de transferência
 * entre empresas. Cada constante representa um tipo de nota gerada no fluxo e carrega
 * o código correspondente do campo {@code TIPMOV} do Sankhya.
 *
 * <ul>
 *   <li>{@code PEDIDO} — Pedido de venda de origem (TIPMOV = 'P')</li>
 *   <li>{@code SAIDA}  — Nota de saída da transferência (TIPMOV = 'V')</li>
 *   <li>{@code ENTRADA}— Nota de entrada da transferência (TIPMOV = 'C')</li>
 * </ul>
 *
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.0
 * @since 2023
 * @see br.com.spark.transferencia.util.TransferenciaUtils#salvarOrigem
 */
public enum Tipo {

    /** Pedido de venda de origem da transferência (TIPMOV = 'P'). */
    PEDIDO("P"),

    /** Nota de saída gerada pela transferência (TIPMOV = 'V'). */
    SAIDA("V"),

    /** Nota de entrada gerada pela transferência (TIPMOV = 'C'). */
    ENTRADA("C");

    /** Código TIPMOV correspondente no Sankhya. */
    private final String opcao;

    Tipo(String opcao) {
        this.opcao = opcao;
    }

    /**
     * Retorna o código TIPMOV correspondente a este tipo de movimento.
     *
     * @return código de uma letra usado no campo TIPMOV do Sankhya
     */
    public String getOpcao() {
        return opcao;
    }
}
