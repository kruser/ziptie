package org.ziptie.server.birt;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.eclipse.birt.report.engine.api.EngineConstants;
import org.eclipse.birt.report.engine.api.EngineException;
import org.eclipse.birt.report.engine.api.HTMLCompleteImageHandler;
import org.eclipse.birt.report.engine.api.HTMLRenderContext;
import org.eclipse.birt.report.engine.api.HTMLRenderOption;
import org.eclipse.birt.report.engine.api.IImage;
import org.eclipse.birt.report.engine.api.IPDFRenderOption;
import org.eclipse.birt.report.engine.api.IRenderOption;
import org.eclipse.birt.report.engine.api.IRenderTask;
import org.eclipse.birt.report.engine.api.IReportDocument;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.PDFRenderOption;
import org.eclipse.birt.report.engine.api.RenderOption;
import org.hibernate.Criteria;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Restrictions;
import org.ziptie.provider.tools.PluginExecRecord;
import org.ziptie.server.birt.internal.BirtActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * RenderElf
 * 
 * This class provides a method to render a BIRT intermediate format file into
 * a final output format.  It contains a simple cache of final report temporary
 * files so that the most recently requested files are kept in the cache to
 * allow serving to the client without re-processing.
 */
@SuppressWarnings("deprecation")
public final class RenderElf
{
    private static final Logger LOGGER = Logger.getLogger(RenderElf.class);

    private static OutputRenderMap<String, File> outputRenderMap;
    private static Map<String, String> formatMimeMap;

    static
    {
        outputRenderMap = new OutputRenderMap<String, File>();
        
        formatMimeMap = new HashMap<String, String>();
        formatMimeMap.put("pdf", "application/pdf"); //$NON-NLS-1$ //$NON-NLS-2$
        formatMimeMap.put("html", "text/html"); //$NON-NLS-1$ //$NON-NLS-2$
        formatMimeMap.put("xls", "application/vnd.ms-excel"); //$NON-NLS-1$//$NON-NLS-2$
    }

    private RenderElf()
    {
        // private constructor
    }

    /**
     * Get the cached version of a report.  Returns <code>null</code> if the
     * report is not cached.
     *
     * @param execId the GUID of the report
     * @param format the desired format of the report
     * @return a <code>File</code> pointing to the report, or null if not in
     *    cache
     */
    public static File getCachedReport(int execId, String format)
    {
        File file = outputRenderMap.get(execId + format);

        return (file != null && file.exists() ? file : null);
    }

