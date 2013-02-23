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
 * Contributor(s):
 */
package org.ziptie.server.job;

import java.lang.reflect.Method;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.xml.namespace.QName;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.WebServiceClient;

/**
 * Helps manage the adapter service endpoints.
 */
public final class AdapterEndpointElf
{
    private static final Map<String, Map<Class<?>, Object>> SERVICES;
    private static final Lock LOCK;

    static
    {
        SERVICES = new HashMap<String, Map<Class<?>, Object>>();
        LOCK = new ReentrantLock();
    }

    private AdapterEndpointElf()
    {
    }

    /**
     * Get the service endpoint of the given type for the given device type.
     * @param <T> The service class
     * @param type The service class type. 
     * @param deviceType The adapter ID.
     * @return The service endpoint instance.
     */
    @SuppressWarnings({ "unchecked", "nls" })
    public static <T> T getEndpoint(Class<T> type, String deviceType)
    {
        try
        {
            LOCK.lock();

            Map<Class<?>, Object> services = SERVICES.get(deviceType);
            if (services != null)
            {
                Object service = services.get(type);
                if (service != null)
                {
                    return (T) service;
                }
            }
            else
            {
                services = new HashMap<Class<?>, Object>();
                SERVICES.put(deviceType, services);
            }

            String remoteNilScheme = System.getProperty("org.ziptie.nil.remoteScheme", "https");
            String remoteNilIP = System.getProperty("org.ziptie.nil.remoteIp", "localhost");
            String remoteNilPort = System.getProperty("org.ziptie.nil.remotePort", "8080");

            String endpoint = String.format("%s://%s:%s/services/adapters/%s", remoteNilScheme, remoteNilIP, remoteNilPort, deviceType);

            String typeName = type.getName();

            Class<?> serviceClass = Class.forName(typeName + "Service", true, type.getClassLoader());
            WebServiceClient serviceAnnotation = serviceClass.getAnnotation(WebServiceClient.class);
            URL wsdl = serviceClass.getResource("/WEB-INF/" + serviceAnnotation.wsdlLocation()); //$NON-NLS-1$
            QName name = new QName(serviceAnnotation.targetNamespace(), serviceAnnotation.name());

            Method getter = serviceClass.getMethod("get" + typeName.substring(typeName.lastIndexOf('.') + 1) + "Port");
            Object serviceInstance = serviceClass.getConstructor(URL.class, QName.class).newInstance(wsdl, name);
            Object service = getter.invoke(serviceInstance);

            ((BindingProvider) service).getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endpoint);
            services.put(type, service);

            return (T) service;
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            LOCK.unlock();
        }
    }
}
