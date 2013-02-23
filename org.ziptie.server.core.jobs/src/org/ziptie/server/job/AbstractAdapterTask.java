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
package org.ziptie.server.job;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.xml.ws.soap.SOAPFaultException;

import org.apache.log4j.Logger;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.client.ConnectionPath;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolNames;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.dispatcher.ITask;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.job.AdapterException.ErrorCode;
import org.ziptie.server.job.backup.ConnectionPathElf;
import org.ziptie.server.job.backup.CredentialElf;
import org.ziptie.server.job.internal.CoreJobsActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * The {@link AbstractAdapterTask} class provides a partial implementation of the {@link ITask} interface in order
 * to provide support for tasks that are meant to execute various adapter operations.  It provides mechanisms for retrieving
 * all of the protocol and credential information needed to connect to a device for an adapter operation.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public abstract class AbstractAdapterTask implements ITask
{
    private static final Logger LOGGER = Logger.getLogger(AbstractAdapterTask.class);

    private ZDeviceCore device;
    private String operationName;
    private ProtocolSet[] protocolSets;
    private List<CredentialSet> credentialSets;
    private Set<ProtocolNames> failedProtocols;
    private int protocolCounter;
    private int credentialsCounter;
    private Exception lastExceptionEncountered;

    /**
     * Creates a new {@link AbstractAdapterTask} instance and associates the specified {@link ZDeviceCore} object with it.
     * 
     * @param operationName The name of the operation that this task will execute.
     * @param device The device to be associated with this {@link AbstractAdapterTask} instance.
     */
    public AbstractAdapterTask(String operationName, ZDeviceCore device)
    {
        this.operationName = operationName;
        this.device = device;
    }

    /** {@inheritDoc} */
    public Outcome execute() throws Exception
    {
        try
        {
            String adapterId = device.getAdapterId();
            if (adapterId == null)
            {
                throw new IllegalStateException(Messages.bind(Messages.AbstractAdapterTask_noAdapter, device.getIpAddress(), device.getManagedNetwork()));
            }

            // Resolve the credentials and protocols for the device
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            try
            {
                resolveCredentialsAndProtocols();
            }
            finally
            {
                if (ownTransaction)
                {
                    TransactionElf.commit();
                }
            }

            failedProtocols = new HashSet<ProtocolNames>();

            while ((protocolCounter < protocolSets.length) && (credentialsCounter < credentialSets.size()))
            {
                try
                {
                    ProtocolSet protocolSet = protocolSets[protocolCounter];
                    if (!protocolsPass(protocolSet, failedProtocols))
                    {
                        protocolCounter++;
                        continue;
                    }

                    CredentialSet credentialSet = credentialSets.get(credentialsCounter);

                    // Construct the SOAP-compatible connection path object
                    ConnectionPath connectionPath = ConnectionPathElf.generateSoapConnectionPath(device.getIpAddress(), protocolSet, credentialSet);

                    try
                    {
                        // Perform the actual task
                        return performTask(credentialSet, protocolSet, connectionPath);
                    }
                    catch (SOAPFaultException e)
                    {
                        String message = PerlErrorParserElf.getMessage(e);

                        // Parse out the remote exception into a more useful exception.  This is done by analyzing the error
                        // thrown from Perl and creating an Exception that is mapped to it
                        AdapterException adapterException = PerlErrorParserElf.parse(message);
                        if (adapterException == null)
                        {
                            throw new Exception(message, e);
                        }

                        // Analyze the exception that we just determined and perform any special retry logic
                        handleRemoteException(adapterException);

                        // Store the last exception encountered.  This is needed in case our retry logic
                        // fails and we want to throw an exception with the proper error.
                        lastExceptionEncountered = adapterException;
                    }
                }
                finally
                {
                    if (LOGGER.isDebugEnabled())
                    {
                        String[] errorMessageInput = new String[] { operationName, device.getIpAddress(), device.getManagedNetwork() };
                        LOGGER.debug(Messages.bind(Messages.AbstractAdapterTask_exit, errorMessageInput));
                    }
                }
            }
        }
        catch (Exception e)
        {
            lastExceptionEncountered = e;
        }

        // If there was an exception encountered, then throw it rather than simply failing.
        // This will mark the outcome of the backup task as "EXCEPTION" and log the exception that occurred.
        if (lastExceptionEncountered != null)
        {
            // If the job was canceled, eat the exception
            if (CoreJobsActivator.getOperationManager().isCanceled(this))
            {
                return Outcome.CANCELLED;
            }

            String[] errorMessageInput = new String[] { operationName, device.getIpAddress(), device.getManagedNetwork() };
            LOGGER.debug(Messages.bind(Messages.AbstractAdapterTask_exception, errorMessageInput));
            throw lastExceptionEncountered;
        }

        return Outcome.FAILURE;
    }

    /**
     * Retrieves the device that will be communicated with during this restore task.
     * 
     * @return The device.
     */
    public ZDeviceCore getDevice()
    {
        return device;
    }

    /** {@inheritDoc} */
    public Object getLockObject()
    {
        return device;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return device.toString();
    }

    // ----------------------------------------------------------------------
    //                     P R O T E C T E D  M E T H O D S
    // ----------------------------------------------------------------------

    /**
     * Performs adapter operation specific functionality for the task.
     * 
     * @param credentialSet The current credential set to use when connecting to the device.
     * @param protocolSet The current protocol set to use when connecting to the device.
     * @param connectionPath The connection path used to connect to the device.
     * @return A successful outcome.
     * @throws Exception Any exception that might be encountered during the adapter operation.
     */
    protected abstract Outcome performTask(CredentialSet credentialSet, ProtocolSet protocolSet, ConnectionPath connectionPath) throws Exception;

    /**
     * Resolves all of the credentials and protocols that can be used for the specified operation.
     */
    protected void resolveCredentialsAndProtocols() throws Exception
    {
        protocolSets = CredentialElf.calculateProtocolSets(device, operationName).toArray(new ProtocolSet[0]);

        // Calculate the credential sets to use.  Make sure not to include any stale credentials
        credentialSets = CredentialElf.calculateCredentialSets(device);
    }

    /**
     * Verifies that the given {@link ProtocolSet} doesn't have any protocols that have previously failed.
     *
     * @param protocolSet the protocol set to verify 
     * @param failures the set of previously failed protocols
     * @return true if the protocol set didn't have any previously failed protocols, false otherwise
     */
    protected boolean protocolsPass(ProtocolSet protocolSet, Set<ProtocolNames> failures)
    {
        for (ProtocolNames failedProt : failures)
        {
            for (Protocol protocol : protocolSet.getProtocols())
            {
                if (failedProt.name().equals(protocol.getName()))
                {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Performs any special logic in regards to credentials and protocols if an exception
     * has been thrown remotely from performing a backup operation against a device with a ZipTie
     * adapter.
     * 
     * @param remoteException The remote exception that was thrown during the process of a backup adapter operation.
     * @throws Exception if the remote exception being analyzed does not indicate that any special logic should be
     * performed.
     */
    protected void handleRemoteException(AdapterException remoteException) throws Exception
    {
        ErrorCode errorCode = remoteException.getErrorCode();
        if (errorCode.isProtocolError())
        {
            if (errorCode.equals(ErrorCode.HTTP_ERROR))
            {
                markHttpProtocolsAsFailed();
            }
            else
            {
                failedProtocols.add(errorCode.getProtocol());
            }
            protocolCounter++;
            CoreJobsActivator.getCredentialsProvider().markDeviceToProtocolMappingAsStale(Integer.toString(device.getDeviceId()));
            return;
        }
        else if (errorCode.equals(ErrorCode.INVALID_CREDENTIALS) || errorCode.equals(ErrorCode.INSUFFICIENT_PRIVILEGE))
        {
            // Try the next CredentialSet
            credentialsCounter++;
            CoreJobsActivator.getCredentialsProvider().markDeviceToCredentialMappingAsStale(Integer.toString(device.getDeviceId()));
            return;
        }
        throw remoteException;
    }

    // ----------------------------------------------------------------------
    //                     P R I V A T E  M E T H O D S
    // ----------------------------------------------------------------------

    /**
     * Iterates through the current protocol set that is being used and marks all HTTP protocols
     * as failing.
     */
    private void markHttpProtocolsAsFailed()
    {
        for (Protocol prot : protocolSets[protocolCounter].getProtocols())
        {
            if (prot.getName().equals(ProtocolNames.HTTP.name()))
            {
                failedProtocols.add(ProtocolNames.HTTP);
                break;
            }
            else if (prot.getName().equals(ProtocolNames.HTTPS.name()))
            {
                failedProtocols.add(ProtocolNames.HTTPS);
                break;
            }
        }
    }
}
