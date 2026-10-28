/*
 * Renderizador local do DANFE (report 40) para teste de layout sem emitir nota.
 *
 * Compila os 3 .jrxml de ../ (versao de teste), preenche com um XML de NF-e
 * e gera uma PNG por pagina em saida/.
 *
 * Simulacoes (diferencas em relacao ao Sankhya):
 *  - JDBC_CONNECTION e uma conexao falsa que devolve consultas vazias:
 *    trechos via Funcoes.pdes (AD_DESCNFE, faturas, etc.) saem em branco.
 *  - XPath via javax.xml.xpath do JDK (o servidor usa Xalan).
 *
 * Uso: ver render.sh
 */

import java.io.File;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRExporterParameter;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.data.JRXmlDataSource;
import net.sf.jasperreports.engine.export.JRGraphics2DExporter;
import net.sf.jasperreports.engine.export.JRGraphics2DExporterParameter;
import net.sf.jasperreports.engine.util.JRProperties;
import net.sf.jasperreports.engine.util.xml.JRXPathExecuter;
import net.sf.jasperreports.engine.util.xml.JRXPathExecuterFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

public class RenderDanfe {

    /** XPath do JDK no lugar do Xalan, que nao esta em nativo/libs. */
    public static class JdkXPathExecuterFactory implements JRXPathExecuterFactory {
        public JRXPathExecuter getXPathExecuter() {
            return new JRXPathExecuter() {
                private final XPath xp = XPathFactory.newInstance().newXPath();

                public NodeList selectNodeList(Node ctx, String expr) throws JRException {
                    try {
                        return (NodeList) xp.evaluate(expr, ctx, XPathConstants.NODESET);
                    } catch (XPathExpressionException e) {
                        throw new JRException(e);
                    }
                }

                public Object selectObject(Node ctx, String expr) throws JRException {
                    try {
                        NodeList nl = (NodeList) xp.evaluate(expr, ctx, XPathConstants.NODESET);
                        return nl.getLength() == 0 ? null : nl.item(0);
                    } catch (XPathExpressionException e) {
                        try {
                            return xp.evaluate(expr, ctx, XPathConstants.STRING);
                        } catch (XPathExpressionException e2) {
                            throw new JRException(e2);
                        }
                    }
                }
            };
        }
    }

    /** Conexao falsa: toda consulta devolve ResultSet vazio. */
    private static Connection conexaoVazia() {
        final InvocationHandler rs = new InvocationHandler() {
            public Object invoke(Object p, Method m, Object[] a) {
                return padrao(m.getReturnType());
            }
        };
        final InvocationHandler st = new InvocationHandler() {
            public Object invoke(Object p, Method m, Object[] a) {
                if (m.getReturnType() == ResultSet.class) {
                    return Proxy.newProxyInstance(ResultSet.class.getClassLoader(), new Class[] { ResultSet.class }, rs);
                }
                return padrao(m.getReturnType());
            }
        };
        InvocationHandler cn = new InvocationHandler() {
            public Object invoke(Object p, Method m, Object[] a) {
                Class<?> t = m.getReturnType();
                if (Statement.class.isAssignableFrom(t)) {
                    return Proxy.newProxyInstance(t.getClassLoader(), new Class[] { t }, st);
                }
                return padrao(t);
            }
        };
        return (Connection) Proxy.newProxyInstance(Connection.class.getClassLoader(), new Class[] { Connection.class }, cn);
    }

    private static Object padrao(Class<?> t) {
        if (t == boolean.class) return Boolean.FALSE;
        if (t == int.class) return 0;
        if (t == long.class) return 0L;
        if (t == double.class) return 0d;
        if (t == float.class) return 0f;
        if (t == short.class) return (short) 0;
        if (t == byte.class) return (byte) 0;
        return null;
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 3) {
            System.err.println("uso: RenderDanfe <dir dos jrxml> <xml da nota> <dir de saida>");
            System.exit(1);
        }
        File dirJrxml = new File(args[0]);
        File xml = new File(args[1]);
        File saida = new File(args[2]);
        saida.mkdirs();

        JRProperties.setProperty("net.sf.jasperreports.xpath.executer.factory", JdkXPathExecuterFactory.class.getName());

