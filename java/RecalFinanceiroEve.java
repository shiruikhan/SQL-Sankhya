package br.com.dm.valida.cte;

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