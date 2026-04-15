package br.com.spark.transferencia.listeners;

/**
 * <b>Nome:</b> DelecaoTransfencia<br>
 * <b>Tipo:</b> Listener de Evento ({@link br.com.sankhya.extensions.eventoprogramavel.EventoProgramavelJava})<br>
 * <b>Descrição:</b> Intercepta a exclusão de notas vinculadas ao processo de transferência
 * entre empresas. Implementa duas responsabilidades:
 * <ul>
 *   <li>{@code beforeDelete}: valida se a nota correlata (entrada ou saída da transferência)
 *       está confirmada ou já foi gerada no Livro de ICMS — bloqueia a exclusão nesses casos.</li>
 *   <li>{@code afterDelete}: em cascata, exclui automaticamente a nota vinculada
 *       (entrada ou saída) via {@code JapeWrapper.delete()}.</li>
 * </ul>
 *
 * <p><b>Campos monitorados em TGFCAB:</b> AD_NUNOTAENT, AD_NUNOTASAI</p>
 * <p><b>Empresa:</b> Spark Eletrônica</p>
 *
 * <p><i>Nota: o nome da classe contém um erro tipográfico ("Transfencia" em vez de
 * "Transferencia"). Mantido por compatibilidade com o registro do evento no Sankhya.</i></p>
 *
 * @author Silvio Vieira
 * @version 1.0
 * @since 2023
 * @see br.com.spark.transferencia.GerarTransferencia
 */
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
			// Validando DELETE saída
            String ehConfirmada = NativeSql.getString("STATUSNOTA", "TGFCAB", "NUNOTA = " + cabVO.asBigDecimal("AD_NUNOTAENT"));
            String ehLivro = NativeSql.getBigDecimal("COUNT(0)", "TGFLIV", "NUNOTA = " + cabVO.asBigDecimal("AD_NUNOTAENT")).intValue() > 0 ? "S" : "N";
            if("L".equals(ehConfirmada) && "S".equals(ehLivro))
	            throw (Exception)SKError.registry(TSLevel.ERROR, "CORE_SPARK", new Exception("Não foi possível deletar o documento pois a entrada de transferência está no Livro de ICMS")); 
		}else if(cabVO.asBigDecimalOrZero("AD_NUNOTASAI").compareTo(BigDecimalUtil.ZERO_VALUE) > 0) {
			// Validando DELETE entrada
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
