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
package org.ziptie.provider.scheduler;

import javax.jms.TextMessage;

import org.quartz.JobExecutionContext;
import org.quartz.Trigger;
import org.quartz.listeners.TriggerListenerSupport;
import org.ziptie.zap.jms.EventElf;
import org.ziptie.zap.metro.MarshallElf;

/**
 * EventGenerator
 */
public class TriggerEventProducer extends TriggerListenerSupport
{
    private static final String SCHEDULER_TRIGGER_QUEUE = "scheduler.trigger";

    /**
     * Constructor
     */
    public TriggerEventProducer()
    {
        getLog().info(this.getClass().getSimpleName() + " registered with scheduler.");
    }

    /** {@inheritDoc} */
    @Override
    public void triggerFired(Trigger trigger, JobExecutionContext context)
    {
        try
        {
            ExecutionData execution = (ExecutionData) context.get(ExecutionData.class);
            String jaxbObjectString = MarshallElf.createJaxbObjectString(execution);

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(SCHEDULER_TRIGGER_QUEUE, jaxbObjectString);
            message.setJMSType("fired");
            EventElf.sendMessage(SCHEDULER_TRIGGER_QUEUE, message);
        }
        catch (Exception e)
        {
            getLog().error("Unable to send JMS event", e);
        }
    }

    /** {@inheritDoc} */
    @Override
    public void triggerComplete(Trigger trigger, JobExecutionContext context, int triggerInstructionCode)
    {
        try
        {
            ExecutionData execution = (ExecutionData) context.get(ExecutionData.class);
            String jaxbObjectString = MarshallElf.createJaxbObjectString(execution);

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(SCHEDULER_TRIGGER_QUEUE, jaxbObjectString);
            message.setJMSType("complete");
            EventElf.sendMessage(SCHEDULER_TRIGGER_QUEUE, message);
        }
        catch (Exception e)
        {
            getLog().error("Unable to send JMS event", e);
        }
    }

    /** {@inheritDoc} */
    public String getName()
    {
        return this.getClass().getSimpleName();
    }
}
