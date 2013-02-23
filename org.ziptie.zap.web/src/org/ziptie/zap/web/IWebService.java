package org.ziptie.zap.web;

import javax.servlet.http.HttpSessionListener;

/**
 * IWebService
 */
public interface IWebService
{
    String PRIMARY_CONNECTOR = "Primary"; //$NON-NLS-1$

    /**
     * Get the access scheme of the named connector.
     *
     * @param connectorName the named connector
     * @return the access scheme (HTTP/HTTPS)
     */
    String getScheme(String connectorName);

    /**
     * Get the bound host name of the named connector.
     *
     * @param connectorName the named connector
     * @return the host name
     */
    String getHost(String connectorName);

    /**
     * Get the listen port of the named connector.
     *
     * @param connectorName the named connector
     * @return the listen port
     */
    int getPort(String connectorName);

    /**
     * Register an HttpSessionListener with the web container.
     *
     * @param listener the listener
     */
    void registerSessionListener(HttpSessionListener listener);

    /**
     * Unregister an HttpSessionListener from the web container.
     *
     * @param listener the listener
     */
    void unregisterSessionListener(HttpSessionListener listener);
}
