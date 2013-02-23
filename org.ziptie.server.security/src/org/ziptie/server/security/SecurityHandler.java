package org.ziptie.server.security;

import java.lang.annotation.Annotation;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.ziptie.server.security.internal.SecurityActivator;
import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * SecurityProxy
 */
public final class SecurityHandler implements InvocationHandler
{
    private static final Map<Class<?>, Class<?>> PRIMITIVE_TYPE_MAP;
    private static final Map<Object, Object> SECURED_PROXY_MAP;
    private static final Map<Method, ZInvocationSecurity> METHOD_ANNOTATION_MAP;
    private static final ZInvocationSecurity NULL_ANNOTATION;

    private Object suspect;

    static
    {
        PRIMITIVE_TYPE_MAP = new HashMap<Class<?>, Class<?>>(7);
        PRIMITIVE_TYPE_MAP.put(Byte.class, Byte.TYPE);
        PRIMITIVE_TYPE_MAP.put(Long.class, Long.TYPE);
        PRIMITIVE_TYPE_MAP.put(Short.class, Short.TYPE);
        PRIMITIVE_TYPE_MAP.put(Boolean.class, Boolean.TYPE);
        PRIMITIVE_TYPE_MAP.put(Integer.class, Integer.TYPE);
        PRIMITIVE_TYPE_MAP.put(Character.class, Character.TYPE);

        SECURED_PROXY_MAP = new ConcurrentHashMap<Object, Object>();
        METHOD_ANNOTATION_MAP = new ConcurrentHashMap<Method, ZInvocationSecurity>();

        NULL_ANNOTATION = new ZInvocationSecurity()
        {
            public String perm()
            {
                return ZInvocationSecurity.UNSECURED;
            }

            public Class<? extends Annotation> annotationType()
            {
                return ZInvocationSecurity.class;
            }
        };
    }

    /**
     * Constructor.
     *
     * @param instance the instance to apply security to
     */
    private SecurityHandler(Object instance)
    {
        this.suspect = instance;
    }

    /**
     * Create a security proxy around the specified object.
     *
     * @param instance the security-annotated object to proxy
     * @return the security-wrapped proxy
     */
    public static Object newProxy(Object instance)
    {
        // Proxies are cached for performance
        Object proxy = SECURED_PROXY_MAP.get(instance);
        if (proxy == null)
        {
            Class<?>[] interfaces = instance.getClass().getInterfaces();
            proxy = Proxy.newProxyInstance(instance.getClass().getClassLoader(), interfaces, new SecurityHandler(instance));
            SECURED_PROXY_MAP.put(instance, proxy);
        }

        return proxy;
    }

    /** {@inheritDoc} */
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable
    {
        // Proxied-methods have their annotations cached for performance.  Poking around
        // interfaces for annotations on every invocation is expensive.
        ZInvocationSecurity annotation = METHOD_ANNOTATION_MAP.get(method);
        if (annotation == null)
        {
            annotation = findAnnotation(method, args);
        }

        String permission = annotation.perm();
        if (!permission.equals(ZInvocationSecurity.UNSECURED))
        {
            ISecurityServiceEx securityService = SecurityActivator.getSecurityService();
            ZPrincipal zprincipal = (ZPrincipal) securityService.getUserSession().getPrincipal();
            ZRole role = zprincipal.getRole();
            if (!role.hasPermission(permission))
            {
                throw new SecurityException(String.format("User '%s' does not have permission '%s'.", zprincipal.getName(), permission)); //$NON-NLS-1$
            }
        }

        return method.invoke(suspect, args);
    }

    /**
     * Find the ZInvocationSecurity annotation on the proxied class' method
     * if it exists.  This method always returns <i>some</i> ZInvocationSecurity
     * annotation instance, even if it's just the NULL_ANNOTATION.
     *
     * @param method the method to look for the annotation on
     * @param args the args to the method
     * @return a ZInvocationSecurity annotation
     */
    private ZInvocationSecurity findAnnotation(Method method, Object[] args)
    {
        ZInvocationSecurity annotation = null;
        try
        {
            Class<?>[] argClasses = getArgClasses(args);

            for (Class<?> iface : suspect.getClass().getInterfaces())
            {
                try
                {
                    Method actualMethod = iface.getMethod(method.getName(), argClasses);
                    annotation = actualMethod.getAnnotation(ZInvocationSecurity.class);
                    if (annotation != null)
                    {
                        return annotation;
                    }
                }
                catch (SecurityException e)
                {
                    throw new RuntimeException(e);
                }
                catch (NoSuchMethodException e)
                {
                    continue;
                }
            }

            annotation = suspect.getClass().getAnnotation(ZInvocationSecurity.class);
            if (annotation == null)
            {
                annotation = NULL_ANNOTATION;
            }

            return annotation;
        }
        finally
        {
            METHOD_ANNOTATION_MAP.put(method, annotation);
        }
    }

    private Class<?>[] getArgClasses(Object[] args)
    {
        if (args == null)
        {
            return new Class[0];
        }

        Class<?>[] classes = new Class[args.length];
        int i = 0;
        for (Object object : args)
        {
            Class<?> primitive = PRIMITIVE_TYPE_MAP.get(object.getClass());
            classes[i++] = primitive != null ? primitive : object.getClass();
        }

        return classes;
    }
}
