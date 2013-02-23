package org.ziptie.provider.devices;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

/**
 * ISimpleDeviceSearch
 */
@WebService(name = "DeviceSearch", targetNamespace = "http://www.ziptie.org/server/devicesearch")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface ISimpleDeviceSearch
{
    /**
     * @param scheme The device resolution scheme.
     * @param query The scheme specific query.
     * @param pageData The page to retrieve.
     * @param sortColumn The column to sort by or <code>null</code>.
     * @param descending <code>true</code> for descending sort or <code>false</code> for ascending.
     * @return The requested page.
     */
    PageData search(@WebParam(name = "scheme") String scheme,
                    @WebParam(name = "query") String query,
                    @WebParam(name = "pageData") PageData pageData,
                    @WebParam(name = "sortColumn") String sortColumn,
                    @WebParam(name = "descending") boolean descending);
}
