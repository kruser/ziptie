package org.ziptie.server.birt;

import org.eclipse.osgi.util.NLS;

public class Messages extends NLS
{
    private static final String BUNDLE_NAME = "org.ziptie.server.birt.messages"; //$NON-NLS-1$

    public static String ReportJob_badAddresses;

    public static String ReportJob_emailSubject;

    public static String ReportJob_emptyAddresses;

    public static String ReportJob_errorSending;

    public static String ReportJob_noFormat;

    public static String ReportJob_reportDefinitionNotFound;

    public static String ReportJob_reportJobFinished;

    public static String ReportJob_reportPersistFailure;

    public static String ReportJob_startingReportJob;

    public static String ReportPluginManager_errorReadingReport;
    public static String ReportPluginManager_definitionNotFound;

    public static String ReportPluginManager_discoveredReport;

    public static String ReportPluginManager_pluginTypeDisplayName;

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
