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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim.http;

import java.io.PrintStream;
import java.util.Iterator;
import java.util.List;

import org.ziptie.net.sim.operations.IOperation;
import org.ziptie.net.sim.operations.StateEvent;
import org.ziptie.net.sim.operations.StateWatcher;

import simple.http.Request;
import simple.http.Response;
import simple.http.load.BasicService;
import simple.http.serve.Context;

/**
 * HTTP interface to show the current state of operations within the simulator
 */
public class StateHttpService extends BasicService
{
    private StateWatcher stateWatcher = StateWatcher.getInstance();

    public StateHttpService(Context context)
    {
        super(context);
    }

    /* (non-Javadoc)
     * @see simple.http.serve.BasicResource#process(simple.http.Request, simple.http.Response)
     */
    protected void process(Request req, Response resp) throws Exception
    {
        String opId = req.getParameter("opId");
        if (opId == null)
        {
            processShowAll(req, resp);
        }
        else
        {
            PrintStream ps = resp.getPrintStream();

            List states = stateWatcher.getStates(Integer.parseInt(opId));
            if (states == null)
            {
                ps.println("No operation found for id: " + opId);
                ps.close();
                return;
            }

            ps.println("<table border='1' cellpadding='1' cellspacing='1'>");
            ps.println("<tr><td width=\'80\'>Type</td><td width=\'300\'>Message</td></tr>");
            Iterator iter = states.iterator();
            while (iter.hasNext())
            {
                StateEvent event = (StateEvent) iter.next();
                ps.print("<tr><td>");
                ps.print(event.getType());
                ps.print("</td><td>");
                ps.print(ConfigurationHttpService.htmlEscape(event.getMessage(), true));
                ps.println("</td></tr>");
            }

            ps.close();
        }
    }

    /**
     * @param req
     * @param resp
     */
    private void processShowAll(Request req, Response resp) throws Exception
    {
        List states = stateWatcher.getLatestStates();

        List openStates = states;
        List oldStates = states;

        PrintStream ps = resp.getPrintStream();
        ps.println("<table border='1' cellpadding='1' cellspacing='1'>");
        ps
          .println("<tr><td width='20'>ID</td><td width='80'>Remote IP</td><td width=\'80\'>Local IP</td><td width=\'250\'>Latest State</td><td width=\'250\'>Operation URL</td></tr>");

        Iterator iter = openStates.iterator();
        while (iter.hasNext())
        {
            StateEvent event = (StateEvent) iter.next();
            IOperation op = event.getSource();

            ps.print("<tr><td><a href='/state/?opId=" + op.getOperationId() + "'>");
            ps.print(op.getOperationId());
            ps.print("</a></td><td>");
            ps.print(op.getRemoteIp());
            ps.print("</td><td>");
            ps.print(op.getLocalIp());
            ps.print("</td><td>");
            ps.print(event.getType() + ": " + event.getMessage());
            ps.print("</td><td>");
            ps.print(op.getUri());
            ps.println("</tr>");
        }
        ps.println("</table>");
        ps.close();
    }
}
