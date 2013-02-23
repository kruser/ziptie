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
 */
package org.ziptie.provider.launchers;

import java.util.List;

import org.hibernate.classic.Session;
import org.hibernate.criterion.Restrictions;


/**
 * LaunchersProvider
 */
public class LaunchersProvider implements ILaunchersProvider
{

    /** {@inheritDoc} */
    public void addOrUpdateLauncher(String name, String url)
    {
        try
        {
            Session session = LaunchersActivator.getSessionFactory().getCurrentSession();
            Launcher launcher = getLauncher(name, session);
            if (launcher != null)
            {
                launcher.setUrl(url);
                session.saveOrUpdate(launcher);
            }
            else
            {
                session.save(new Launcher(name, url));
            }
        }
        catch (Exception e)
        {
                e.printStackTrace();
        }
    }

    /** {@inheritDoc} */
    public void deleteLauncher(String name)
    {
        Session session = LaunchersActivator.getSessionFactory().getCurrentSession();
        Launcher launcher = getLauncher(name, session);
        if (launcher != null)
        {
            session.delete(launcher);
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<Launcher> getLaunchers()
    {
        Session session = LaunchersActivator.getSessionFactory().getCurrentSession();
        return (List<Launcher>) session.createCriteria(Launcher.class).list();
    }
    
    /**
     * Get the launcher with the given name
     * @param name
     * @param session
     * @return
     */
    private Launcher getLauncher(String name, Session session)
    {
        return (Launcher) session.createCriteria(Launcher.class).add(Restrictions.eq("name", name)).uniqueResult();
    }
}
