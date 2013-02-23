package org.ziptie.provider.security;

import java.security.Principal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;
import org.ziptie.provider.security.internal.LicenseElf;
import org.ziptie.provider.security.internal.SecurityProviderActivator;
import org.ziptie.server.security.SecurityElf;
import org.ziptie.server.security.ZPrincipal;
import org.ziptie.server.security.ZRole;
import org.ziptie.zap.security.IUserSession;

/**
 * SecurityProvider
 */
public class SecurityProvider implements ISecurityProvider
{
    private static final Logger LOGGER = Logger.getLogger(SecurityProvider.class);

    /** Special permission only possessed by 'admin' users.  Expands into all
     * available permissions.
     */
    private static final String ORG_ZIPTIE_ACCESS_ALL = "org.ziptie.access.all"; //$NON-NLS-1$

    private static final String ADMIN_USER = "admin"; //$NON-NLS-1$
    private static final String ADMINISTRATOR_ROLE = "Administrator"; //$NON-NLS-1$

    /** {@inheritDoc} */
    public void logoutCurrentUser()
    {
        IUserSession userSession = SecurityProviderActivator.getSecurityService().getUserSession();
        if (userSession != null)
        {
            userSession.invalidate();
        }
        else
        {
            LOGGER.warn("Logout performed against non-existent session."); //$NON-NLS-1$
        }
    }

    /** {@inheritDoc} */
    public void changePassword(String username, String password)
    {
        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZPrincipal zprincipal = (ZPrincipal) session.get(ZPrincipal.class, username);
        zprincipal.setMD5Password(SecurityElf.calcMD5(username, password));
        session.update(zprincipal);
    }

    /** {@inheritDoc} */
    public void changeMyPassword(String password)
    {
        // Get the invoking user
        Principal principal = SecurityProviderActivator.getSecurityService().getUserSession().getPrincipal();

        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZPrincipal zprincipal = (ZPrincipal) session.get(ZPrincipal.class, principal.getName());
        zprincipal.setMD5Password(SecurityElf.calcMD5(principal.getName(), password));
        session.update(zprincipal);
    }

    /** {@inheritDoc} */
    public ZRole getRole(String role)
    {
        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZRole zrole = (ZRole) session.get(ZRole.class, role);

        if (zrole != null)
        {

            // Expand ORG_ZIPTIE_ACCESS_ALL permission into all available permissions.
            if (zrole.hasPermission(ORG_ZIPTIE_ACCESS_ALL))
            {
                // We're about to change the ZRole object at runtime, we don't want these
                // changes persisted
                session.setReadOnly(zrole, true);

                Set<String> permissions = new HashSet<String>();
                for (String perm : getAvailablePermissions())
                {
                    String[] split = perm.split("="); //$NON-NLS-1$
                    permissions.add(split[0]);
                }
                zrole.setPermissionSet(permissions);
            }
        }
        
        return zrole;
    }

    /** {@inheritDoc} */
    public void createRole(String role, List<String> permissions)
    {
        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZRole zrole = new ZRole(role);
        Set<String> permSet = new HashSet<String>();
        permSet.addAll(permissions);

        zrole.setPermissionSet(permSet);
        session.save(zrole);
    }

    /** {@inheritDoc} */
    public void updateRole(ZRole zrole)
    {
        if (zrole.getName().equals(ADMINISTRATOR_ROLE))
        {
            throw new SecurityException("Updating the Administrator role is not allowed."); //$NON-NLS-1$
        }

        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        session.update(zrole);
    }

    /** {@inheritDoc} */
    public void deleteRole(String role)
    {
        if (role.equals(ADMINISTRATOR_ROLE))
        {
            throw new SecurityException("Deleting the Administrator role is not allowed."); //$NON-NLS-1$
        }

        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        session.delete(new ZRole(role));
    }

    /** {@inheritDoc} */
    public void createUser(String username, String fullName, String email, String password, String role)
    {
        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZRole zrole = getRole(role);
        ZPrincipal newUser = new ZPrincipal(username, fullName, email, SecurityElf.calcMD5(username, password), zrole);
        session.save(newUser);
    }

    /** {@inheritDoc} */
    public void updateUser(String username, String fullName, String email, String role)
    {
        if (username.equals(ADMIN_USER) && !role.equals(ADMINISTRATOR_ROLE))
        {
            throw new SecurityException("You cannot change the role of the 'admin' account."); //$NON-NLS-1$
        }

        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZPrincipal principal = (ZPrincipal) session.get(ZPrincipal.class, username);
        if (principal != null)
        {
            principal.setFullName(fullName);
            principal.setEmail(email);
            ZRole newRole = (ZRole) session.get(ZRole.class, role);
            if (newRole == null)
            {
                throw new SecurityException("Specified role " + role + " does not exist."); //$NON-NLS-1$ //$NON-NLS-2$
            }
            principal.setRole(newRole);
            session.update(principal);
        }
    }

    /** {@inheritDoc} */
    public void deleteUser(String username)
    {
        if (username.equals(ADMIN_USER))
        {
            throw new SecurityException("You cannot delete Administrator role."); //$NON-NLS-1$
        }

        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        ZPrincipal principal = (ZPrincipal) session.get(ZPrincipal.class, username);
        session.delete(principal);
    }

    /** {@inheritDoc} */
    public ZPrincipal getUser(String username)
    {
        return SecurityProviderActivator.getSecurityService().getZPrincipal(username);
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<ZPrincipal> listUsers()
    {
        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        Criteria criteria = session.createCriteria(ZPrincipal.class);
        List<ZPrincipal> list = criteria.list();

        Collections.sort(list, new Comparator<ZPrincipal>() {
            public int compare(ZPrincipal p1, ZPrincipal p2)
            {
                return p1.getName().compareToIgnoreCase(p2.getName());
            }
        });

        return list;
    }

    /** {@inheritDoc} */
    public List<String> getAvailablePermissions()
    {
        List<String> availablePermissions = SecurityProviderActivator.getSecurityService().getAvailablePermissions();
        return availablePermissions;
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<ZRole> getAvailableRoles()
    {
        SessionFactory sessionFactory = SecurityProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        Criteria criteria = session.createCriteria(ZRole.class);

        List<ZRole> list = new ArrayList<ZRole>();
        for (ZRole role : (List<ZRole>) criteria.list())
        {
            session.evict(role);
            if (role.getName().equals(ADMINISTRATOR_ROLE))
            {
                list.add(getRole(ADMINISTRATOR_ROLE));
            }
            else
            {
                list.add(role);
            }
        }

        return list;
    }

    /** {@inheritDoc} */
    public ZPrincipal getCurrentUser()
    {
        return (ZPrincipal) SecurityProviderActivator.getSecurityService().getUserSession().getPrincipal();
    }

    /** {@inheritDoc} */
    public License getLicense()
    {
        return LicenseElf.loadLicense();
    }
}
