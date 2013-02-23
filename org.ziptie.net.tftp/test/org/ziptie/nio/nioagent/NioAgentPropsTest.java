package org.ziptie.nio.nioagent;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.NioAgentPropsImpl;

import junit.framework.TestCase;


public class NioAgentPropsTest extends TestCase implements SystemLogger.Injector
{

    // -- member fields
    private NioAgentPropsImpl nioAgentPropsImpl;

    // -- constructors
    public NioAgentPropsTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testPropertiesFile() throws Exception
    {
        String testValue = (String) nioAgentPropsImpl.props.get("props.test");
        assertEquals("foo", testValue);
    }

    // -- protected methods
    protected void setUp() throws Exception
    {
        nioAgentPropsImpl = (NioAgentPropsImpl) NioAgentPropsImpl.getInstance(logger);
    }

}
