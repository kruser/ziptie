package org.ziptie.server.security;

import java.io.Serializable;
import java.security.Principal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpSession;

import org.mortbay.jetty.plus.jaas.JAASUserPrincipal;
import org.ziptie.zap.security.IUserSession;

/**
 * ZUserSession
 */
public class ZUserSession implements IUserSession
{
    private HttpSession session;

    private Locale locale;

    /**
     * Constructor.
     *
     * @param session the underlying HttpSession
     */
    public ZUserSession(HttpSession session)
    {
        this.session = session;
    }

    /** {@inheritDoc} */
    public Principal getPrincipal()
    {
        Principal principal = (Principal) session.getAttribute(Principal.class.getName());
        if (principal != null && principal instanceof JAASUserPrincipal)
        {
            JAASUserPrincipal jaasPrincipal = (JAASUserPrincipal) principal;
            Set<ZPrincipal> principals = jaasPrincipal.getSubject().getPrincipals(ZPrincipal.class);
            return principals.iterator().next();
        }

        return null;
    }

    /**
     * Set the user principal for this session.
     *
     * @param principal the user principal
     */
    public void setPrincipal(Principal principal)
    {
        session.setAttribute(Principal.class.getName(), principal);
    }

    /**
     * Set the locale for this session.
     *
     * @param locale the locale
     */
    public void setLocale(Locale locale)
    {
        this.locale = locale;
    }

    /** {@inheritDoc} */
    public Locale getLocale()
    {
        if (locale == null)
        {
            return Locale.getDefault();
        }

        return locale;
    }

    /** {@inheritDoc} */
    public void invalidate()
    {
        session.invalidate();
    }

    // --------------------------------------------------------------------
    // Methods from java.util.Map (extended by IUserSession)
    // --------------------------------------------------------------------

    /** {@inheritDoc} */
    public void clear()
    {
        for (String name : keySet())
        {
            session.removeAttribute(name);
        }
    }

    /** {@inheritDoc} */
    public boolean containsKey(Object key)
    {
        return session.getAttribute((String) key) != null;
    }

    /** {@inheritDoc} */
    public boolean containsValue(Object value)
    {
        Enumeration<?> attributeNames = session.getAttributeNames();
        while (attributeNames.hasMoreElements())
        {
            if (session.getAttribute((String) attributeNames.nextElement()).equals(value))
            {
                return true;
            }
        }

        return false;
    }

    /** {@inheritDoc} */
    public Set<java.util.Map.Entry<String, Serializable>> entrySet()
    {
        Enumeration<?> attributeNames = session.getAttributeNames();
        Set<java.util.Map.Entry<String, Serializable>> set = new HashSet<java.util.Map.Entry<String, Serializable>>();
        while (attributeNames.hasMoreElements())
        {
            String key = (String) attributeNames.nextElement();
            Serializable value = (Serializable) session.getAttribute(key);
            Entry entry = new Entry(key, value);
            set.add(entry);
        }

        return set;
    }

    /** {@inheritDoc} */
    public Collection<Serializable> values()
    {
        Enumeration<?> attributeNames = session.getAttributeNames();
        ArrayList<Serializable> values = new ArrayList<Serializable>();
        while (attributeNames.hasMoreElements())
        {
            values.add((Serializable) session.getAttribute((String) attributeNames.nextElement()));
        }

        return values;
    }

    /** {@inheritDoc} */
    public Serializable get(Object key)
    {
        return (Serializable) session.getAttribute((String) key);
    }

    /** {@inheritDoc} */
    public boolean isEmpty()
    {
        return !session.getAttributeNames().hasMoreElements();
    }

    /** {@inheritDoc} */
    public Set<String> keySet()
    {
        Enumeration<?> attributeNames = session.getAttributeNames();
        Set<String> set = new HashSet<String>();
        while (attributeNames.hasMoreElements())
        {
            set.add((String) attributeNames.nextElement());
        }

        return set;
    }

    /** {@inheritDoc} */
    public Serializable put(String key, Serializable value)
    {
        Serializable oldValue = (Serializable) session.getAttribute(key);
        session.setAttribute(key, value);

        return oldValue;
    }

    /** {@inheritDoc} */
    public void putAll(Map<? extends String, ? extends Serializable> t)
    {
        for (Map.Entry<? extends String, ? extends Object> entry : t.entrySet())
        {
            session.setAttribute(entry.getKey(), entry.getValue());
        }
    }

    /** {@inheritDoc} */
    public Serializable remove(Object key)
    {
        Serializable object = (Serializable) session.getAttribute((String) key);
        session.removeAttribute((String) key);
        return object;
    }

    /** {@inheritDoc} */
    public int size()
    {
        Enumeration<?> attributeNames = session.getAttributeNames();
        int size = 0;
        while (attributeNames.hasMoreElements())
        {
            size++;
        }

        return size;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null)
        {
            return false;
        }
        else if (obj == this)
        {
            return true;
        }

        try
        {
            ZUserSession other = (ZUserSession) obj;
            return this.session.getId().equals(other.session.getId());
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return session.getId().hashCode();
    }

    /**
     * Entry
     */
    private static class Entry implements java.util.Map.Entry<String, Serializable>
    {
        private String key;
        private Serializable value;

        Entry(String key, Serializable value)
        {
            this.key = key;
            this.value = value;
        }

        public String getKey()
        {
            return key;
        }

        public Serializable getValue()
        {
            return value;
        }

        public Serializable setValue(Serializable v)
        {
            Serializable oldValue = value;
            this.value = v;
            return oldValue;
        }
    }

    /** {@inheritDoc} */
    public boolean checkHasPermission(String permissionName)
    {
        return ((ZPrincipal) getPrincipal()).getRole().hasPermission(permissionName);
    }
}
