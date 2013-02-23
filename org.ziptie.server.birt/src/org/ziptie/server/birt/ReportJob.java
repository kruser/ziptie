package org.ziptie.server.birt;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailAttachment;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.HtmlEmail;
import org.apache.commons.mail.MultiPartEmail;
import org.apache.log4j.Logger;
import org.eclipse.birt.report.engine.api.EngineException;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportRunnable;
import org.eclipse.birt.report.engine.api.IRunTask;
import org.hibernate.classic.Session;
import org.quartz.InterruptableJob;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.UnableToInterruptJobException;
import org.ziptie.provider.devices.DeviceResolutionElf;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.provider.scheduler.ExecutionData;
import org.ziptie.provider.tools.PluginExecRecord;
import org.ziptie.server.birt.internal.BirtActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * ReportJob
 * 
 * The ReportJob supports the following parameters in the JobData:
 *
 *   ipResolutionScheme
 *   ipResolutionData
 *
 * Note that an individual report may choose to ignore these parameters entirely.
 *
 * (Optional) Used for emailing of report after generation:
 * 
 *   report.email.format     - if sending mail this is required
 *   report.email.to         - if sending mail this is required.  semi-colon separated list of email addresses.
 *   report.email.cc         - optional.  semi-colon separated list of email addresses.
 *   report.email.link       - either this must be true, the next attribute must be true, or both can be true
 *   report.email.attachment - either this must be true, the previous attribute must be true, or both can be true
 */
public class ReportJob implements InterruptableJob
{
    private static final Logger LOGGER = Logger.getLogger(ReportJob.class);

    private static final String REPORT_EMAIL_FORMAT = "report.email.format"; //$NON-NLS-1$
    private static final String REPORT_EMAIL_TO = "report.email.to"; //$NON-NLS-1$
    private static final String REPORT_EMAIL_CC = "report.email.cc"; //$NON-NLS-1$
    private static final String REPORT_EMAIL_LINK = "report.email.link"; //$NON-NLS-1$
    private static final String REPORT_EMAIL_ATTACHMENT = "report.email.attachment"; //$NON-NLS-1$
    private static final String REPORT_TITLE = "tool"; //$NON-NLS-1$
    private static final String MAIL_HOST_PROP = "mail.host"; //$NON-NLS-1$
    private static final String MAIL_FROM_PROP = "mail.from"; //$NON-NLS-1$
    private static final String MAIL_FROM_NAME_PROP = "mail.from.name"; //$NON-NLS-1$
    private static final String MAIL_AUTH_USER_PROP = "mail.auth.user"; //$NON-NLS-1$
    private static final String MAIL_AUTH_PASSWORD_PROP = "mail.auth.password"; //$NON-NLS-1$

    private JobDataMap mergedJobDataMap;
    private volatile IRunTask runTask;
    private ExecutionData executionData;
    private String reportTitle;

