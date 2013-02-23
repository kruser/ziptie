package org.ziptie.provider.events;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQTextMessage;
import org.apache.log4j.Logger;
import org.ziptie.provider.events.internal.EventsActivator;
import org.ziptie.server.security.ISecurityServiceEx;
import org.ziptie.zap.security.IUserSession;
import org.ziptie.zap.security.IUserSessionListener;

/**
 * EventProvider
 */
public class EventProvider implements IEventProvider
{
    private static final Logger LOGGER = Logger.getLogger(EventProvider.class);

    private static final int WAIT_TIME = 1900;  // 1900 seconds. longer than session timeout.

    private Session session;
    private ConcurrentHashMap<IUserSession, Subscription> subscriptions;

    public EventProvider()
    {
        subscriptions = new ConcurrentHashMap<IUserSession, Subscription>();

        try
        {
            // Create a ConnectionFactory
            ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory("vm://localhost"); //$NON-NLS-1$

            // Create a Connection
            Connection connection = connectionFactory.createConnection();
            connection.start();

            // Create a Session
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            
            ISecurityServiceEx securityService = EventsActivator.getSecurityService();
            securityService.registerUserSessionListener(new SessionListener());
        }
        catch (JMSException e)
        {
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void subscribe(String queueName)
    {
        try
        {
            ISecurityServiceEx securityService = EventsActivator.getSecurityService();
            IUserSession userSession = securityService.getUserSession();

            Subscription subscription = subscriptions.get(userSession);
            if (subscription == null)
            {
                subscription = new Subscription();
                subscriptions.put(userSession, subscription);
            }

            if (!subscription.isSubscribed(queueName))
            {
                Destination topic = session.createTopic(queueName);
                MessageConsumer consumer = session.createConsumer(topic);
                subscription.subscribe(queueName, consumer);
            }
        }
        catch (JMSException e)
        {
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void unsubscribe(String queueName)
    {
        ISecurityServiceEx securityService = EventsActivator.getSecurityService();
        IUserSession userSession = securityService.getUserSession();

        Subscription subscription = subscriptions.get(userSession);
        if (subscription != null)
        {
            subscription.unsubscribe(queueName);
        }
    }

    /** {@inheritDoc} */
    public List<Event> poll()
    {
        ISecurityServiceEx securityService = EventsActivator.getSecurityService();
        IUserSession userSession = securityService.getUserSession();

        Subscription subscription = subscriptions.get(userSession);
        if (subscription != null)
        {
            for (int i = 0; i < WAIT_TIME; i++)
            {
                List<Event> messages = subscription.getMessages();
                if (messages.size() > 0)
                {
                    return messages;
                }
                else
                {
                    try
                    {
                        Thread.sleep(1000L);
                    }
                    catch (InterruptedException e)
                    {
                        break;
                    }
                }
            }
        }

        return new ArrayList<Event>();
    }

    // ----------------------------------------------------------------------
    //                        I N N E R   C L A S S E S
    // ----------------------------------------------------------------------
    
    /**
     * Subscription
     */
    private class Subscription
    {
        private HashMap<String, MessageConsumer> subscriptions;

        Subscription()
        {
            subscriptions = new HashMap<String, MessageConsumer>();
        }

        /**
         * Is the current (invoking) client subscribed to the specified queue?
         *
         * @param queueName the queue name
         * @return true if already subscribed, false otherwise
         */
        boolean isSubscribed(String queueName)
        {
            return subscriptions.containsKey(queueName);
        }

        /**
         * Subscribe the (invoking) client to the specified queue.
         *
         * @param queueName the queue name
         * @param consumer the message consumer, needed for unsubscription
         */
        synchronized void subscribe(String queueName, MessageConsumer consumer)
        {
            subscriptions.put(queueName, consumer);
        }

        /**
         * Unsubscribe the (invoking) client from the specified queue.
         *
         * @param queueName the queue name
         */
        synchronized void unsubscribe(String queueName)
        {
            try
            {
                MessageConsumer consumer = subscriptions.remove(queueName);
                if (consumer != null)
                {
                    consumer.close();
                }
            }
            catch (JMSException e)
            {
                // ignore
            }
        }

        /**
         * Unsubscribe the (invoking) client from all queues.
         */
        void unsubscribeAll()
        {
            List<String> queues = new ArrayList<String>();
            queues.addAll(subscriptions.keySet());
            for (String queueName : queues)
            {
                unsubscribe(queueName);
            }
        }

        /**
         * Get the messages
         * @return
         */
        List<Event> getMessages()
        {
            ArrayList<Event> events = new ArrayList<Event>();
            synchronized (this)
            {
                for (Entry<String, MessageConsumer> entry : subscriptions.entrySet())
                {
                    String queueName = entry.getKey();
                    MessageConsumer consumer = entry.getValue();
                    try
                    {
                        while (true)
                        {
                            Message message = consumer.receiveNoWait();
                            if (message != null)
                            {
                                if (LOGGER.isTraceEnabled())
                                {
                                    LOGGER.trace(String.format("Dequeued event from %s of type %s", queueName, message.getJMSType())); //$NON-NLS-1$
                                }
                                events.add(convertMessage(queueName, message));
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                    catch (JMSException e)
                    {
                        // ignore
                    }
                }
            }

            // Sort the events by time
            Collections.sort(events, new Comparator<Event>() {
                public int compare(Event event1, Event event2)
                {
                    long eventtime1 = event1.getOriginTime();
                    long eventtime2 = event2.getOriginTime();
                    if (eventtime1 > eventtime2)
                    {
                        return 1;
                    }
                    else if (eventtime1 < eventtime2)
                    {
                        return -1;
                    }
                    
                    return 0;
                }
            });

            return events;
        }

        private Event convertMessage(String queueName, Message message) throws JMSException
        {
            Event event = new Event();

            if (message instanceof ActiveMQTextMessage)
            {
                ActiveMQTextMessage textMessage = (ActiveMQTextMessage) message;

                event.setQueue(queueName);
                event.setText(textMessage.getText());
                event.setOriginTime(textMessage.getBrokerInTime());
                event.setType(textMessage.getJMSType());
            }

            return event;
        }
    }

    /**
     * SessionListener
     */
    private class SessionListener implements IUserSessionListener
    {
        public void sessionCreated(IUserSession session)
        {
            // nothing
        }

        public void sessionDestroyed(IUserSession session)
        {
            Subscription subscription = subscriptions.get(session);
            if (subscription != null)
            {
                subscription.unsubscribeAll();
            }
        }
    }
}
