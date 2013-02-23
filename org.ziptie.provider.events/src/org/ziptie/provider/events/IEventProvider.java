package org.ziptie.provider.events;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

/**
 * IEventProvider
 */
@WebService(name = "Events", targetNamespace = "http://www.ziptie.org/server/events")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IEventProvider
{
    void subscribe(@WebParam(name = "queue") String queue);

    void unsubscribe(@WebParam(name = "queue") String queue);

    List<Event> poll();
}
