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
package org.ziptie.server.discovery.internal;

import java.io.ByteArrayOutputStream;
import java.util.Date;
import java.util.Properties;

import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.ziptie.discovery.AbstractBaseStatsMonitor;
import org.ziptie.discovery.DiscoveryStatus;
import org.ziptie.discovery.TimeElf;
import org.ziptie.zap.jms.EventElf;

/**
 * Stats monitor for tracking events for the event publisher.
 */
class DiscoveryStatsMonitor extends AbstractBaseStatsMonitor
{
    private static final Logger LOGGER = Logger.getLogger(DiscoveryStatsMonitor.class);

    private static final String DISCOVERY_EVENT_QUEUE = "discovery"; //$NON-NLS-1$
    private static final String UTF_8_ENCODING = "utf-8"; //$NON-NLS-1$

    DiscoveryStatsMonitor()
    {
    }

    @Override
    protected void logIfIdle(DiscoveryStatus newStats)
    {
        if (!newStats.isActive() && getLatestDiscoveryStatus().isActive())
        {
            String timeDiff = TimeElf.getDuration(newStats.getStartedRunning(), new Date());
            String logMessage = "The Discovery Engine went idle after " + timeDiff + ". "
                    + newStats.getAddressesAnalyzed() + " total addresses analyzed, " + newStats.getRespondedToSnmp()
                    + " responded.";
            LOGGER.info(logMessage);
        }
    }

    @SuppressWarnings("nls")
    @Override
    protected void processJmsAlerts(DiscoveryStatus newStats)
    {
        Properties props = new Properties();
        props.setProperty("QueueSize", String.valueOf(newStats.getQueueSize()));
        props.setProperty("IsActive", String.valueOf(newStats.isActive()));
        props.setProperty("AddressesAnalyzed", String.valueOf(newStats.getAddressesAnalyzed()));
        props.setProperty("RespondedToSnmp", String.valueOf(newStats.getRespondedToSnmp()));

        String comment = String.format("Discovery %d analyzed.", newStats.getAddressesAnalyzed());

        sendEvent(props, comment);
    }

    private void sendEvent(Properties properties, String comment)
    {
        try
        {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            properties.storeToXML(baos, comment, UTF_8_ENCODING);

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(DISCOVERY_EVENT_QUEUE, baos.toString(UTF_8_ENCODING));
            EventElf.sendMessage(DISCOVERY_EVENT_QUEUE, message);
        }
        catch (Exception e)
        {
            LOGGER.error("Unable to send JMS event", e); //$NON-NLS-1$
        }
    }
}
