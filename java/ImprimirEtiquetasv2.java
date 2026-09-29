package botaoAcao;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import com.sankhya.util.SessionFile;
import com.sankhya.util.UIDGenerator;

import br.com.sankhya.extensions.actionbutton.AcaoRotinaJava;
import br.com.sankhya.extensions.actionbutton.ContextoAcao;
import br.com.sankhya.extensions.actionbutton.QueryExecutor;
import br.com.sankhya.extensions.actionbutton.Registro;
import br.com.sankhya.jape.EntityFacade;
import br.com.sankhya.jape.dao.JdbcWrapper;
import br.com.sankhya.jape.sql.NativeSql;
import br.com.sankhya.jape.wrapper.JapeFactory;
import br.com.sankhya.modelcore.util.ArquivoModeloUtils;
import br.com.sankhya.modelcore.util.EntityFacadeFactory;
import br.com.sankhya.modelcore.util.Report;
import br.com.sankhya.modelcore.util.ReportManager;
import br.com.sankhya.util.ConcatenatePDF;
import br.com.sankhya.ws.ServiceContext;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperPrint;

public class ImprimirEtiquetasv2 implements AcaoRotinaJava {

	private StringBuilder msgErro = new StringBuilder();
//	private BigDecimal nunota = new BigDecimal(0);
//	private BigDecimal nroRelatorio = new BigDecimal(0);
	// private BigDecimal codFunc = new BigDecimal(0);

	public void doAction(ContextoAcao ctx) throws Exception {

		for (int i = 0; i < ctx.getLinhas().length; i++) {
			Registro line = ctx.getLinhas()[i];

			System.out.println("silvio vieira Inicio");

			try {

				gerarRelatorio(ctx, line);

			} catch (Exception e) {
				e.printStackTrace();
			}

		}

	}

