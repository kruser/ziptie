package org.ziptie.provider.events;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.events.internal.EventsActivator;

/**
 * EventProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.events.IEventProvider", //$NON-NLS-1$
            serviceName = "EventsService", portName = "EventsPort")
public class EventProviderDelegate implements IEventProvider
{

    /** {@inheritDoc} */
    public void subscribe(String queue)
    {
        getProvider().subscribe(queue);
    }

    /** {@inheritDoc} */
    public void unsubscribe(String queue)
    {
        getProvider().unsubscribe(queue);
    }

    public List<Event> poll()
    {
        return getProvider().poll();
    }

    /**
     * This is an accessor to get the 'true' provider as a service.  If the bundle
     * has been restarted, this may return a different provider than previous
     * invocations.
     * 
     * @return the provider to which to delegate
     */
    private IEventProvider getProvider()
    {
        IEventProvider provider = EventsActivator.getEventProvider();
        if (provider == null)
        {
            throw new RuntimeException("EventsProvider unavailable."); //$NON-NLS-1$
        }

        return provider;
    }
}
