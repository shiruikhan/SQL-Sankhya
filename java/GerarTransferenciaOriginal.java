package br.com.spark.transferencia;

import br.com.sankhya.extensions.actionbutton.AcaoRotinaJava;
import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.QueryExecutor;
import br.com.sankhya.extensions.actionbutton.Registro;
import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.core.JapeSession;
import br.com.sankhya.jape.core.JapeSession.SessionHandle;
import br.com.sankhya.jape.dao.JdbcWrapper;
import br.com.sankhya.jape.sql.NativeSql;
import br.com.sankhya.jape.util.JapeSessionContext;
import br.com.sankhya.jape.vo.DynamicVO;
import br.com.sankhya.jape.vo.PrePersistEntityState;
import br.com.sankhya.jape.wrapper.JapeFactory;
import br.com.sankhya.jape.wrapper.JapeWrapper;
import br.com.sankhya.jape.wrapper.fluid.FluidCreateVO;
import br.com.sankhya.modelcore.auth.AuthenticationInfo;
import br.com.sankhya.modelcore.comercial.BarramentoRegra;
import br.com.sankhya.modelcore.comercial.centrais.CACHelper;
import br.com.sankhya.modelcore.util.EntityFacadeFactory;
import com.sankhya.util.BigDecimalUtil;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;

public class GerarTransferenciaOriginal implements AcaoRotinaJava {
	
  private String msgRetorno = "";
  private String retorno = "";
  JapeSession.SessionHandle hnd = null;
  
