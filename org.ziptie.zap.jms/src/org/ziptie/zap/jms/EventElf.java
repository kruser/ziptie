package org.ziptie.zap.jms;

import javax.jms.Connection;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.TextMessage;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.commons.pool.BaseKeyedPoolableObjectFactory;
import org.apache.commons.pool.impl.StackKeyedObjectPool;

/**
 * EventElf
 */
@SuppressWarnings("nls")
public final class EventElf
{
    private static Connection connection;
    private static StackKeyedObjectPool sessionPool;
    private static StackKeyedObjectPool producerPool;

    static
    {
        try
        {
            // Create a ConnectionFactory
            String brokerUrl = System.getProperty("amq.broker.url", "vm://localhost");
            ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(brokerUrl);

            // Create a Connection
            connection = connectionFactory.createConnection();
            connection.start();

            sessionPool = new StackKeyedObjectPool(new SessionKeyedObjectPoolFactory());
            producerPool = new StackKeyedObjectPool(new ProducerKeyedObjectPoolFactory());
        }
        catch (JMSException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Create a TextMessage destined for the specified queue.
     *
     * @param queueName the name of the destination queue
     * @param message the message text
     * @return a TextMessage object
     * @throws Exception thrown if an exception occurs
     */
    public static TextMessage createTextMessage(String queueName, String message) throws Exception
    {
        Session jmsSession = (Session) sessionPool.borrowObject(queueName);
        try
        {
            return jmsSession.createTextMessage(message);
        }
        finally
        {
            sessionPool.returnObject(queueName, jmsSession);
        }
    }

    /**
     * @param queueName
     * @param message
     * @throws Exception
     */
    public static void sendMessage(String queueName, Message message) throws Exception
    {
        MessageProducer producer = (MessageProducer) producerPool.borrowObject(queueName);
        try
        {
            producer.send(message);
        }
        finally
        {
            producerPool.returnObject(queueName, producer);
        }
    }

    /**
     * SessionKeyedObjectPoolFactory
     */
    private static class SessionKeyedObjectPoolFactory extends BaseKeyedPoolableObjectFactory
    {
        /** {@inheritDoc} */
        @Override
        public void destroyObject(Object key, Object object) throws Exception
        {
            Session session = (Session) object;
            session.close();
        }

        /** {@inheritDoc} */
        @Override
        public Object makeObject(Object key) throws Exception
        {
            return connection.createSession(false, javax.jms.Session.AUTO_ACKNOWLEDGE);
        }
    }

    /**
     * ProducerKeyedObjectPoolFactory
     */
    private static class ProducerKeyedObjectPoolFactory extends BaseKeyedPoolableObjectFactory
    {
        /** {@inheritDoc} */
        @Override
        public void destroyObject(Object key, Object object) throws Exception
        {
            MessageProducer producer = (MessageProducer) object;
            producer.close();
        }

        /** {@inheritDoc} */
        @Override
        public Object makeObject(Object key) throws Exception
        {
            Session jmsSession = (Session) sessionPool.borrowObject(key.toString());
            try
            {
                // Create the destination (Topic or Queue)
                Destination destination = jmsSession.createTopic(key.toString());
    
                // Create a MessageProducer from the Session to the Topic or Queue
                MessageProducer producer = jmsSession.createProducer(destination);
                producer.setDeliveryMode(DeliveryMode.NON_PERSISTENT);
    
                return producer;
            }
            finally
            {
                sessionPool.returnObject(key.toString(), jmsSession);
            }
        }
    }
}