	private void gerarRelatorio(ContextoAcao ctx, Registro line) throws Exception {

		msgErro = new StringBuilder();
		// BigDecimal codEmp = (BigDecimal) line.getCampo("CODEMP");
		// BigDecimal ordemCarga = (BigDecimal) line.getCampo("ORDEMCARGA");
		BigDecimal nunota = (BigDecimal) line.getCampo("NUNOTA");

		System.out.println("silvio vieira parametros:  IPIPROC: " + nunota);

		// imprime a nota NFE
		JdbcWrapper jdbc = JapeFactory.getEntityFacade().getJdbcWrapper();
		NativeSql nativeSql = new NativeSql(jdbc);
		// StringBuilder sql = new StringBuilder();
		jdbc.openSession();

		QueryExecutor queryCON = ctx.getQuery();

		queryCON.nativeSelect(
				" SELECT COUNT(SERIE) AS COUNT " + "   FROM TGFSER " + "  WHERE NUNOTA = " + nunota);

		System.out.println(queryCON.toString());

		while (queryCON.next()) {

			Integer count = queryCON.getInt("COUNT");
			
			System.out.println("silvio vieira parametros:  qtdlinhas: " + count);

			EntityFacade dwfEntityFacade = EntityFacadeFactory.getDWFFacade();
			BigDecimal nroRelatorio = new BigDecimal(138);
			BigDecimal nroRelatorio2 = new BigDecimal(142);
			BigDecimal nroRelatorio3 = new BigDecimal(143);
			BigDecimal nroRelatorio4 = new BigDecimal(144);
			BigDecimal nroRelatorio5 = new BigDecimal(145);
			BigDecimal nroRelatorio6 = new BigDecimal(146);
			byte[] arqFatura = null;
			byte[] parte2 = null;
			byte[] parte3 = null;
			byte[] parte4 = null;
			byte[] parte5 = null;
			byte[] parte6 = null;

			Map<String, Object> parameters = new HashMap<String, Object>();
			Report modeloImpressao = null;
			JasperPrint jasperPrint = null;

			parameters = new HashMap<String, Object>();
			parameters.put("NUNOTA", nunota);
			parameters.put("PDIR_MODELO", ArquivoModeloUtils.getDiretorioModelos());

			modeloImpressao = ReportManager.getInstance().getReport(nroRelatorio, dwfEntityFacade);

			jasperPrint = modeloImpressao.buildJasperPrint(parameters, jdbc.getConnection());

			arqFatura = JasperExportManager.exportReportToPdf(jasperPrint);
			
			System.out.println("silvio vieira parametros:  fim relatorio 1: ");

			// relatorio 2
			Map<String, Object> parameters2 = new HashMap<String, Object>();
			Report modeloImpressao2 = null;
			JasperPrint jasperPrint2 = null;

			parameters2 = new HashMap<String, Object>();
			parameters2.put("NUNOTA", nunota);
			parameters2.put("PDIR_MODELO", ArquivoModeloUtils.getDiretorioModelos());

			modeloImpressao2 = ReportManager.getInstance().getReport(nroRelatorio2, dwfEntityFacade);

			jasperPrint2 = modeloImpressao2.buildJasperPrint(parameters2, jdbc.getConnection());

			parte2 = JasperExportManager.exportReportToPdf(jasperPrint2);
			
			System.out.println("silvio vieira parametros:  fim relatorio 2: ");


			// relatorio 3
			Map<String, Object> parameters3 = new HashMap<String, Object>();
			Report modeloImpressao3 = null;
			JasperPrint jasperPrint3 = null;

			parameters3 = new HashMap<String, Object>();
			parameters3.put("NUNOTA", nunota);
			parameters3.put("PDIR_MODELO", ArquivoModeloUtils.getDiretorioModelos());

			modeloImpressao3 = ReportManager.getInstance().getReport(nroRelatorio3, dwfEntityFacade);

			jasperPrint3 = modeloImpressao3.buildJasperPrint(parameters3, jdbc.getConnection());

			parte3 = JasperExportManager.exportReportToPdf(jasperPrint3);
			
			System.out.println("silvio vieira parametros:  fim relatorio 3: ");


			// relatorio 4

			Map<String, Object> parameters4 = new HashMap<String, Object>();
			Report modeloImpressao4 = null;
			JasperPrint jasperPrint4 = null;

			parameters4 = new HashMap<String, Object>();
			parameters4.put("NUNOTA", nunota);
			parameters4.put("PDIR_MODELO", ArquivoModeloUtils.getDiretorioModelos());

			modeloImpressao4 = ReportManager.getInstance().getReport(nroRelatorio4, dwfEntityFacade);

			jasperPrint4 = modeloImpressao4.buildJasperPrint(parameters4, jdbc.getConnection());

			parte4 = JasperExportManager.exportReportToPdf(jasperPrint4);

			System.out.println("silvio vieira parametros:  fim relatorio 4: ");

			// relatorio 5

			Map<String, Object> parameters5 = new HashMap<String, Object>();
			Report modeloImpressao5 = null;
			JasperPrint jasperPrint5 = null;

			parameters5 = new HashMap<String, Object>();
			parameters5.put("NUNOTA", nunota);
			parameters5.put("PDIR_MODELO", ArquivoModeloUtils.getDiretorioModelos());

			modeloImpressao5 = ReportManager.getInstance().getReport(nroRelatorio5, dwfEntityFacade);

			jasperPrint5 = modeloImpressao5.buildJasperPrint(parameters5, jdbc.getConnection());

			parte5 = JasperExportManager.exportReportToPdf(jasperPrint5);
			
			System.out.println("silvio vieira parametros:  fim relatorio 5: ");


			// relatorio 6

			Map<String, Object> parameters6 = new HashMap<String, Object>();
			Report modeloImpressao6 = null;
			JasperPrint jasperPrint6 = null;

			parameters6 = new HashMap<String, Object>();
			parameters6.put("NUNOTA", nunota);
			parameters6.put("PDIR_MODELO", ArquivoModeloUtils.getDiretorioModelos());

			modeloImpressao6 = ReportManager.getInstance().getReport(nroRelatorio6, dwfEntityFacade);

			jasperPrint6 = modeloImpressao6.buildJasperPrint(parameters6, jdbc.getConnection());

			parte6 = JasperExportManager.exportReportToPdf(jasperPrint6);
			
			System.out.println("silvio vieira parametros:  fim relatorio 6 ");


			// JUNCAO
			ConcatenatePDF arquivos = new ConcatenatePDF();
			arquivos.setNumeration(false);
			arquivos.addPdfFile(arqFatura);
			if (count > 50) {
			arquivos.addPdfFile(parte2);
			System.out.println("silvio vieira parametros:  if 1 ");
			}
			if (count > 100) {
			arquivos.addPdfFile(parte3);
			System.out.println("silvio vieira parametros:  if 2 ");
			}
			if (count > 150) {
			arquivos.addPdfFile(parte4);
			System.out.println("silvio vieira parametros:  if 3 ");
			}
			if (count > 200) {
			arquivos.addPdfFile(parte5);
			System.out.println("silvio vieira parametros:  if 4 ");
			}
			if (count > 250) {
			arquivos.addPdfFile(parte6);
			System.out.println("silvio vieira parametros:  if 1 ");
			}

			byte[] arquivo = arquivos.run().toByteArray();

			SessionFile fileReport = SessionFile.createSessionFile("Relatorios", "application/pdf", arquivo);

			String chaveSessaoArquivo = UIDGenerator.getNextID();

			ServiceContext.getCurrent().putHttpSessionAttribute(chaveSessaoArquivo, (Serializable) fileReport);

			ctx.setMensagemRetorno(
					String.format("%s", getLinkBaixar("Clique aqui para Visualizar.", chaveSessaoArquivo)));

		}

	}

	public static void hexToBinary(InputStream is, OutputStream os) {
		Reader reader = new BufferedReader(new InputStreamReader(is));

		try {
			char buffer[] = new char[2];

			while (reader.read(buffer) != -1) {
				os.write((Character.digit(buffer[0], 16) << 4) + Character.digit(buffer[1], 16));
			}
		} catch (IOException e) {
			System.err.println("An error occurred");
		}
	}

	private String getLinkBaixar(String descricao, String chave) {
		String url = "<a title=\"Visualizar Arquivo\" href=\"/mge/visualizadorArquivos.mge?chaveArquivo=" + chave
				+ "\" target=\"_blank\"><u><b>" + descricao + "</b></u></a>";

		return url;
	}
}
