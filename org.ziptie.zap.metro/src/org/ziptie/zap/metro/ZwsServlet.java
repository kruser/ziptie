package org.ziptie.zap.metro;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.LogManager;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.namespace.QName;

import org.apache.log4j.Logger;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.BundleEvent;
import org.osgi.framework.BundleListener;
import org.ziptie.zap.jta.TransactionElf;
import org.ziptie.zap.metro.internal.MetroActivator;

import com.sun.xml.ws.api.model.wsdl.WSDLBoundOperation;
import com.sun.xml.ws.api.server.BoundEndpoint;
import com.sun.xml.ws.api.server.Container;
import com.sun.xml.ws.api.server.Module;
import com.sun.xml.ws.api.server.PortAddressResolver;
import com.sun.xml.ws.resources.WsservletMessages;
import com.sun.xml.ws.transport.http.DeploymentDescriptorParser;
import com.sun.xml.ws.transport.http.ResourceLoader;
import com.sun.xml.ws.transport.http.servlet.ServletAdapter;
import com.sun.xml.ws.transport.http.servlet.ServletAdapterList;
import com.sun.xml.ws.transport.http.servlet.WSServletDelegate;

/**
 * ZwsServlet
 */
public class ZwsServlet extends HttpServlet
{
    private static final long serialVersionUID = 7038961239515085670L;
    private static final Logger logger = Logger.getLogger(ZwsServlet.class);

    private static final String JAXWS_RI_RUNTIME_INFO = "com.sun.xml.ws.server.http.servletDelegate"; //$NON-NLS-1$
    private static final String AUTO_START_KEY = "autoStartTransaction"; //$NON-NLS-1$

    private WSServletDelegate delegate;
    private ServletContext context;
    private Lock delegateLock;

    private Map<String, List<ServletAdapter>> bundleToServletAdaptersMap;
    private boolean startTransaction = true;

