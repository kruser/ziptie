package org.ziptie.zap.web;

import java.io.File;
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.Servlet;
import javax.servlet.http.HttpSessionListener;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionDelta;
import org.eclipse.core.runtime.IRegistryChangeEvent;
import org.eclipse.core.runtime.IRegistryChangeListener;
import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.servlet.FilterHolder;
import org.mortbay.jetty.servlet.FilterMapping;
import org.mortbay.jetty.servlet.ServletHandler;
import org.mortbay.jetty.servlet.ServletHolder;
import org.mortbay.jetty.servlet.ServletMapping;
import org.mortbay.jetty.servlet.SessionHandler;
import org.mortbay.xml.XmlConfiguration;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.ziptie.zap.util.BundleFinderHelper;
import org.ziptie.zap.web.internal.ZResourceHandler;

/**
 * WebService
 */
@SuppressWarnings("nls")
public class WebService implements IWebService, IRegistryChangeListener
{
    public static final String EXTENSION_NAMESPACE = "org.ziptie.zap.web";
    public static final String EXTENSION_POINT_ID = "WebRegistry";

    private static final Logger LOGGER = Logger.getLogger(WebService.class);
    private static final String MESSAGE_FORMAT = "registering %s %s from bundle %s";
    private static final String ATTR_ALIAS = "alias";
    private static final String ATTR_CLASS = "class";
    private static final String ATTR_NAME = "name";
    private static final String ATTR_VALUE = "value";
    private static final String FILTER = "filter";
    private static final String RESOURCE = "resource";
    private static final String SERVLET = "servlet";

    private BundleFinderHelper bundleFinder;

    private Server server;

    private ServletHandler servletHandler;

    /**
     * Constructor.
     *
     * @param context the bundle context
     * @throws Exception thrown if an exception occurs
     */
    public WebService(BundleContext context) throws Exception
    {
        bundleFinder = new BundleFinderHelper(context);

        // Find the Jetty configuration file...
        String jettyXml = System.getProperty("org.ziptie.zap.web.jetty.xml", "jetty.xml");

        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        File jettyConfigDir = new File(URI.create(configArea + "jetty")); //$NON-NLS-1$
        File configFile = new File(jettyConfigDir, jettyXml);
        if (!jettyConfigDir.isDirectory() || !configFile.exists())
        {
            LOGGER.fatal(String.format("Jetty configuration: %s config file not found", configFile)); //$NON-NLS-1$
            return;
        }

        // We need to do this because the jetty-ssl engine is in our bundle (it is not provided
        // as an OSGi-bundle by Jetty, therefore the reflection based XmlConfiguration cannot
        // instantiate classes from the jetty-ssl engine library without this code.
        ClassLoader oldCL = Thread.currentThread().getContextClassLoader();
        try
        {
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());
            server = new Server();
            XmlConfiguration xc = new XmlConfiguration(configFile.toURL());
            xc.configure(server);
        }
        finally
        {
            Thread.currentThread().setContextClassLoader(oldCL);
        }