    /**
     * Render the BIRT intermediate file into the requested output format.
     *
     * @param rptDocFile a file containing BIRT intermediate output format
     * @param format the format specifier ("pdf", "html", "xls", etc.)
     * @return the file containing the final rendered output
     * @throws EngineException
     * @throws IOException
     */
    @SuppressWarnings("unchecked")
    public static File render(File rptDocFile, int execId, String format) throws EngineException, IOException
    {
        File outFile = outputRenderMap.get(execId + format);
        if (outFile != null && outFile.exists())
        {
            return outFile;
        }

        boolean owner = TransactionElf.beginOrJoinTransaction();
        try
        {
            Session session = BirtActivator.getSessionFactory().getCurrentSession();
            Criteria criteria = session.createCriteria(PluginExecRecord.class);
            criteria.add(Restrictions.sqlRestriction("execution_id = " + execId)); //$NON-NLS-1$
            PluginExecRecord pluginExec = (PluginExecRecord) criteria.uniqueResult();
            
            outFile = File.createTempFile("birt", "." + format); //$NON-NLS-1$ //$NON-NLS-2$
            outFile.deleteOnExit();

            IReportEngine reportEngine = BirtActivator.getReportPluginManager().getReportEngine(pluginExec.getPluginName());
            try
            {
                IReportDocument reportDoc = reportEngine.openReportDocument(rptDocFile.getAbsolutePath());
                IRenderTask renderTask = reportEngine.createRenderTask(reportDoc);
                
                IRenderOption options = new RenderOption();
                options.setOutputFileName(outFile.getAbsolutePath());
                if ("pdf".equalsIgnoreCase(format)) //$NON-NLS-1$
                {
                    reportEngine.getConfig().getAppContext().put(EngineConstants.APPCONTEXT_CHART_RESOLUTION, Integer.valueOf(600));
                    
                    options.setOutputFormat(IRenderOption.OUTPUT_FORMAT_PDF);
                    
                    PDFRenderOption pdfOptions = new PDFRenderOption(options);
                    pdfOptions.setOption(IPDFRenderOption.FIT_TO_PAGE, new Boolean(true));
                    pdfOptions.setOption(IPDFRenderOption.PAGEBREAK_PAGINATION_ONLY, new Boolean(false));
                    renderTask.setRenderOption(pdfOptions);
                }
                else if ("html".equalsIgnoreCase(format)) //$NON-NLS-1$
                {
                    options.setOutputFormat(IRenderOption.OUTPUT_FORMAT_HTML);
                    
                    HTMLRenderOption htmlOptions = new HTMLRenderOption(options);
                    htmlOptions.setSupportedImageFormats("PNG"); //$NON-NLS-1$
                    htmlOptions.setBaseImageURL(String.format("pluginDetail?executionId=%d&image=", execId)); //$NON-NLS-1$
                    htmlOptions.setImageHandler(new HTMLImageHandler(outFile.getName().replace("." + format, ""))); //$NON-NLS-1$ //$NON-NLS-2$

                    renderTask.setRenderOption(htmlOptions);
                }
        
                renderTask.render();
                renderTask.close();

                if (!outFile.exists() || outFile.length() == 0)
                {
                    LOGGER.error("Zero length report output file."); //$NON-NLS-1$
                }

                outputRenderMap.put(execId + format, outFile);
            }
            finally
            {
                reportEngine.destroy();
            }
        }
        finally
        {
            if (owner)
            {
                TransactionElf.commit();
            }
        }

        return outFile;
    }

    /**
     * Get the MIME type for files with the specified extension.
     *
     * @param extension the file extension
     * @return the MIME type for the extension or <code>null</code>
     */
    public static String getMimeType(String extension)
    {
        return formatMimeMap.get(extension);
    }

    private static class HTMLImageHandler extends HTMLCompleteImageHandler
    {
        private String reportPrefix;

        public HTMLImageHandler(String prefix)
        {
            super();
            this.reportPrefix = prefix;
        }

        @Override
        protected File createUniqueFile(String imageDir, String prefix, String postfix)
        {
            File file = super.createUniqueFile(imageDir, reportPrefix + prefix, postfix);
            file.deleteOnExit();
            return file;
        }

        @Override
        protected String handleImage(IImage image, Object context, String prefix, boolean needMap)
        {
            String url = super.handleImage(image, context, prefix, false).replace("./", ""); //$NON-NLS-1$ //$NON-NLS-2$

            HTMLRenderContext ctx = (HTMLRenderContext) context;
            return ctx.getBaseImageURL() + url;
        }
    }

    /**
     * Simple eviction cache.  Retains twenty instances and then starts evicting eldest.
     *
     */
    private static class OutputRenderMap<K, V> extends LinkedHashMap<K, V>
    {
        private static final long serialVersionUID = -5407155526999157659L;

        private final Integer RETENSION_COUNT = Integer.getInteger("org.ziptie.report.cachesize", 20); //$NON-NLS-1$

        @Override
        protected boolean removeEldestEntry(java.util.Map.Entry<K, V> eldest)
        {
            boolean remove = this.size() > RETENSION_COUNT;
            if (remove)
            {
                remove(eldest.getKey());
            }
            return remove;
        }

        @Override
        public V remove(Object key)
        {
            V remove = super.remove(key);
            File file = (File) remove;
            file.delete();

            final String pathStub = file.getName().replaceFirst("\\.[a-z]+$", ""); //$NON-NLS-1$ //$NON-NLS-2$
            File parentDir = new File(file.getParent());
            File[] listFiles = parentDir.listFiles(new FileFilter() {
                public boolean accept(File pathname)
                {
                    return pathname.getName().startsWith(pathStub);
                }
            });

            for (File die : listFiles)
            {
                die.delete();
            }

            return remove;
        }
    }
}