    /**
     * Default constructor.
     */
    public ZwsServlet()
    {
        // Make com.sun.xml.ws SHUT UP and only load at WARNING level.
        try
        {
            startTransaction = Boolean.parseBoolean(System.getProperty(AUTO_START_KEY, "true")); //$NON-NLS-1$

            Properties props = new Properties();
            props.put("com.sun.xml.ws.level", Level.WARNING.toString()); //$NON-NLS-1$
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            props.store(baos, ""); //$NON-NLS-1$
            baos.close();
            ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray());
            LogManager.getLogManager().readConfiguration(bais);

            // Create the delegate lock
            delegateLock = new ReentrantLock();

            // Initialize our map that contains mappings of bundles to Servlet Adapters
            bundleToServletAdaptersMap = new HashMap<String, List<ServletAdapter>>();
        }
        catch (IOException io)
        {
            logger.error(io);
        }
    }

    @Override
    public void init(ServletConfig servletConfig) throws ServletException
    {
        super.init(servletConfig);

        if (logger.isDebugEnabled())
        {
            logger.debug("ZwsServlet initializing."); //$NON-NLS-1$
        }

        context = servletConfig.getServletContext();
        //        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        //        if (classLoader == null)
        //        {
        //            classLoader = getClass().getClassLoader();
        //        }

        // Iterate over all the bundles and load up any web services
        BundleContext ctxt = MetroActivator.getBundleContext();

        Bundle[] bundles = ctxt.getBundles();
        for (Bundle bundle : bundles)
        {
            registerWebServiceBundle(bundle);
        }

        // Update the contex with the properly structured servlet delegate that is aware of all the web service
        // that were loaded
        context.setAttribute(JAXWS_RI_RUNTIME_INFO, getDelegate());

        // Register a BundleListener to see if new web services are added or if existing ones are removed
        BundleListener wsBundleListener = new BundleListener() {
            public void bundleChanged(BundleEvent event)
            {
                switch (event.getType())
                {
                    case BundleEvent.UNRESOLVED:
                        unregisterWebServiceBundle(event.getBundle());
                        break;

                    case BundleEvent.RESOLVED:
                        registerWebServiceBundle(event.getBundle());
                        break;

                    default:
                        break;
                }
            }
        };

        // Register the bundle listener for web services
        MetroActivator.getBundleContext().addBundleListener(wsBundleListener);
    }

    @SuppressWarnings("nls")
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException
    {
        String query = request.getQueryString();
        if (request.getRequestURI().equals("/server") &&
                (query == null || query.contains("j_username") || query.equals("authenticate")))
        {
            printSummary(response);
            return;
        }

        boolean success = false;

        if (startTransaction)
        {
            TransactionElf.beginOrJoinTransaction();
        }

        try
        {
            getDelegate().doGet(request, response, context);

            success = true;
        }
        catch (RuntimeException e)
        {
            logger.error(e.getMessage(), e);
            throw e;
        }
        finally
        {
            if (startTransaction)
            {
                if (success)
                {
                    TransactionElf.commit();
                }
                else
                {
                    TransactionElf.rollback();
                }
            }
        }
    }

    private void printSummary(HttpServletResponse response) throws ServletException
    {
        try
        {
            response.setStatus(HttpServletResponse.SC_OK);
            response.setContentType("text/html"); //$NON-NLS-1$

            ServletOutputStream out = response.getOutputStream();
            PrintStream ps = new PrintStream(out);
            ps.append("<h5>") //$NON-NLS-1$
                .append(String.valueOf(getDelegate().adapters.size()))
                .append(" SOAP Services Active.</h5>\n<ul>\n"); //$NON-NLS-1$
            for (ServletAdapter adapter : getDelegate().adapters)
            {
                ps.append("<li><a href=\"") //$NON-NLS-1$
                    .append(adapter.urlPattern)
                    .append("?wsdl\">") //$NON-NLS-1$
                    .append(adapter.getName())
                    .append("</a>\n<ul>"); //$NON-NLS-1$
                for (WSDLBoundOperation boundOperation : adapter.getEndpoint().getPort().getBinding().getBindingOperations())
                {
                    ps.append("<li>") //$NON-NLS-1$
                        .append(boundOperation.getName().getLocalPart())
                        .append("</li>\n"); //$NON-NLS-1$
                }
                ps.append("</ul></li>\n"); //$NON-NLS-1$
            }
            ps.append("</ul>\n"); //$NON-NLS-1$
            out.close();
        }
        catch (IOException e)
        {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        boolean success = false;

        if (startTransaction)
        {
            TransactionElf.beginOrJoinTransaction();
        }

        try
        {
            // The Adobe Flash player does not allow access to the message contents of responses when the 
            // status code is not 200 so we have to force even the errors to be 200s.
            // But, we only do this for when the request is from the flash player, as we don't want to break
            // other clients, like Perl.

            String referer = request.getHeader("Referer"); //$NON-NLS-1$
            if (referer != null && referer.endsWith(".swf")) //$NON-NLS-1$
            {
                getDelegate().doPost(request, new Always200Response(response), context);
            }
            else
            {
                getDelegate().doPost(request, response, context);
            }

            success = true;
        }
        catch (RuntimeException e)
        {
            logger.error(e.getMessage(), e);
            throw e;
        }
        finally
        {
            if (startTransaction)
            {
                if (success)
                {
                    TransactionElf.commit();
                }
                else
                {
                    TransactionElf.rollback();
                }
            }
        }
    }

    /**
     * Parses the specified {@link Bundle} to see if it contains any web services definitions and if so, registers
     * all of the specified web services.
     * <p>
     * <p>
     * NOTE:  This method will be called whenever a bundle change event has occurred.
     *
     * @param bundle The {@link Bundle} to parse and potentially register.
     */
    private void registerWebServiceBundle(Bundle bundle)
    {
        try
        {
            // Ensure that the bundle represents a valid web service
            URL jaxwsUrl = bundle.getEntry("/META-INF/" + "sun-jaxws.xml"); //$NON-NLS-1$ //$NON-NLS-2$
            if (jaxwsUrl == null)
            {
                return;
            }

            ServletContainer container = new ServletContainer(context);
            List<ServletAdapter> servletAdaptersForBundle = new ArrayList<ServletAdapter>();

            DeploymentDescriptorParser<ServletAdapter> parser = new DeploymentDescriptorParser<ServletAdapter>(this.getClass().getClassLoader(),
                    new ServletResourceLoader(bundle),
                    container, new ServletAdapterList() {
                // we prefer using relative paths for embedded URLs in the WSDL - such as
                // XSD schemaLocation, and port location URLs.  since we already supply the
                // ServletAdapterList, we simply hack the address returned by the base
                // implementation.  So, instead of getting schemaLocations that look like this:
                // http://foo.bar:etc/server/service we now simply get /server/service.  Clearly
                // this only works if we are the source of WSDL and XSDs - we can't refer to
                // an external host's schemas like this.  given our build/automation support
                // around automatic export of WSDL files, we can't (apparently) override this
                // anyway, unless there is a JAX annotation that I'm unaware of.
                public PortAddressResolver createPortAddressResolver(final String baseAddress) {
                    final PortAddressResolver superPAR = super.createPortAddressResolver(baseAddress);

                    return new PortAddressResolver() {
                        public String getAddressFor(QName serviceName, String portName) {
                            String chopped = superPAR.getAddressFor(serviceName, portName);
                            try
                            {
                                URL url = new URL(chopped);
                                StringBuilder rval = new StringBuilder();
                                rval.append(url.getPath());
                                if(url.getQuery() != null)
                                {
                                    rval.append("?");
                                    rval.append(url.getQuery());
                                }
                                return rval.toString();
                            }
                            catch(Exception ex)
                            {
                                logger.warn("bad embedded URL in WSDL");
                                return chopped;
                            }
                        }
                    };
                }
            });

            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());
            try
            {
                List<ServletAdapter> parsed = parser.parse(jaxwsUrl.toExternalForm(), jaxwsUrl.openStream());
                for (ServletAdapter adapter : parsed)
                {
                    logger.info(String.format("Discovered web service '%s'", adapter.getName())); //$NON-NLS-1$
                }
                servletAdaptersForBundle.addAll(parsed);
            }
            finally
            {
                Thread.currentThread().setContextClassLoader(cl);
            }

            // Map the bundle's location to all of it's servlet adapters
            bundleToServletAdaptersMap.put(bundle.getLocation(), servletAdaptersForBundle);

            // Set the delegate to null.  This will allow the next call to getDelegate() to recaluclate the delegate and all the ServletAdapters
            // that are available
            delegate = null;

            // Update the context with the reconstructed delegate, containing all of the valid servlet adapters
            context.setAttribute(JAXWS_RI_RUNTIME_INFO, getDelegate());
        }
        catch (Throwable e)
        {
            logger.fatal(WsservletMessages.LISTENER_PARSING_FAILED(e), e);
            context.removeAttribute(JAXWS_RI_RUNTIME_INFO);
            throw new RuntimeException(e);
        }
    }

    /**
     * Parses the specified {@link Bundle} to see if it contains any web services definitions and if so, unregisters
     * all of the specified web services associated with it.
     * <p>
     * <p>
     * NOTE:  This method will be called whenever a bundle change event has occurred.
     *
     * @param bundle The {@link Bundle} to parse and potentially unregister.
     */
    private void unregisterWebServiceBundle(Bundle bundle)
    {
        // Check to see if the specified bundle has already been installed/resolved as a web service and that
        // servlet adapters already exist for it
        List<ServletAdapter> servletAdaptersForBundle = bundleToServletAdaptersMap.get(bundle.getLocation());
        if (servletAdaptersForBundle == null)
        {
            return;
        }

        delegateLock.lock();
        try
        {
            // Remove the mapping of the bundle's location to its servlet adapters
            bundleToServletAdaptersMap.remove(bundle.getLocation());

            // Set the delegate to null.  This will allow the next call to getDelegate() to re-caluclate the delegate and all the ServletAdapters
            // that are available
            delegate = null;

            // Update the context with the reconstructed delegate, containing all of the valid servlet adapters
            context.setAttribute(JAXWS_RI_RUNTIME_INFO, getDelegate());
        }
        finally
        {
            delegateLock.unlock();
        }
    }

    /**
     * Wrapper for providing access to the primary {@link WSServletDelegate} object.  It ensures that if the delegate has not been created
     * or is <code>null</code> for any reason, then it will be properly created.
     *
     * @return The primary {@link WSServletDelegate} object.
     */
    private WSServletDelegate getDelegate()
    {
        // Lock the delegate lock
        delegateLock.lock();

        try
        {
            WSServletDelegate theDelegate = delegate;

            if (theDelegate == null)
            {
                // Construct a list to store every servlet adapter
                List<ServletAdapter> everyServletAdapter = new ArrayList<ServletAdapter>();

                for (List<ServletAdapter> servletAdaptersForBundle : bundleToServletAdaptersMap.values())
                {
                    everyServletAdapter.addAll(servletAdaptersForBundle);
                }

                // Re-create the delegate with all the proper servlet adapters
                delegate = new WSServletDelegate(everyServletAdapter, context);

                return delegate;
            }

            return theDelegate;
        }
        finally
        {
            // Unlock the delegate lock
            delegateLock.unlock();
        }
    }

    /**
     * ServletContainer
     */
    private static class ServletContainer extends Container
    {
        private final ServletContext servletContext;

        ServletContainer(ServletContext servletContext)
        {
            super();
            this.servletContext = servletContext;
        }

        @SuppressWarnings("unchecked")
        public <T> T getSPI(Class<T> spiType)
        {
            if (spiType == ServletContext.class)
            {
                return (T) servletContext;
            }
            else if (spiType == Module.class)
            {
                return (T) new BogusModule();
            }

            return null;
        }
    }

    /**
     * ServletResourceLoader
     */
    private class ServletResourceLoader implements ResourceLoader
    {
        private final Bundle bundle;

        public ServletResourceLoader(Bundle bundle)
        {
            super();
            this.bundle = bundle;
        }

        public URL getResource(String path) throws MalformedURLException
        {
            // return context.getResource(path);
            // return bundle.getResource(path);
            return bundle.getEntry(path);
        }

        public URL getCatalogFile() throws MalformedURLException
        {
            return MetroActivator.getBundleContext().getBundle().getResource("/WEB-INF/jax-ws-catalog.xml"); //$NON-NLS-1$
        }

        public Set<String> getResourcePaths(String path)
        {
            // return context.getResourcePaths(path);
            try
            {
                Enumeration<?> entryPaths = bundle.getEntryPaths(path);
                if (entryPaths == null)
                {
                    throw new IllegalStateException(String.format("Bundle '%s' missing resource '%s'", bundle.getSymbolicName(), path)); //$NON-NLS-1$
                }

                Set<String> set = new HashSet<String>();
                while (entryPaths.hasMoreElements())
                {
                    String s = (String) entryPaths.nextElement();
                    // File file = new File(url.toURI());
                    set.add(s);
                }

                return set;
            }
            catch (Exception e)
            {
                throw new RuntimeException(e);
            }
        }
    }

    private static class BogusModule extends Module
    {
        private List<BoundEndpoint> endPoints;

        public BogusModule()
        {
            endPoints = new ArrayList<BoundEndpoint>();
        }

        @Override
        public List<BoundEndpoint> getBoundEndpoints()
        {
            return endPoints;
        }

    }
}
