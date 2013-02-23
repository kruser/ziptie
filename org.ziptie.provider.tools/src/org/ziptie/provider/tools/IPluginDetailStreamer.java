package org.ziptie.provider.tools;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * IPluginDetailStreamer
 */
public interface IPluginDetailStreamer
{
    /**
     * Implementers of this method should examine the attributes of the servlet
     * request and stream the appropriate detail to the response.
     *
     * @param req a servlet request
     * @param resp a servlet response
     * @throws ServletException thrown if an exception occurs
     * @throws IOException thrown if an exception occurs
     */
    void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException;
}