    /** {@inheritDoc} */
    public void execute(JobExecutionContext executionContext) throws JobExecutionException
    {
        mergedJobDataMap = executionContext.getMergedJobDataMap();
        reportTitle = mergedJobDataMap.getString(REPORT_TITLE);
        executionData = (ExecutionData) executionContext.get(ExecutionData.class);

        JobDetail jobDetail = executionContext.getJobDetail();
        LOGGER.info(Messages.bind(Messages.ReportJob_startingReportJob, reportTitle, jobDetail.getGroup() + '.' + jobDetail.getName()));

        ReportPluginManager reportPluginManager = BirtActivator.getReportPluginManager();
        IReportRunnable reportDesign = reportPluginManager.getReportByTitle(reportTitle);
        if (reportDesign == null)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_reportDefinitionNotFound, reportTitle));
            return;
        }

        List<ZDeviceLite> devices = null;
        File tmpFile = null;
        try
        {
            String ipData = mergedJobDataMap.getString("ipResolutionData"); //$NON-NLS-1$
            String ipScheme = mergedJobDataMap.getString("ipResolutionScheme"); //$NON-NLS-1$
            if (ipData != null && ipScheme != null)
            {
                devices = DeviceResolutionElf.resolveDevices(ipScheme, ipData);
                persistTempDevices(devices);
            }

            TransactionElf.beginOrJoinTransaction();
            tmpFile = runReport(reportDesign, devices);
            TransactionElf.commit();

            TransactionElf.beginOrJoinTransaction();
            createExecRecord();
            persistReport(tmpFile, executionData.getId());
            TransactionElf.commit();

            emailReport(tmpFile, executionContext);
        }
        catch (Exception e)
        {
            TransactionElf.rollback();
            throw new JobExecutionException(e);
        }
        finally
        {
            if (tmpFile != null)
            {
                tmpFile.delete();
            }

            if (devices != null)
            {
                deleteTempDevices();
            }

            LOGGER.info(Messages.bind(Messages.ReportJob_reportJobFinished, jobDetail.getGroup() + '.' + jobDetail.getName()));
        }
    }

    /** {@inheritDoc} */
    public void interrupt() throws UnableToInterruptJobException
    {
        if (runTask != null)
        {
            runTask.cancel();
        }
    }

    /**
     * Run the specified report design.
     *
     * @param reportDesign the report design to run
     * @param devices a set of devices or <code>null</code>
     * @return the intermediate BIRT output file
     * @throws IOException thrown if there is an error writing the report to the file system
     * @throws EngineException thrown if there is an internal error in BIRT running the report
     */
    private File runReport(IReportRunnable reportDesign, List<ZDeviceLite> devices) throws IOException, EngineException
    {
        IReportEngine reportEngine = BirtActivator.getReportPluginManager().getReportEngine(reportTitle);

        try
        {
            runTask = reportEngine.createRunTask(reportDesign);

            // Set the execution id as a parameter to the report
            runTask.setParameterValue("execution_id", new Integer(executionData.getId())); //$NON-NLS-1$

            // Set the device list as a parameter to the report
            if (devices != null)
            {
                runTask.setParameterValue("zdevicelites", devices); //$NON-NLS-1$
            }

            // Set the locale of the report
            String locale = mergedJobDataMap.getString("locale"); //$NON-NLS-1$
            if (locale != null)
            {
                runTask.setLocale(new Locale(locale));
            }

            // Get interactive inputs and set them as parameter values in the run task
            for (String key : mergedJobDataMap.getKeys())
            {
                if (key.startsWith("input.")) //$NON-NLS-1$
                {
                    runTask.setParameterValue(key, mergedJobDataMap.getString(key));
                }
            }

            File tmpFile = File.createTempFile("birt", ".rptdocument"); //$NON-NLS-1$ //$NON-NLS-2$
            tmpFile.deleteOnExit(); // best effort delete, only works in clean jvm shutdown

            runTask.setErrorHandlingOption(IRunTask.CANCEL_ON_ERROR);
            runTask.run(tmpFile.getAbsolutePath());
            runTask.close();
            runTask = null;

            return tmpFile;
        }
        finally
        {
            reportEngine.destroy();
        }
    }

    /**
     * Create a record of the execution.
     *
     * @param toolProperties 
     */
    private void createExecRecord()
    {
        PluginExecRecord execRecord = new PluginExecRecord();
        execRecord.setPluginName(reportTitle);
        execRecord.setOutputFormat("birt(html|pdf)"); //$NON-NLS-1$
        execRecord.setExecutionData(executionData);

        Session session = BirtActivator.getSessionFactory().getCurrentSession();
        session.save(execRecord);
    }

    /**
     * Stream the binary intermediate output format file into a BLOB in the database.
     *
     * @param tmpFile intermediate output format file
     * @throws SQLException thrown if there is an error accessing the database
     * @throws IOException thrown if there is an error reading the file
     */
    private void persistReport(File tmpFile, int executionId) throws SQLException, IOException
    {
        Connection connection = BirtActivator.getDataSource().getConnection();

        try
        {
            PreparedStatement stmt = connection.prepareStatement("INSERT INTO birt_report (execution_id, details) VALUES (?,?)"); //$NON-NLS-1$

            BufferedInputStream is = new BufferedInputStream(new FileInputStream(tmpFile));
            stmt.setInt(1, executionId);
            stmt.setBinaryStream(2, is, (int) tmpFile.length());
            int rowsUpdated = stmt.executeUpdate();
            if (rowsUpdated == 0)
            {
                LOGGER.warn(Messages.ReportJob_reportPersistFailure);
            }

            stmt.close();
            is.close();
        }
        finally
        {
            connection.close();
        }
    }

    private void persistTempDevices(List<ZDeviceLite> devices) throws SQLException
    {
        if (devices == null || devices.size() == 0)
        {
            return;
        }

        TransactionElf.beginOrJoinTransaction();

        Connection connection = BirtActivator.getDataSource().getConnection();

        PreparedStatement stmt = null;
        try
        {
            stmt = connection.prepareStatement("INSERT INTO birt_resolved_devices(device_id, execution_id) VALUES (?, ?)"); //$NON-NLS-1$
            for (ZDeviceLite device : devices)
            {
                stmt.setInt(1, device.getDeviceId());
                stmt.setInt(2, executionData.getId());
                stmt.addBatch();
            }

            int[] batchRc = stmt.executeBatch();
            if (batchRc == null || batchRc[0] <= 0)
            {
                LOGGER.warn("Batch insert failed for temporary device table."); //$NON-NLS-1$
            }
        }
        finally
        {
            if (stmt != null)
            {
                stmt.close();
            }

            connection.close();

            TransactionElf.commit();
        }
    }

    /**
     * @throws JobExecutionException
     */
    private void deleteTempDevices() throws JobExecutionException
    {
        TransactionElf.beginOrJoinTransaction();

        Connection connection = null;
        try
        {
            connection = BirtActivator.getDataSource().getConnection();
            PreparedStatement stmt = connection.prepareStatement("DELETE FROM birt_resolved_devices WHERE execution_id = ?"); //$NON-NLS-1$
            stmt.setInt(1, executionData.getId());
            stmt.execute();
            stmt.close();
        }
        catch (SQLException e)
        {
            TransactionElf.rollback();
            throw new JobExecutionException("Exception deleting entries in temporary device table.", e); //$NON-NLS-1$
        }
        finally
        {
            TransactionElf.commit();
            try
            {
                connection.close();
            }
            catch (SQLException e)
            {
                // nothing
            }
        }
    }

    /**
     * Email the report if the JobData defines the required parameters,
     * otherwise this method just returns without doing anything.
     *
     * @param intermediate the BIRT intermediate format file
     * @param executionContext the Quartz JobExecutionContext of this job
     */
    @SuppressWarnings("nls")
    private void emailReport(File intermediate, JobExecutionContext executionContext)
    {
        JobDataMap jobData = executionContext.getMergedJobDataMap();
        boolean emailAttachment = jobData.containsKey(REPORT_EMAIL_ATTACHMENT) ? jobData.getBooleanValue(REPORT_EMAIL_ATTACHMENT) : false;
        boolean emailLink = jobData.containsKey(REPORT_EMAIL_LINK) ? jobData.getBooleanValue(REPORT_EMAIL_LINK) : false;
        String emailTo = jobData.getString(REPORT_EMAIL_TO);
        String emailCc = jobData.getString(REPORT_EMAIL_CC);
        String reportFormat = jobData.getString(REPORT_EMAIL_FORMAT);

        if (!validateEmailProperties(emailAttachment, emailLink, emailTo, reportFormat))
        {
            return;
        }

        try
        {
            Email email = null;
            if (reportFormat.equals("pdf"))
            {
                email = new MultiPartEmail();
            }
            else if (reportFormat.equals("html"))
            {
                email = new HtmlEmail();
            }

            setupEmail(executionContext, emailTo, emailCc, email);

            // Create the attachment
            if (emailAttachment)
            {
                final File render = RenderElf.render(intermediate, executionData.getId(), reportFormat);

                if (reportFormat.equals("pdf"))
                {
                    EmailAttachment attachment = new EmailAttachment();
                    attachment.setPath(render.getAbsolutePath());
                    attachment.setDisposition(EmailAttachment.ATTACHMENT);
                    attachment.setDescription(reportTitle);
                    attachment.setName(String.format("%s.%s", reportTitle, reportFormat)); //$NON-NLS-1$
                    ((MultiPartEmail) email).attach(attachment);
                }
                else if (reportFormat.equals("html"))
                {
                    HtmlEmail htmlEmail = (HtmlEmail) email;
                    String html = stringFromFile(render);

                    final String pathStub = render.getName().replaceFirst("\\.[a-z]+$", ""); //$NON-NLS-1$ //$NON-NLS-2$
                    File parentDir = new File(render.getParent());
                    File[] listFiles = parentDir.listFiles(new FileFilter()
                    {
                        public boolean accept(File pathname)
                        {
                            return pathname.getName().startsWith(pathStub) && !pathname.getName().endsWith("html"); //$NON-NLS-1$
                        }
                    });

                    for (File image : listFiles)
                    {
                        String cid = htmlEmail.embed(image);
                        String regex = "src=.+" + image.getName();
                        html = html.replaceAll(regex, "src=\"cid:" + cid);
                    }

                    htmlEmail.setHtmlMsg(html);
                }
            }

            if (emailLink)
            {
            }

            email.send();
        }
        catch (AddressException ae)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_badAddresses, reportTitle), ae);
        }
        catch (EmailException ee)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_errorSending, reportTitle), ee);
        }
        catch (EngineException ee)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_errorSending, reportTitle), ee);
        }
        catch (IOException ie)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_errorSending, reportTitle), ie);
        }
    }

    private String stringFromFile(File render) throws IOException
    {
        BufferedReader reader = null;
        try
        {
            reader = new BufferedReader(new FileReader(render));
            StringBuilder sb = new StringBuilder();
            char[] cbuf = new char[4096];
            while (true)
            {
                int read = reader.read(cbuf);
                if (read <= 0)
                {
                    break;
                }
                sb.append(cbuf, 0, read);
            }

            return sb.toString();
        }
        finally
        {
            if (reader != null)
            {
                reader.close();
            }
        }
    }

    private void setupEmail(JobExecutionContext executionContext, String emailTo, String emailCc, Email email) throws AddressException, EmailException
    {
        InternetAddress[] toAddrs = InternetAddress.parse(emailTo);
        email.setTo(Arrays.asList(toAddrs));

        if (emailCc != null && emailCc.trim().length() > 0)
        {
            InternetAddress[] ccAddrs = InternetAddress.parse(emailCc);
            email.setCc(Arrays.asList(ccAddrs));
        }

        email.setCharset("utf-8"); //$NON-NLS-1$
        email.setHostName(System.getProperty(MAIL_HOST_PROP, "mail")); //$NON-NLS-1$
        String authUser = System.getProperty(MAIL_AUTH_USER_PROP);
        if (authUser != null)
        {
            email.setAuthentication(authUser, System.getProperty(MAIL_AUTH_PASSWORD_PROP));
        }
        email.setFrom(System.getProperty(MAIL_FROM_PROP), System.getProperty(MAIL_FROM_NAME_PROP));
        email.setSubject(Messages.bind(Messages.ReportJob_emailSubject, executionContext.getJobDetail().getFullName()));
        email.addHeader("X-Mailer", "ZipTie Mailer"); //$NON-NLS-1$ //$NON-NLS-2$
        email.setDebug(Boolean.getBoolean("org.ziptie.mail.debug")); //$NON-NLS-1$
    }

    /**
     * Validate the email properties specified in the job data.
     *
     * @param emailAttachment
     * @param emailLink
     * @param emailTo
     * @param reportFormat
     * @return true if the parameters are valid for generating an email, false otherwise
     */
    private boolean validateEmailProperties(Boolean emailAttachment, boolean emailLink, String emailTo, String reportFormat)
    {
        if (!emailAttachment && !emailLink)
        {
            return false;
        }

        if (emailTo == null)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_emptyAddresses, reportTitle));
            return false;
        }

        if (reportFormat == null)
        {
            LOGGER.error(Messages.bind(Messages.ReportJob_noFormat, reportTitle));
            return false;
        }

        return true;
    }
}
