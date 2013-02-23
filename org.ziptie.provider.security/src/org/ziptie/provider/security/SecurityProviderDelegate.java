package org.ziptie.provider.security;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.security.internal.SecurityProviderActivator;
import org.ziptie.server.security.SecurityHandler;
import org.ziptie.server.security.ZPrincipal;
import org.ziptie.server.security.ZRole;

/**
 * SecurityProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.security.ISecurityProvider",
            serviceName = "SecurityService", portName = "SecurityPort")
public class SecurityProviderDelegate implements ISecurityProvider
{
    public void logoutCurrentUser()
    {
        getProvider().logoutCurrentUser();
    }

    /** {@inheritDoc} */
    public void changePassword(String username, String password)
    {
        getProvider().changePassword(username, password);
    }

    /** {@inheritDoc} */
    public void changeMyPassword(String password)
    {
        getProvider().changeMyPassword(password);
    }

    /** {@inheritDoc} */
    public void createRole(String role, List<String> permissions)
    {
        getProvider().createRole(role, permissions);
    }

    /** {@inheritDoc} */
    public void createUser(String username, String fullName, String email, String password, String role)
    {
        getProvider().createUser(username, fullName, email, password, role);
    }

    /** {@inheritDoc} */
    public void deleteRole(String role)
    {
        getProvider().deleteRole(role);
    }

    /** {@inheritDoc} */
    public void deleteUser(String username)
    {
        getProvider().deleteUser(username);
    }

    /** {@inheritDoc} */
    public List<String> getAvailablePermissions()
    {
        return getProvider().getAvailablePermissions();
    }

    /** {@inheritDoc} */
    public List<ZRole> getAvailableRoles()
    {
        return getProvider().getAvailableRoles();
    }

    /** {@inheritDoc} */
    public ZPrincipal getCurrentUser()
    {
        return getProvider().getCurrentUser();
    }

    /** {@inheritDoc} */
    public ZRole getRole(String role)
    {
        return getProvider().getRole(role);
    }

    /** {@inheritDoc} */
    public void updateRole(ZRole zrole)
    {
        getProvider().updateRole(zrole);
    }

    /** {@inheritDoc} */
    public void updateUser(String username, String fullName, String email, String role)
    {
        getProvider().updateUser(username, fullName, email, role);
    }

    /** {@inheritDoc} */
    public List<ZPrincipal> listUsers()
    {
        return getProvider().listUsers();
    }
    
    /** {@inheritDoc} */
    public ZPrincipal getUser(String username)
    {
        return getProvider().getUser(username);
    }

    /** {@inheritDoc} */
    public License getLicense()
    {
        return getProvider().getLicense();
    }

    /**
     * Get the underlying ISecurityProvider implementation.
     *
     * @return the ISecurityProvider implementation
     */
    private ISecurityProvider getProvider()
    {
        ISecurityProvider provider = SecurityProviderActivator.getSecurityProvider();
        if (provider == null)
        {
            throw new RuntimeException("SecurityProvider is unavailable."); //$NON-NLS-1$
        }

        return (ISecurityProvider) SecurityHandler.newProxy(provider);
    }
}
