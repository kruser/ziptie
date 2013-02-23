package org.ziptie.discovery;


/**
 * @author rkruse
 */
public class UnitTestDiscEventHandler implements IDiscoveryEventHandler
{
    /**
     * {@inheritDoc}
     */
    public void handleEvent(DiscoveryEvent discoveryEvent)
    {
        if (discoveryEvent.isGoodEvent())
        {
            System.out.println("Received Good DiscoveryEvent: " + discoveryEvent);
        }
    }
}
