package br.com.dm.valida.cte;

/**
 * <b>Nome:</b> RecalFinanceiroEve<br>
 * <b>Tipo:</b> Evento Programável ({@link br.com.sankhya.extensions.eventoprogramavel.EventoProgramavelJava})<br>
 * <b>Descrição:</b> Recalcula os lançamentos financeiros de uma nota durante a confirmação.
 * Acionado no {@code beforeUpdate} de {@code TGFCAB} quando o campo {@code AD_AGDIMPCTE}
 * muda de nulo/N para S enquanto o atributo {@code CONFIRMANDO} está ativo na sessão.
 * Utiliza {@link br.com.sankhya.modelcore.comercial.CentralFinanceiro} para refazer o
 * financeiro vinculado à nota.
 *
 * <p><b>Evento ativo:</b> {@code beforeUpdate}</p>
 * <p><b>Entidade monitorada:</b> CabecalhoNota (TGFCAB)</p>
 * <p><b>Campo gatilho:</b> AD_AGDIMPCTE — flag de agendamento de impressão de CT-e</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * @author Silvio Vieira
 * @version 1.0
 * @since 2023
 */
import java.math.BigDecimal;

import br.com.sankhya.extensions.eventoprogramavel.EventoProgramavelJava;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.event.PersistenceEvent;
import br.com.sankhya.jape.event.TransactionContext;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.modelcore.comercial.AtributosRegras;
import br.com.sankhya.modelcore.comercial.CentralFinanceiro;

public class RecalFinanceiroEve implements EventoProgramavelJava{

	@Override
	public void beforeUpdate(PersistenceEvent ctx) throws Exception {
		
		DynamicVO cabVO = (DynamicVO) ctx.getVo();
		DynamicVO cabOldVO = (DynamicVO) ctx.getOldVO();
		
		if (   JapeSession.getProperty(AtributosRegras.CONFIRMANDO)!= null
			&& "S".equals(cabVO.asString("AD_AGDIMPCTE")) 
			&& (validaField(cabOldVO.asString("AD_AGDIMPCTE"))) 
		   ) {
				BigDecimal nuNota = cabVO.asBigDecimal("NUNOTA");
				CentralFinanceiro cin = new CentralFinanceiro();
				cin.inicializaNota(nuNota);
				cin.refazerFinanceiro();
		}
		
	}

	@Override
	public void afterDelete(PersistenceEvent event) throws Exception {}

	@Override
	public void afterInsert(PersistenceEvent event) throws Exception {}
	
	@Override
	public void beforeCommit(TransactionContext tranCtx) throws Exception {}

	@Override
	public void beforeDelete(PersistenceEvent event) throws Exception {}

	@Override
	public void beforeInsert(PersistenceEvent event) throws Exception {}

	@Override
	public void afterUpdate(PersistenceEvent event) throws Exception {}

	public static boolean validaField (String campo) {		
		return campo == null || "N".equals(campo);
	}
}