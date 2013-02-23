/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): Leo Bayer (lbayer@ziptie.org), Dylan White (dylamite@ziptie.org)
 */
package org.ziptie.adapters.ws.internal;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Dictionary;
import java.util.HashSet;
import java.util.Set;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.BundleEvent;
import org.osgi.framework.BundleListener;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.adapters.ws.INilSettingsProvider;
import org.ziptie.adapters.ws.NilSettingsProvider;
import org.ziptie.net.adapters.AdapterService;
import org.ziptie.net.adapters.AdapterServiceException;
import org.ziptie.net.adapters.IAdapterService;

/**
 * Lifecycle class for the Adapter Webservice bundle
 */
@SuppressWarnings("nls")
public class AdaptersWsActivator implements BundleActivator, BundleListener
{
    public static final String WSDL_URL_PROP_KEY = "adapter.wsdl.location";
    public static final String ADAPTER_ID_PROP_KEY = "adapterId";

    private static final Logger LOGGER = Logger.getLogger(AdaptersWsActivator.class);
    private static AdaptersWsActivator instance;
    private static NilSettingsProvider nilSettings;

    private BundleContext context;
    private ServiceRegistration registration;
    private IAdapterService service;
    private ServiceRegistration asRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext ctxt) throws Exception
    {
        // Log that the Adapters Web Service provider is attempting to start
        LOGGER.info(Messages.providerStarting);

        context = ctxt;

        if (instance != null)
        {
            throw new IllegalStateException("Activator is a singlton!");
        }
        instance = this;

        nilSettings = new NilSettingsProvider();
        registration = ctxt.registerService(INilSettingsProvider.class.getName(), nilSettings, null);

        setupServices(ctxt);

        asRegistration = ctxt.registerService(IAdapterService.class.getName(), service, null);

        // Log that the Adapters Web Service provider has started
        LOGGER.info(Messages.providerStarted);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctxt) throws Exception
    {
        ctxt.removeBundleListener(this);

        registration.unregister();
        nilSettings = null;

        asRegistration.unregister();
        service = null;

        instance = null;

        // Log that the the Adapters Web Service provider has stopped
        LOGGER.info(Messages.providerStopped);
    }

    private Set<URL> getSchemaIncludes(Bundle bundle)
    {
        Set<URL> includes = new HashSet<URL>();
        Object object = bundle.getHeaders().get("Schema-Include");
        if (object != null)
        {
            for (String include : object.toString().split(","))
            {
                include = include.trim();
                URL entry = bundle.getEntry(include);
                if (entry == null)
                {
                    Logger.getLogger(getClass()).warn(String.format("Could not find schema location %s %s", bundle.getSymbolicName(), include));
                }
                else
                {
                    includes.add(entry);
                }
            }
        }

        return includes;
    }

    private void registerAdapters(Bundle bundle)
    {
        for (URL url : getSchemaIncludes(bundle))
        {
            service.addSchemaLocation(url);
        }

        if (!isAdapterBundle(bundle))
        {
            return;
        }

        Set<String> ids = service.registerAdapters(getBundleLocation(bundle));
        for (String adapter : ids)
        {
            Logger.getLogger(getClass()).info(String.format("Discovered adapter %s.", adapter));
        }
    }

    private void unregisterAdapters(Bundle bundle)
    {
        for (URL url : getSchemaIncludes(bundle))
        {
            service.removeSchemaLocation(url);
        }

        if (!isAdapterBundle(bundle))
        {
            return;
        }

        Set<String> ids = service.unregisterAdapters(getBundleLocation(bundle));
        for (String adapter : ids)
        {
            Logger.getLogger(getClass()).info(String.format("Removed adapter %s.", adapter));
        }
    }

    private void setupServices(BundleContext ctxt) throws AdapterServiceException
    {
        service = new AdapterService();

        for (Bundle bundle : ctxt.getBundles())
        {
            registerAdapters(bundle);
        }

        ctxt.addBundleListener(this);
    }

    /** {@inheritDoc} */
    public void bundleChanged(BundleEvent event)
    {
        switch (event.getType())
        {
        case BundleEvent.STOPPED:
            unregisterAdapters(event.getBundle());
            break;

        case BundleEvent.RESOLVED:
            registerAdapters(event.getBundle());
            break;

        default:
            break;
        }
    }

    /**
     * Uses the bundles manifest to determine if it is an adapter 
     * bundle that the {@link AdapterService} needs to know about.
     * 
     * @param bundle the bundle to analyze
     * @return true if the bundle contains adapters
     */
    private boolean isAdapterBundle(Bundle bundle)
    {
        Dictionary<?, ?> headers = bundle.getHeaders();
        Object object = headers.get(AdapterService.BUNDLE_TYPE);
        return (object != null && object.equals(AdapterService.ADAPTER_BUNDLE_TYPE));
    }

    /**
     * Gets the installed filesystem location of the given bundle.
     * @param bundle The OSGi bundle
     * @return The location of the installed plugin or <code>null</code> if it can't be expressed as a {@link File}.
     */
    private static File getBundleLocation(Bundle bundle)
    {
        try
        {
            URL result = FileLocator.find(bundle, new Path(""), null); //$NON-NLS-1$
            result = FileLocator.toFileURL(result);
            return new File(result.getFile());
        }
        catch (IOException e)
        {
            Logger.getLogger(AdaptersWsActivator.class).error("Unable to resolve bundle location!", e);
            return null;
        }
    }

    /**
     * Get's the adapters.ws bundle context.
     * @return The bundle context.
     */
    public BundleContext getContext()
    {
        return context;
    }

    /**
     * Gets the singleton instance.
     * @return The instance.
     */
    public static AdaptersWsActivator getInstance()
    {
        return instance;
    }

    /**
     * Get the NIL Settings provider instance.
     * @return The singleton instance.
     */
    public static NilSettingsProvider getSettingsProvider()
    {
        return nilSettings;
    }
}