  public void doAction(ContextoAcao ca) throws Exception {
	
	 
    System.out.println("[GerarTransferencia]  - INICIO");
    EntityFacade entityFacade = EntityFacadeFactory.getDWFFacade();
    JdbcWrapper jdbc = entityFacade.getJdbcWrapper();
    NativeSql nativeSql = new NativeSql(jdbc);
    nativeSql.executeUpdate(" DELETE FROM AD_GERARTRANSF ");
    String codEmpOrigStr = (String)ca.getParam("P_CODEMPORIG");
    String codEmpDestinoStr = (String)ca.getParam("P_CODEMPDEST");
    String codLocalOrigStr = (String)ca.getParam("P_CODLOCALORIG");
    String codLocalDestinoStr = (String)ca.getParam("P_CODLOCALDEST");
    BigDecimal nunotaEntrada = new BigDecimal(0);
    BigDecimal nunotaSaida = new BigDecimal(0);
    System.out.println("[GerarTransferencia]  - codemp: " + codEmpOrigStr + "codempdest: " + codEmpDestinoStr);
    BigDecimal codEmpOrig = BigDecimalUtil.valueOf(codEmpOrigStr);
    BigDecimal codEmpDestino = BigDecimalUtil.valueOf(codEmpDestinoStr);
    BigDecimal codLocalOrig = BigDecimalUtil.valueOf(codLocalOrigStr);
    BigDecimal codLocalDestino = BigDecimalUtil.valueOf(codLocalDestinoStr);
    
    for (int i = 0; i < (ca.getLinhas()).length; i++) {
      Registro line = ca.getLinhas()[i];
      JapeSession.SessionHandle hnd = JapeSession.open();
      try {
        System.out.println("thiago bonatti INICIO - PARTE 1 nunota: " + line.getCampo("NUNOTA"));
        BigDecimal nunota = (BigDecimal)line.getCampo("NUNOTA");
        StringBuilder sqlNotas = new StringBuilder();
        sqlNotas.append(" SELECT NVL(AD_NUNOTAENT,0) AS AD_NUNOTAENT , NVL(AD_NUNOTASAI,0) AS AD_NUNOTASAI ");
        sqlNotas.append("   FROM TGFCAB CAB");
        sqlNotas.append("  WHERE CAB.NUNOTA = " + nunota);
        ResultSet rsNotas = nativeSql.executeQuery(sqlNotas.toString());
        while (rsNotas.next()) {
          BigDecimal nunotaEntOld = rsNotas.getBigDecimal("AD_NUNOTAENT");
          BigDecimal nunotaSaiOld = rsNotas.getBigDecimal("AD_NUNOTASAI");
          Integer nunotaEntOldInt = Integer.valueOf(nunotaEntOld.toString());
          Integer nunotaSaiOldInt = Integer.valueOf(nunotaSaiOld.toString());
          hnd = JapeSession.open();
          JapeWrapper impDAO = JapeFactory.dao("AD_GERARTRANSF");
          StringBuilder sql = new StringBuilder();
          sql.append(
              " SELECT CAB.NUNOTA , CAB.NUMNOTA, ITE.SEQUENCIA, CAB.CODPARC, CAB.CODEMP, ITE.CODLOCALORIG, ITE.CODPROD,  ITE.QTDNEG, ITE.CODVOL , ITE.CONTROLE, ");
          sql.append(
              "  CASE WHEN ( SELECT COUNT(*) FROM TGFCON2 WHERE STATUS = 'F' AND NUNOTAORIG = CAB.NUNOTA) > 0 THEN 'S' ELSE 'N' END AS CONF ");
          sql.append("   FROM TGFCAB CAB, TGFITE ITE ");
          sql.append("  WHERE CAB.NUNOTA = ITE.NUNOTA ");
          sql.append("\tAND CAB.NUNOTA = " + nunota);
          try {
            System.out.println(sql.toString());
            ResultSet rs = nativeSql.executeQuery(sql.toString());
            while (rs.next()) {
              String conferido = rs.getString("CONF");
              if (nunotaEntOldInt.intValue() > 0 || nunotaSaiOldInt.intValue() > 0)
                this.retorno = "Este(s) pedido(s) jgerou NF de Transferencia!"; 
              if (conferido.equals("S") && this.retorno == "") {
                BigDecimal sequencia = rs.getBigDecimal("SEQUENCIA");
                BigDecimal codparc = rs.getBigDecimal("CODPARC");
                BigDecimal codemp = rs.getBigDecimal("CODEMP");
                BigDecimal codprod = rs.getBigDecimal("CODPROD");
                BigDecimal qtdneg = rs.getBigDecimal("QTDNEG");
                String codvol = rs.getString("CODVOL");
                String controle = rs.getString("CONTROLE");
                try {
                  DynamicVO dynamicVO = ((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)impDAO.create().set("NUNOTA", nunota)).set("SEQUENCIA", sequencia))
                    .set("CODPARC", codparc)).set("CODEMP", codemp))
                    .set("CODLOCALORIG", codLocalOrig)).set("CODPROD", codprod))
                    .set("QTDNEG", qtdneg)).set("CODVOL", codvol)).set("CONTROLE", controle))
                    .save();
                } catch (Exception e) {
                  e.printStackTrace();
                  continue;
                } finally {
                  System.out.println(" teste");
                } 
                continue;
              } 
              this.retorno = "O pedido nro " + nunota + " ainda nfoi conferido!";
              if (nunotaEntOldInt.intValue() > 0 || nunotaSaiOldInt.intValue() > 0)
                this.retorno = "Este(s) pedido(s) jgerou NF de Transferencia!"; 
            } 
          } catch (Exception e) {
            ca.setMensagemRetorno(e.getMessage());
            e.printStackTrace();
          } 
        } 
      } catch (Exception e) {
        e.printStackTrace();
      } finally {
        jdbc.closeSession();
      } 
    } 
    System.out.println("thiago bonatti parte 2 - inico de gerar a transf");
    if (this.retorno == "") {
      Timestamp pData = null;
      BigDecimal pCodEmp = null;
      BigDecimal pCodCenCus = null;
      BigDecimal pCodParc = null;
      BigDecimal pCodNat = null;
      BigDecimal pCodProj = null;
      BigDecimal pCodTipOper = null;
      String pTipMov = null;
      BigDecimal codTipVenda = null;
      BigDecimal codEmpNegoc = null;
      StringBuffer sql = new StringBuffer();
      QueryExecutor query = ca.getQuery();
      QueryExecutor queryIte = ca.getQuery();
      QueryExecutor queryUpd = ca.getQuery();
      sql.append(" SELECT EMP.CODEMP AS CODEMPDEST,  EMP.CODPARC AS CODPARCORIG, ");
      sql.append(" EMPO.CODEMP AS CODEMPORIG,  EMPO.CODPARC AS CODPARCDEST , SYSDATE AS DATA, ");
      sql.append(" CASE WHEN (SELECT COUNT(*) FROM AD_GERARTRANSF) = 0 THEN 'N' ELSE 'S' END AS TEMLANC  ");
      sql.append("   FROM TSIEMP EMP, TSIEMP EMPO ");
      sql.append("   WHERE EMP.CODEMP = " + codEmpDestino);
      sql.append("     AND EMPO.CODEMP = " + codEmpOrig);
      System.out.println(sql.toString());
      try {
        query.nativeSelect(sql.toString());
        while (query.next()) {
          BigDecimal nuNotaGerado = new BigDecimal(0);
          String temLancamento = query.getString("TEMLANC");
          if (temLancamento.equals("S")) {
            pData = query.getTimestamp("DATA");
            codEmpNegoc = query.getBigDecimal("CODEMPDEST");
            pCodEmp = query.getBigDecimal("CODEMPDEST");
            pCodParc = query.getBigDecimal("CODPARCDEST");
            pCodNat = new BigDecimal(0);
            pCodCenCus = new BigDecimal(0);
            pCodProj = new BigDecimal(0);
            pCodTipOper = new BigDecimal(252);
            pTipMov = "C";
            codTipVenda = new BigDecimal(99);
            String serie = "1";
            EntityFacade dwfEntityFacade = EntityFacadeFactory.getDWFFacade();
            DynamicVO cabVO = (DynamicVO)dwfEntityFacade.getDefaultValueObjectInstance("CabecalhoNota");
            cabVO.setProperty("CODTIPOPER", pCodTipOper);
            cabVO.setProperty("TIPMOV", pTipMov);
            cabVO.setProperty("CODPARC", pCodParc);
            cabVO.setProperty("CODEMP", codEmpNegoc);
            cabVO.setProperty("SERIENOTA", serie);
            cabVO.setProperty("CODEMPNEGOC", pCodEmp);
            cabVO.setProperty("DTNEG", pData);
            cabVO.setProperty("CODNAT", pCodNat);
            cabVO.setProperty("CODCENCUS", pCodCenCus);
            cabVO.setProperty("CODPROJ", pCodProj);
            cabVO.setProperty("CIF_FOB", "S");
            cabVO.setProperty("CODTIPVENDA", codTipVenda);
            try {
              CACHelper cacHelper = new CACHelper();
              AuthenticationInfo auth = AuthenticationInfo.getCurrent();
              JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);
              PrePersistEntityState cabPreState = PrePersistEntityState.build(dwfEntityFacade, 
                  "CabecalhoNota", cabVO);
              BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
              DynamicVO newCabVO = bRegrasCab.getState().getNewVO();
              nuNotaGerado = newCabVO.asBigDecimal("NUNOTA");
              ca.setMensagemRetorno("Entrada Gerada: " + nuNotaGerado);
              System.out.println("Cabeincluido: " + nuNotaGerado);
              nunotaEntrada = nuNotaGerado;
              sql = new StringBuffer();
              sql.append(" SELECT I.CODPROD, I.CODVOL, I.CODLOCALORIG, I.CONTROLE, ");
              sql.append(" SUM(I.QTDNEG) AS QTDNEG, ");
              sql.append(
                  " (SELECT CUSSEMICM FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP =1  AND DTATUAL = (SELECT MAX(DTATUAL) FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP = 1)) AS CUSMED, ");
              sql.append(
                  " (SELECT CUSSEMICM FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP =1  AND DTATUAL = (SELECT MAX(DTATUAL) FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP = 1)) * SUM(I.QTDNEG) AS VLRTOT ");
              sql.append("   FROM AD_GERARTRANSF I ");
              sql.append(" GROUP BY I.CODPROD, I.CODVOL, I.CODLOCALORIG, I.CONTROLE ");
              System.out.println(sql.toString());
              queryIte.nativeSelect(sql.toString());
              while (queryIte.next()) {
                System.out.println("Inicio inclusProduto " + queryIte.getBigDecimal("CODPROD"));
                BigDecimal vlrUnit = queryIte.getBigDecimal("CUSMED");
                BigDecimal vlrTot = queryIte.getBigDecimal("VLRTOT");
                String controlenovo = queryIte.getString("CONTROLE");
                BigDecimal codProd = queryIte.getBigDecimal("CODPROD");
                Collection<PrePersistEntityState> itensNota = new ArrayList<>();
                DynamicVO itemVO = (DynamicVO)dwfEntityFacade
                  .getDefaultValueObjectInstance("ItemNota");
                itemVO.setProperty("CODPROD", queryIte.getBigDecimal("CODPROD"));
                itemVO.setProperty("QTDNEG", queryIte.getBigDecimal("QTDNEG"));
                itemVO.setProperty("VLRUNIT", vlrUnit);
                itemVO.setProperty("VLRTOT", vlrTot);
                itemVO.setProperty("CONTROLE", controlenovo);
                itemVO.setProperty("CODLOCALORIG", codLocalDestino);
                itemVO.setProperty("PERCDESC", BigDecimal.ZERO);
                itemVO.setProperty("VLRDESC", BigDecimal.ZERO);
                itemVO.setProperty("CODVOL", queryIte.getString("CODVOL"));
                PrePersistEntityState itePreState = PrePersistEntityState.build(dwfEntityFacade, 
                    "ItemNota", itemVO);
                itensNota.add(itePreState);
                cacHelper.incluirAlterarItem(nunotaEntrada, auth, itensNota, false);
                BigDecimal sequencia = itemVO.asBigDecimal("SEQUENCIA");
                System.out.println("[GerarTransferencia] - Fim inclusitem CODPROD: " + 
                    queryIte.getBigDecimal("CODPROD") + " sequencia " + sequencia);
                StringBuffer sqlSerie = new StringBuffer();
                QueryExecutor querySerie = ca.getQuery();
                sqlSerie = new StringBuffer();
                sqlSerie.append(" SELECT N.CODPROD, SER.SERIE, 0 AS ATUALESTOQUE, 'N' AS TIPCONTEST ");
                sqlSerie.append("  FROM AD_GERARTRANSF N ,TGFSER SER ");
                sqlSerie.append(" WHERE N.NUNOTA = SER.NUNOTA ");
                sqlSerie.append("   AND N.SEQUENCIA = SER.SEQUENCIA");
                querySerie.nativeSelect(sqlSerie.toString());
                while (querySerie.next()) {
                  System.out.println("[GerarTransferencia] - inicio da inclusda TGFSER  sequencia " + 
                      sequencia);
                  String controle = querySerie.getString("SERIE");
                  String ticontest = querySerie.getString("TIPCONTEST");
                  BigDecimal atualEstoque = querySerie.getBigDecimal("ATUALESTOQUE");
                  JapeWrapper impDAO = JapeFactory.dao("SerieProduto");
                  try {
                	  /*
                    DynamicVO dynamicVO = impDAO.create().set("NUNOTA", nunotaEntrada))
                      .set("CODPROD", codProd)).set("SEQUENCIA", sequencia))
                      .set("SERIE", controle)).set("ATUALESTOQUE", atualEstoque))   
                      .save();
                     */
                  } catch (Exception e) {
                    e.printStackTrace();
                    continue;
                  } finally {
                    System.out.println(" teste");
                  } 
                } 
              } 
              nativeSql.executeUpdate(" UPDATE TGFCAB SET AD_NUNOTAENT = " + nunotaEntrada + 
                  " WHERE NUNOTA IN (SELECT NUNOTA FROM AD_GERARTRANSF)");
            } catch (Exception e) {
              System.out.println("GeraMovPortal: erro NUNOTA: " + nunotaEntrada);
              this.msgRetorno = String.valueOf(this.msgRetorno) + e.getMessage();
              e.printStackTrace();
            } 
            
            //Entrada
            pData = query.getTimestamp("DATA");
            codEmpNegoc = query.getBigDecimal("CODEMPORIG");
            pCodEmp = query.getBigDecimal("CODEMPORIG");
            pCodParc = query.getBigDecimal("CODPARCORIG");
            pCodNat = new BigDecimal(0);
            pCodCenCus = new BigDecimal(0);
            pCodProj = new BigDecimal(0);
            pCodTipOper = new BigDecimal(1452);
            pTipMov = "V";
            codTipVenda = new BigDecimal(99);
            cabVO = (DynamicVO)dwfEntityFacade
              .getDefaultValueObjectInstance("CabecalhoNota");
            cabVO.setProperty("CODTIPOPER", pCodTipOper);
            cabVO.setProperty("TIPMOV", pTipMov);
            cabVO.setProperty("CODPARC", pCodParc);
            cabVO.setProperty("CODEMP", codEmpNegoc);
            cabVO.setProperty("SERIENOTA", serie);
            cabVO.setProperty("CODEMPNEGOC", pCodEmp);
            cabVO.setProperty("DTNEG", pData);
            cabVO.setProperty("CODNAT", pCodNat);
            cabVO.setProperty("CODCENCUS", pCodCenCus);
            cabVO.setProperty("CODPROJ", pCodProj);
            cabVO.setProperty("CIF_FOB", "S");
            cabVO.setProperty("CODTIPVENDA", codTipVenda);
            nuNotaGerado = new BigDecimal(0);
            try {
              CACHelper cacHelper = new CACHelper();
              AuthenticationInfo auth = AuthenticationInfo.getCurrent();
              JapeSessionContext.putProperty("br.com.sankhya.com.CentralCompraVenda", Boolean.TRUE);
              PrePersistEntityState cabPreState = PrePersistEntityState.build(dwfEntityFacade, 
                  "CabecalhoNota", cabVO);
              BarramentoRegra bRegrasCab = cacHelper.incluirAlterarCabecalho(auth, cabPreState);
              DynamicVO newCabVO = bRegrasCab.getState().getNewVO();
              nunotaSaida = newCabVO.asBigDecimal("NUNOTA");
              ca.setMensagemRetorno("saida Gerada: " + nunotaSaida);
              System.out.println("Cabeincluido saida: " + nunotaSaida);
              sql = new StringBuffer();
              sql.append(" SELECT I.CODPROD, I.CODVOL, I.CODLOCALORIG, I.CONTROLE, ");
              sql.append(" SUM(I.QTDNEG) AS QTDNEG, ");
              sql.append(
                  " (SELECT CUSSEMICM FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP =1  AND DTATUAL = (SELECT MAX(DTATUAL) FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP = 1)) AS CUSMED, ");
              sql.append(
                  " (SELECT CUSSEMICM FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP =1  AND DTATUAL = (SELECT MAX(DTATUAL) FROM TGFCUS WHERE CODPROD = I.CODPROD AND CODEMP = 1)) * SUM(I.QTDNEG) AS VLRTOT ");
              sql.append("   FROM AD_GERARTRANSF I ");
              sql.append(" GROUP BY I.CODPROD, I.CODVOL, I.CODLOCALORIG, I.CONTROLE ");
              System.out.println(sql.toString());
              queryIte.nativeSelect(sql.toString());
              while (queryIte.next()) {
                System.out.println("Inicio inclusProduto " + queryIte.getBigDecimal("CODPROD"));
                BigDecimal vlrUnit = queryIte.getBigDecimal("CUSMED");
                BigDecimal vlrTot = queryIte.getBigDecimal("VLRTOT");
                String controlenovo = queryIte.getString("CONTROLE");
                BigDecimal codProd = queryIte.getBigDecimal("CODPROD");
                Collection<PrePersistEntityState> itensNota = new ArrayList<>();
                DynamicVO itemVO = (DynamicVO)dwfEntityFacade
                  .getDefaultValueObjectInstance("ItemNota");
                itemVO.setProperty("CODPROD", queryIte.getBigDecimal("CODPROD"));
                itemVO.setProperty("QTDNEG", queryIte.getBigDecimal("QTDNEG"));
                itemVO.setProperty("VLRUNIT", vlrUnit);
                itemVO.setProperty("VLRTOT", vlrTot);
                itemVO.setProperty("CONTROLE", controlenovo);
                itemVO.setProperty("CODLOCALORIG", codLocalOrig);
                itemVO.setProperty("PERCDESC", BigDecimal.ZERO);
                itemVO.setProperty("VLRDESC", BigDecimal.ZERO);
                itemVO.setProperty("CODVOL", queryIte.getString("CODVOL"));
                PrePersistEntityState itePreState = PrePersistEntityState.build(dwfEntityFacade, 
                    "ItemNota", itemVO);
                itensNota.add(itePreState);
                cacHelper.incluirAlterarItem(nunotaSaida, auth, itensNota, false);
                BigDecimal sequencia = itemVO.asBigDecimal("SEQUENCIA");
                System.out.println("Fim inclusnota de saida" + queryIte.getBigDecimal("CODPROD"));
                StringBuffer sqlSerie = new StringBuffer();
                QueryExecutor querySerie = ca.getQuery();
                sqlSerie = new StringBuffer();
                sqlSerie.append(" SELECT N.CODPROD, SER.SERIE, 0 AS ATUALESTOQUE, 'N' AS TIPCONTEST ");
                sqlSerie.append("  FROM AD_GERARTRANSF N ,TGFSER SER ");
                sqlSerie.append(" WHERE N.NUNOTA = SER.NUNOTA ");
                sqlSerie.append("   AND N.SEQUENCIA = SER.SEQUENCIA");
                querySerie.nativeSelect(sqlSerie.toString());
                while (querySerie.next()) {
                  String controle = querySerie.getString("SERIE");
                  String ticontest = querySerie.getString("TIPCONTEST");
                  BigDecimal atualEstoque = querySerie.getBigDecimal("ATUALESTOQUE");
                  JapeWrapper impDAO = JapeFactory.dao("SerieProduto");
                  try {
                    DynamicVO dynamicVO = ((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)((FluidCreateVO)impDAO.create().set("NUNOTA", nunotaSaida))
                      .set("CODPROD", codProd)).set("SEQUENCIA", sequencia))
                      .set("SERIE", controle)).set("ATUALESTOQUE", atualEstoque))
                      
                      .save();
                  } catch (Exception e) {
                    e.printStackTrace();
                    continue;
                  } finally {
                    System.out.println(" teste");
                  } 
                } 
              } 
              nativeSql.executeUpdate(" UPDATE TGFCAB SET AD_NUNOTASAI = " + nunotaSaida + 
                  " WHERE NUNOTA IN (SELECT NUNOTA FROM AD_GERARTRANSF)");
            } catch (Exception e) {
              System.out.println("GeraMovPortal: erro NUNOTA saida: " + nunotaSaida);
              this.msgRetorno = String.valueOf(this.msgRetorno) + e.getMessage();
              e.printStackTrace();
            } 
            continue;
          } 
          return;
        } 
      } catch (Exception e) {
        this.msgRetorno = String.valueOf(this.msgRetorno) + e.getMessage();
        e.printStackTrace();
      } finally {
        ca.setMensagemRetorno("Nro Nota de Entrada: " + nunotaEntrada + " <br> " + 
            "Nro Nota de Saida: " + nunotaSaida);
        query.close();
        queryIte.close();
        queryUpd.close();
      } 
    } else {
      ca.setMensagemRetorno(this.retorno);
    } 
  }
}