        // Os .jasper ficam com o nome que o relatorio principal referencia (./danfe_retrato_sub.jasper)
        File build = new File(saida, "jasper");
        build.mkdirs();
        String[][] arquivos = {
            { "danfe_retrato_itens_4.0.jrxml", "danfe_retrato_itens.jasper" },
            { "danfe_retrato_sub_4.0_BKP.jrxml", "danfe_retrato_sub.jasper" },
            { "danfe_retrato_4.0.jrxml", "danfe_retrato.jasper" },
        };
        for (String[] a : arquivos) {
            System.out.println("compilando " + a[0]);
            JasperCompileManager.compileReportToFile(new File(dirJrxml, a[0]).getPath(), new File(build, a[1]).getPath());
        }

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        Document doc = dbf.newDocumentBuilder().parse(xml);
        // XML autorizado vem como <nfeProc><NFe>...; o DANFE espera a raiz <NFe> (/NFe/infNFe/infAdic/...)
        Element raiz = doc.getDocumentElement();
        if (!"NFe".equals(raiz.getLocalName() != null ? raiz.getLocalName() : raiz.getNodeName())) {
            NodeList nfe = raiz.getElementsByTagName("NFe");
            if (nfe.getLength() == 0) {
                throw new IllegalArgumentException("XML sem elemento <NFe>");
            }
            Document novo = dbf.newDocumentBuilder().newDocument();
            novo.appendChild(novo.importNode(nfe.item(0), true));
            doc = novo;
        }
        // O namespace do portal fiscal quebraria os XPath sem prefixo do relatorio: remove reparseando sem namespace
        String semNs = paraTexto(doc).replaceAll(" xmlns=\"[^\"]*\"", "");
        doc = dbf.newDocumentBuilder().parse(new org.xml.sax.InputSource(new java.io.StringReader(semNs)));

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("NUNOTA", new java.math.BigDecimal(0));
        params.put("IMPITENSNFE", new java.math.BigDecimal(0));
        params.put("JDBC_CONNECTION", conexaoVazia());

        // Subrelatorios sao carregados por caminho relativo (./danfe_retrato_sub.jasper):
        // render.sh executa a JVM a partir de saida/jasper
        JasperReport principal = (JasperReport) net.sf.jasperreports.engine.util.JRLoader.loadObject(new File(build, "danfe_retrato.jasper"));
        // Numeros do XML usam ponto decimal; sem isso o locale pt_BR le "180.40" como 18040
        JRXmlDataSource ds = new JRXmlDataSource(doc, "//infNFe");
        ds.setLocale(java.util.Locale.US);
        JasperPrint print = JasperFillManager.fillReport(principal, params, ds);

        int paginas = print.getPages().size();
        for (int i = 0; i < paginas; i++) {
            float zoom = 2f;
            BufferedImage img = new BufferedImage((int) (print.getPageWidth() * zoom), (int) (print.getPageHeight() * zoom), BufferedImage.TYPE_INT_RGB);
            Graphics2D g = img.createGraphics();
            g.setColor(java.awt.Color.WHITE);
            g.fillRect(0, 0, img.getWidth(), img.getHeight());
            JRGraphics2DExporter exp = new JRGraphics2DExporter();
            exp.setParameter(JRExporterParameter.JASPER_PRINT, print);
            exp.setParameter(JRGraphics2DExporterParameter.GRAPHICS_2D, g);
            exp.setParameter(JRExporterParameter.PAGE_INDEX, Integer.valueOf(i));
            exp.setParameter(JRGraphics2DExporterParameter.ZOOM_RATIO, Float.valueOf(zoom));
            exp.exportReport();
            g.dispose();
            File png = new File(saida, "pagina-" + (i + 1) + ".png");
            ImageIO.write(img, "png", png);
            System.out.println("gerado " + png.getPath());
        }
    }

    private static String paraTexto(Document doc) throws Exception {
        javax.xml.transform.Transformer t = javax.xml.transform.TransformerFactory.newInstance().newTransformer();
        java.io.StringWriter sw = new java.io.StringWriter();
        t.transform(new javax.xml.transform.dom.DOMSource(doc), new javax.xml.transform.stream.StreamResult(sw));
        return sw.toString();
    }
}
