package br.com.spark.transferencia.listeners;

import java.math.BigDecimal;

import com.sankhya.util.BigDecimalUtil;

import br.com.sankhya.extensions.eventoprogramavel.EventoProgramavelJava;
import br.com.sankhya.jape.event.PersistenceEvent;
import br.com.sankhya.jape.event.TransactionContext;
import br.com.sankhya.jape.sql.NativeSql;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.wrapper.JapeFactory;
import br.com.sankhya.jape.wrapper.JapeWrapper;
import br.com.sankhya.modelcore.util.DynamicEntityNames;
import br.com.sankhya.util.troubleshooting.SKError;
import br.com.sankhya.util.troubleshooting.TSLevel;

public class DelecaoTransfencia implements EventoProgramavelJava{

	@Override
	public void afterDelete(PersistenceEvent eve) throws Exception {
		DynamicVO cabVO = (DynamicVO) eve.getVo();
		if(cabVO.asBigDecimalOrZero("AD_NUNOTAENT").compareTo(BigDecimalUtil.ZERO_VALUE) > 0) {
				JapeWrapper cabDAO = JapeFactory.dao(DynamicEntityNames.CABECALHO_NOTA);
                cabDAO.delete(cabVO.asBigDecimal("AD_NUNOTAENT"));            
		}else if(cabVO.asBigDecimalOrZero("AD_NUNOTASAI").compareTo(BigDecimalUtil.ZERO_VALUE) > 0) {
			    JapeWrapper cabDAO = JapeFactory.dao(DynamicEntityNames.CABECALHO_NOTA);
	            cabDAO.delete(cabVO.asBigDecimal("AD_NUNOTASAI"));	           
		}	
	}

	@Override
	public void afterInsert(PersistenceEvent eve) throws Exception {}

	@Override
	public void afterUpdate(PersistenceEvent eve) throws Exception {}

	@Override
	public void beforeCommit(TransactionContext eve) throws Exception {}

	@Override
	public void beforeDelete(PersistenceEvent eve) throws Exception {
		DynamicVO cabVO = (DynamicVO) eve.getVo();
		if(cabVO.asBigDecimalOrZero("AD_NUNOTAENT").compareTo(BigDecimalUtil.ZERO_VALUE) > 0) {
			//Validando DELETE saída
            String ehConfirmada = NativeSql.getString("STATUSNOTA", "TGFCAB", "NUNOTA = " + cabVO.asBigDecimal("AD_NUNOTAENT"));
            String ehLivro = NativeSql.getBigDecimal("COUNT(0)", "TGFLIV", "NUNOTA = " + cabVO.asBigDecimal("AD_NUNOTAENT")).intValue() > 0 ? "S" : "N";
            if("L".equals(ehConfirmada) && "S".equals(ehLivro))
	            throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("Não foi possível deletar o documento pois a entrada de transferência está no Livro de ICMS")); 
		}else if(cabVO.asBigDecimalOrZero("AD_NUNOTASAI").compareTo(BigDecimalUtil.ZERO_VALUE) > 0) {
			//Validando DELETE entrada
			  String ehConfirmada = NativeSql.getString("STATUSNOTA", "TGFCAB", "NUNOTA = " + cabVO.asBigDecimal("AD_NUNOTASAI"));
	            if("L".equals(ehConfirmada)) 
		            throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("Não foi possível deletar o documento pois a saída de transferência foi confirmada")); 
		}	
		
	}

	@Override
	public void beforeInsert(PersistenceEvent eve) throws Exception {}

	@Override
	public void beforeUpdate(PersistenceEvent eve) throws Exception {}

}
