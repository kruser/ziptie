package org.ziptie.server.birt;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.ziptie.provider.tools.IPluginDetailStreamer;
import org.ziptie.provider.tools.IPluginProvider;
import org.ziptie.provider.tools.PluginExecRecord;
import org.ziptie.server.birt.internal.BirtActivator;
import org.ziptie.zap.jta.TransactionElf;
import org.ziptie.zap.util.ServiceLookupElf;

/**
 * RenderServlet
 */
public class ReportDetailStreamer implements IPluginDetailStreamer
{
    private static final long serialVersionUID = -3558885497019614434L;
    private static final Logger LOGGER = Logger.getLogger(ReportDetailStreamer.class);

    private static final String CONTENT_TYPE = "Content-Type"; //$NON-NLS-1$
    private static final String CONTENT_LENGTH = "Content-Length"; //$NON-NLS-1$
    private static final String HTTP_EXECUTION_ID = "executionId"; //$NON-NLS-1$
    private static final String FORMAT = "format"; //$NON-NLS-1$
    private static final String IMAGE = "image"; //$NON-NLS-1$
    private static final int BUFFER_SIZE = 16384;

    /**
     * Default constructor.
     */
    public ReportDetailStreamer()
    {
    }

    /** {@inheritDoc} */
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        String format = req.getParameter(FORMAT);
        int execId = Integer.valueOf(req.getParameter(HTTP_EXECUTION_ID));

        if (format == null && req.getParameter(IMAGE) != null)
        {
            streamImage(req, resp);
            return;
        }

        String mimetype = RenderElf.getMimeType(format);
        if (mimetype == null)
        {
            resp.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, "Unsupported media type."); //$NON-NLS-1$
            return;
        }

        resp.setHeader(CONTENT_TYPE, mimetype);

        TransactionElf.beginOrJoinTransaction();
        try
        {
            PluginExecRecord record = ServiceLookupElf.getService(IPluginProvider.class).getExecutionRecord(execId);

            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMDDHHmm"); //$NON-NLS-1$
            String name = record.getPluginName() + " - " + formatter.format(record.getExecutionData().getStartTime()) + ".pdf"; //$NON-NLS-1$ //$NON-NLS-2$
            resp.setHeader("Content-Disposition", "inline; filename=\"" + name + "\"");  //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$

            File outFile = RenderElf.getCachedReport(execId, format);
            if (outFile == null)
            {
                File rptDocFile = extractIntermediateFormat(execId);                

                try
                {
                    if (rptDocFile != null)
                    {
                        outFile = RenderElf.render(rptDocFile, execId, format);
                    }
                    else
                    {
                        LOGGER.error(String.format("Unable to render output for report execId: %s", execId)); //$NON-NLS-1$
                        resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to render report."); //$NON-NLS-1$
                        return;
                    }
                }
                finally
                {
                    if (rptDocFile != null && !Boolean.getBoolean("org.ziptie.birt.retain.intermediate")) //$NON-NLS-1$
                    {
                        rptDocFile.delete();
                    }
                }
            }

            streamFileToClient(outFile, resp);
        }
        catch (Exception e)
        {
            LOGGER.error(String.format("Unable to render output for report execId: %s", execId), e); //$NON-NLS-1$
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getLocalizedMessage());
        }
        finally
        {
            TransactionElf.commit();
        }
    }

    @SuppressWarnings("nls")
    private void streamImage(HttpServletRequest req, HttpServletResponse resp) throws IOException
    {
        String imageFile = req.getParameter(IMAGE);
        try
        {
            if (imageFile.startsWith(".") || imageFile.startsWith("..") || imageFile.contains(":"))
            {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Directory out of security sandbox.");
                return;
            }
    
            resp.setHeader(CONTENT_TYPE, "png");
    
            File file = new File(System.getProperty("java.io.tmpdir", "tmp"), imageFile);
            streamFileToClient(file, resp);
        }
        catch (IOException io)
        {
            LOGGER.error(String.format("Unable to to serve report image %s", imageFile), io); //$NON-NLS-1$
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, io.getLocalizedMessage());
        }
    }

    /**
     * This method will extract the intermediate BIRT format from a BLOB in the database and
     * write it to a temporary file.  The BIRT render engine really prefers to work with
     * files.
     *
     * @param execId the GUID of the report to render
     * @return a File that points to the temporary intermediate BIRT file, or null if an error
     *    occurred.
     * @throws SQLException thrown if there was an error from the database
     * @throws IOException thrown if there was an error processing a stream
     */
    private File extractIntermediateFormat(int execId) throws SQLException, IOException
    {
        File tmpFile = null;

        TransactionElf.beginOrJoinTransaction();

        Connection connection = BirtActivator.getDataSource().getConnection();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = connection.prepareStatement("SELECT details FROM birt_report WHERE execution_id = ?", //$NON-NLS-1$
                                               ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            stmt.setInt(1, execId);
            rs = stmt.executeQuery();
            if (!rs.first())
            {
                return null;
            }

            tmpFile = File.createTempFile("birt", ".tmp"); //$NON-NLS-1$ //$NON-NLS-2$
            tmpFile.deleteOnExit();

            InputStream binaryStream = rs.getBinaryStream(1);
            BufferedOutputStream fout = new BufferedOutputStream(new FileOutputStream(tmpFile), BUFFER_SIZE);
            byte[] buf = new byte[BUFFER_SIZE];
            while (true)
            {
                int read = binaryStream.read(buf);
                if (read <= 0)
                {
                    break;
                }

                fout.write(buf, 0, read);
            }
            fout.close();
            binaryStream.close();
        }
        catch (IOException io)
        {
            if (tmpFile != null)
            {
                tmpFile.delete();
                tmpFile = null;
            }
            throw io;
        }
        finally
        {
            if (rs != null)
            {
                rs.close();
            }
            if (stmt != null)
            {
                stmt.close();
            }

            TransactionElf.commit();
            connection.close();
        }
        return tmpFile;
    }

    /**
     * Stream the generated output file to the client.
     *
     * @param outFile the file containing the rendered report.
     * @param resp the servlet response to stream to
     * @throws IOException thrown if there was an error reading the file or streaming the
     *    output
     */
    private void streamFileToClient(File outFile, HttpServletResponse resp) throws IOException
    {
        resp.setHeader(CONTENT_LENGTH, String.valueOf(outFile.length()));

        ServletOutputStream outputStream = resp.getOutputStream();
        BufferedInputStream fileStream = new BufferedInputStream(new FileInputStream(outFile));

        try
        {
            byte[] buf = new byte[BUFFER_SIZE];
            while (true)
            {
                int read = fileStream.read(buf);
                if (read <= 0)
                {
                    break;
                }

                outputStream.write(buf, 0, read);
            }
        }
        finally
        {
            fileStream.close();
            outputStream.flush();
        }
    }
}
