package org.ziptie.zap.jta.internal;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.sql.DataSource;
import javax.transaction.TransactionManager;
import javax.transaction.UserTransaction;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bitronix.tm.BitronixTransactionManager;
import bitronix.tm.Configuration;
import bitronix.tm.TransactionManagerServices;

/**
 * JtaActivator
 */
public class JtaActivator implements BundleActivator
{
    private static final Logger LOGGER = LoggerFactory.getLogger(JtaActivator.class);
    private ServiceRegistration tmRegistration;
    private ServiceRegistration utRegistration;
    private Map<String, ServiceRegistration> dsRegistrations;

    /**
     * init field.s
     */
    public JtaActivator()
    {
        dsRegistrations = new HashMap<String, ServiceRegistration>();
    }

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

        // Default
        String btmProperties = "bitronix-jta/btm-config.properties"; //$NON-NLS-1$

        String database = System.getProperty("database"); //$NON-NLS-1$
        if (database != null)
        {
            btmProperties = String.format("bitronix-jta/btm-config.%s.properties", database); //$NON-NLS-1$
        }

        configArea += (configArea != null ? btmProperties : "osgi-config/" + btmProperties); //$NON-NLS-1$
        URI btmConfig = URI.create(configArea);
        File file = new File(btmConfig);
        System.setProperty("bitronix.tm.configuration", file.getAbsolutePath()); //$NON-NLS-1$

        TransactionManager tm = TransactionManagerServices.getTransactionManager();
        tmRegistration = context.registerService(TransactionManager.class.getName(), tm, null);
        utRegistration = context.registerService(UserTransaction.class.getName(), tm, null);

        Map<String, Integer> uniqueNameLineNumbers = rankingOfUniqueNameProperties(file);
        Map<String, Object> resources = TransactionManagerServices.getResourceLoader().getResources();

        for (Map.Entry<String, Object> me : resources.entrySet())
        {
            Integer ranking = uniqueNameLineNumbers.get(me.getKey());
            if (ranking == null)
            {
                ranking = 1;
            }

            Dictionary<String, Object> props = new Hashtable<String, Object>();
            props.put("service.pid", me.getKey()); //$NON-NLS-1$
            props.put("service.ranking", ranking); //$NON-NLS-1$
            ServiceRegistration sr = context.registerService(DataSource.class.getName(), me.getValue(), props);
            dsRegistrations.put(me.getKey(), sr);
        }

        Configuration conf = TransactionManagerServices.getConfiguration();
        LOGGER.info(String.format("Started JTA for server ID '%s'.", conf.getServerId()));
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        BitronixTransactionManager tm = (BitronixTransactionManager) getTransactionManager();
        tm.shutdown();

        tmRegistration.unregister();
        utRegistration.unregister();

        for (ServiceRegistration reg : dsRegistrations.values())
        {
            reg.unregister();
        }
        dsRegistrations.clear();
       
        Configuration conf = TransactionManagerServices.getConfiguration();
        LOGGER.info(String.format("Stopped JTA for server ID '%s'.", conf.getServerId()));
    }

    /**
     * @return
     */
    public static UserTransaction getUserTransaction()
    {
        return TransactionManagerServices.getTransactionManager();
    }

    /**
     * @return
     */
    public static TransactionManager getTransactionManager()
    {
        return TransactionManagerServices.getTransactionManager();
    }

    private Map<String, Integer> rankingOfUniqueNameProperties(File file) throws FileNotFoundException, IOException
    {
        Pattern uniqueName = Pattern.compile("^\\s*resource\\.[^\\.]*\\.uniqueName\\s*=\\s*([^\\s]+)\\s*$");

        Map<String, Integer> lineNumbers = new HashMap<String, Integer>();
        BufferedReader reader = new BufferedReader(new FileReader(file));
        int ranking = 1;
        for (String line = reader.readLine(); line != null; line = reader.readLine())
        {
            Matcher matcher = uniqueName.matcher(line);
            if(matcher.matches())
            {
                lineNumbers.put(matcher.group(1), ranking);
                ranking++;
            }
        }

        return lineNumbers;
    }
}