        servletHandler = (ServletHandler) server.getChildHandlerByClass(ServletHandler.class);
    }

    /**
     * Start the service.
     *
     * @throws Exception thrown if an exception occurs
     */
    public void start() throws Exception
    {
        server.start();
    }

    /**
     * Stop the service.
     * 
     * @throws Exception thrown if an exception occurs 
     */
    public void stop() throws Exception
    {
        server.stop();
    }

    /** {@inheritDoc} */
    public void registerSessionListener(HttpSessionListener listener)
    {
        SessionHandler sessionHandler = (SessionHandler) server.getChildHandlerByClass(SessionHandler.class);
        sessionHandler.addEventListener(listener);
    }

    /** {@inheritDoc} */
    public void unregisterSessionListener(HttpSessionListener listener)
    {
        throw new UnsupportedOperationException("Currently unimplemented");
    }

    /** {@inheritDoc} */
    public String getHost(String connectorName)
    {
        for (Connector connector : server.getConnectors())
        {
            if (connector.getName() != null && connector.getName().equals(connectorName))
            {
                return connector.getHost();
            }
        }

        return null;
    }

    /** {@inheritDoc} */
    public int getPort(String connectorName)
    {
        for (Connector connector : server.getConnectors())
        {
            if (connector.getName() != null && connector.getName().equals(connectorName))
            {
                return connector.getPort();
            }
        }

        return 0;
    }

    /** {@inheritDoc} */
    public String getScheme(String connectorName)
    {
        for (Connector connector : server.getConnectors())
        {
            if (connector.getName() != null && connector.getName().equals(connectorName))
            {
                return connector.getIntegralScheme();
            }
        }

        return null;
    }

    /** {@inheritDoc} */
    public void registryChanged(IRegistryChangeEvent event)
    {
        List<IConfigurationElement> added = new LinkedList<IConfigurationElement>();

        IExtensionDelta[] extensionDeltas = event.getExtensionDeltas(EXTENSION_NAMESPACE, EXTENSION_POINT_ID);
        for (IExtensionDelta delta : extensionDeltas)
        {
            switch (delta.getKind())
            {
            case IExtensionDelta.ADDED:
                // Don't add any until after all the removes have occurred.
                Collections.addAll(added, delta.getExtension().getConfigurationElements());
                break;

            case IExtensionDelta.REMOVED:
                for (IConfigurationElement config : delta.getExtension().getConfigurationElements())
                {
                    unregister(config);
                }
                break;

            default:
                break;
            }
        }

        for (IConfigurationElement config : added)
        {
            register(config);
        }
    }

    /**
     * Register an element of a given type.
     *
     * @param element the configuration element
     */
    public void register(IConfigurationElement element)
    {
        String elName = element.getName();

        try
        {
            if (elName.equals(SERVLET))
            {
                registerServlet(element);
            }
            else if (elName.equals(FILTER))
            {
                registerFilter(element);
            }
            else if (elName.equals(RESOURCE))
            {
                registerResource(element);
            }
        }
        catch (CoreException e)
        {
            LOGGER.fatal("Error registering web resource.", e);
        }
    }

    private void registerServlet(IConfigurationElement element) throws CoreException
    {
        String bundleName = element.getContributor().getName();
        String elClass = element.getAttribute(ATTR_CLASS);

        Servlet servlet = null;
        try
        {
            servlet = (Servlet) element.createExecutableExtension(ATTR_CLASS);
        }
        catch (Throwable th)
        {
            LOGGER.error("unable to create extension class " + elClass, th);
            return;
        }

        LOGGER.debug(String.format(MESSAGE_FORMAT, SERVLET, elClass, bundleName));

        Map<?, ?> initParams = getInitParams(element);
        ServletHolder holder = new ServletHolder(servlet);
        holder.setInitParameters(initParams);
        holder.setServletHandler(servletHandler);
        String name = element.getAttribute(ATTR_ALIAS);
        if (name != null)
        {
            holder.setName(name);
        }
        else
        {
            String msg = "Registering a servlet (%s) in bundle (%s) without an 'alias', cannot be unregistered.";
            LOGGER.warn(String.format(msg, servlet.getClass().getName(), bundleName));
        }

        servletHandler.addServlet(holder);

        ServletMapping mapping = new ServletMapping();
        mapping.setServletName(holder.getName());

        List<String> patterns = getPatterns(element);
        if (patterns.size() > 0)
        {
            mapping.setPathSpecs(patterns.toArray(new String[0]));

            servletHandler.addServletMapping(mapping);
        }
    }

    private void registerFilter(IConfigurationElement element) throws CoreException
    {
        String bundleName = element.getContributor().getName();
        String elClass = element.getAttribute(ATTR_CLASS);

        Filter filter = null;
        try
        {
            filter = (Filter) element.createExecutableExtension(ATTR_CLASS);
        }
        catch (Throwable th)
        {
            LOGGER.error("unable to create filter clas " + elClass, th);
            return;
        }

        LOGGER.debug(String.format(MESSAGE_FORMAT, "web filter", elClass, bundleName));

        FilterHolder holder = new FilterHolder(filter);
        String optionalFilterAlias = element.getAttribute(ATTR_ALIAS);
        if (optionalFilterAlias != null)
        {
            holder.setName(optionalFilterAlias);
        }
        else
        {
            String msg = "Registering a filter (%s) in bundle (%s) without an 'alias', cannot be unregistered.";
            LOGGER.warn(String.format(msg, filter.getClass().getName(), bundleName));
        }

        FilterMapping mapping = new FilterMapping();
        mapping.setFilterName(holder.getName());
        List<String> patterns = getPatterns(element);
        if (patterns.size() > 0)
        {
            mapping.setPathSpecs(patterns.toArray(new String[0]));
        }

        String[] servletAliases = getServletAliases(element);
        if (servletAliases.length > 0)
        {
            mapping.setServletNames(servletAliases);
        }

        servletHandler.addFilter(holder, mapping);
    }

    private void registerResource(IConfigurationElement element)
    {
        String bundleName = element.getContributor().getName();
        Bundle bundle = bundleFinder.findBySymbolicName(bundleName);

        ZResourceHandler zresHandler = (ZResourceHandler) server.getChildHandlerByClass(ZResourceHandler.class);
        List<String> patterns = getPatterns(element);
        for (String pattern : patterns)
        {
            zresHandler.addBundle(pattern, bundle);
        }

        //                container.registerResources(alias, name, getBundleHttpContext(bundle));

        LOGGER.debug("Registered resource from bundle " + bundleName);
    }

    private void unregister(IConfigurationElement element)
    {
        String elName = element.getName();

        if (elName.equals(SERVLET))
        {
            unregisterServlet(element);
        }
        else if (elName.equals(FILTER))
        {
            unregisterFilter(element);
        }
        else if (elName.equals(RESOURCE))
        {
            unregisterResource(element);
        }
    }

    private void unregisterServlet(IConfigurationElement element)
    {
        String name = element.getAttribute(ATTR_ALIAS);
        if (name == null)
        {
            LOGGER.warn("Cannot unregister servlet without an alias.");
            return;
        }

        LOGGER.debug("Unregistering servlet " + name);

        // Remove servlet mappings
        LinkedList<ServletMapping> servletMappings = new LinkedList<ServletMapping>();
        servletMappings.addAll(Arrays.asList(servletHandler.getServletMappings()));
        Iterator<ServletMapping> iterator = servletMappings.iterator();
        while (iterator.hasNext())
        {
            ServletMapping mapping = iterator.next();
            if (name.equals(mapping.getServletName()))
            {
                iterator.remove();
            }
        }

        servletHandler.setServletMappings(servletMappings.toArray(new ServletMapping[0]));

        // Remove filter mappings for this servlet
        LinkedList<FilterMapping> filterMappings = new LinkedList<FilterMapping>();
        filterMappings.addAll(Arrays.asList(servletHandler.getFilterMappings()));
        Iterator<FilterMapping> iterator2 = filterMappings.iterator();
        while (iterator.hasNext())
        {
            FilterMapping mapping = iterator2.next();
            Set<String> servletNames = new HashSet<String>();
            Collections.addAll(servletNames, mapping.getServletNames());
            if (servletNames.contains(name))
            {
                servletNames.remove(name);
                mapping.setServletNames(servletNames.toArray(new String[0]));
            }
        }

        // Remove servlet holders (i.e. the servlet itself)
        LinkedList<ServletHolder> holders = new LinkedList<ServletHolder>();
        holders.addAll(Arrays.asList(servletHandler.getServlets()));
        Iterator<ServletHolder> iterator3 = holders.iterator();
        while (iterator3.hasNext())
        {
            ServletHolder holder = iterator3.next();
            if (name.equals(holder.getName()))
            {
                iterator3.remove();
            }
        }

        servletHandler.setServlets(holders.toArray(new ServletHolder[0]));
    }

    private void unregisterFilter(IConfigurationElement element)
    {
        String name = element.getAttribute(ATTR_ALIAS);
        if (name == null)
        {
            LOGGER.warn("Cannot unregister filter without an alias.");
            return;
        }

        LOGGER.debug("Unregistering filter " + name);

        LinkedList<FilterMapping> filterMappings = new LinkedList<FilterMapping>();
        filterMappings.addAll(Arrays.asList(servletHandler.getFilterMappings()));
        Iterator<FilterMapping> iterator = filterMappings.iterator();
        while (iterator.hasNext())
        {
            FilterMapping mapping = iterator.next();
            if (name.equals(mapping.getFilterName()))
            {
                iterator.remove();
            }
        }

        servletHandler.setFilterMappings(filterMappings.toArray(new FilterMapping[0]));

        LinkedList<FilterHolder> holders = new LinkedList<FilterHolder>();
        holders.addAll(Arrays.asList(servletHandler.getFilters()));
        Iterator<FilterHolder> iterator2 = holders.iterator();
        while (iterator2.hasNext())
        {
            FilterHolder holder = iterator2.next();
            if (name.equals(holder.getName()))
            {
                iterator2.remove();
            }
        }

        servletHandler.setFilters(holders.toArray(new FilterHolder[0]));
    }

    private void unregisterResource(IConfigurationElement element)
    {
        String bundleName = element.getContributor().getName();
        Bundle bundle = bundleFinder.findBySymbolicName(bundleName);

        ZResourceHandler zresHandler = (ZResourceHandler) server.getChildHandlerByClass(ZResourceHandler.class);
        List<String> patterns = getPatterns(element);
        for (String pattern : patterns)
        {
            zresHandler.removeBundle(pattern, bundle);
        }
    }

    private List<String> getPatterns(IConfigurationElement element)
    {
        List<String> values = new ArrayList<String>();

        for (IConfigurationElement child : element.getChildren("url-pattern"))
        {
            String pattern = child.getAttribute("pattern");
            values.add(pattern);
        }

        return values;
    }

    private String[] getServletAliases(IConfigurationElement element)
    {
        List<String> values = new ArrayList<String>();

        for (IConfigurationElement child : element.getChildren("servlet-alias"))
        {
            String pattern = child.getAttribute(ATTR_NAME);
            values.add(pattern);
        }

        return values.toArray(new String[values.size()]);
    }

    private Map<String, String> getInitParams(IConfigurationElement element)
    {
        HashMap<String, String> dict = new HashMap<String, String>();

        for (IConfigurationElement child : element.getChildren("init-param"))
        {
            String name = child.getAttribute(ATTR_NAME);
            String value = child.getAttribute(ATTR_VALUE);
            dict.put(name, value);
        }

        return dict;
    }
}
