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
 */

package org.ziptie.server.security;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import org.ziptie.server.security.internal.SecurityActivator;

/**
 * ZSecurityFilter
 */
public class ZSecurityFilter implements Filter
{
    /**
     * Constructor.
     */
    public ZSecurityFilter()
    {
    }

    /** {@inheritDoc} */
    public void init(FilterConfig config) throws ServletException
    {
    }

    /** {@inheritDoc} */
    public void destroy()
    {
    }

    /** {@inheritDoc} */
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException
    {
        ISecurityServiceEx securityService = SecurityActivator.getSecurityService();

        ZUserSession zsession = (ZUserSession) securityService.getUserSession();
        zsession.setLocale(req.getLocale());

        chain.doFilter(req, resp);
    }
}
