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

package org.ziptie.net.utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;

/**
 * @author rkruse
 */
public class PortScanTest extends TestCase
{
    /**
     * Tests the {@link PortScan} to a single host with a single port.
     *
     */
    public void testSingle()
    {
        IPAddress router = new IPAddress("10.100.15.3");
        List<Integer> results = PortScan.getInstance().scan(router, Collections.singletonList(new Integer(23)));
        assertEquals(23, results.get(0).intValue());
    }
    
    /**
     * Tests the {@link PortScan} to a single host with multiple ports.
     *
     */
    public void testMultiplePorts()
    {
        IPAddress router = new IPAddress("10.100.15.3");
        List<Integer> ports = new ArrayList<Integer>();
        ports.add(7);
        ports.add(22);
        ports.add(23);
        ports.add(80);
        ports.add(443);
        List<Integer> results = PortScan.getInstance().scan(router, ports);
        assertEquals(2, results.size());
        assertEquals(23, results.get(0).intValue());
        assertEquals(80, results.get(1).intValue());
    }
    
    public void testMultiThreaded() throws InterruptedException, ExecutionException
    {
        ExecutorService threadPool = Executors.newFixedThreadPool(10);
        IPAddress target = new IPAddress("10.100.15.4");
        List<Integer> ports = new ArrayList<Integer>();
        ports.add(22);
        ports.add(23);
        
        List<Future<List<Integer>>> futures = new ArrayList<Future<List<Integer>>>();
        for (int i = 0; i < 20; i++)
        {
            futures.add(threadPool.submit(new Scan(target, ports))); 
        }
        
        for(Future<List<Integer>> future: futures)
        {
            List<Integer> result = future.get();
            System.out.println(result); 
            assertEquals(1, result.size());
        }
    }
    
    private class Scan implements Callable<List<Integer>>
    {
        private IPAddress host;
        private List<Integer> ports;
        
        public Scan(IPAddress host, List<Integer> ports)
        {
            this.host = host;
            this.ports = ports;
        }
        
        public List<Integer> call() throws Exception
        {
            return PortScan.getInstance().scan(host, ports);
        }
    }
}

// -------------------------------------------------
// $Log: PortScanTest.java,v $
// Revision 1.3  2007/03/19 02:56:23  rkruse
// rewrite the portscan as a singleton service with semphores around the number of available scans. This will make it so that Windows won't think this is a virus and throttle things unnecessarily.
//
// Revision 1.3  2007/03/19 02:50:38  Rkruse
// rewrite the portscan as a singleton service with semphores around the number of available scans.  This will make it so that Windows won't think this is a virus and throttle things unnecessarily.  fixed #15255 "pix 10.100.20.42 - won't backup due to protocols" .
//
// Revision 1.2 2007/03/15 22:49:18 Rkruse
// fixed #15255 "pix 10.100.20.42 - won't backup due to credentials" . Don't
// specify the timeout on the initial port scan done by the protocol manager.
// This will play nice with Windows servers when they start to rate limit
// outbound tcp connections.
//
// Revision 1.1 2007/01/17 23:04:39 Rkruse
// move port scan to a new package
//
// Revision 1.2 2007/01/05 03:04:29 Rkruse
// serial port scan...merge from ziptie
//
// Revision 1.4 2007/01/05 03:01:48 rkruse
// when multithreaded=false, do a serialScan, don't start up a thread pool.
//
// Revision 1.3 2006/11/02 02:00:37 lbayer
// new improved license headers
//
// Revision 1.2 2006/11/02 00:57:21 lbayer
// apply ziptie license header to all java files
//
// Revision 1.1 2006/10/20 22:56:37 rkruse
// merging from hammerhead
//
// Revision 1.1 2006/10/18 20:00:35 Rkruse
// moving from the NIL
//
// Revision 1.1 2006/08/22 23:07:18 Rkruse
// port scanner
//
// Revision 1.0 Aug 21, 2006 rkruse
// Initial revision
// --------------------------------------------------
