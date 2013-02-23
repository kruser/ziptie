package org.ziptie.nio.nioagent.datagram.tftp;

/**
 * ACK packet codec for TFTP clients requesting a write operation.  The block
 * number of the initial ACK packet coming from the server in response to the 
 * WRQ is 0.  
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class ClientBlocknumInitializer implements BlocknumInitializer
{
    // -- public methods
    public int initialBlockNum()
    {
        return 0;
    }

}
