package org.ziptie.provider.scheduler;

import org.quartz.JobDetail;

/**
 * ISecureJob
 */
public interface ISecureJob
{
    /**
     * Validate whether the invoking user is allowed to create/update/delete this job.
     *
     * @param jobData the JobData describing the job to be created/updated/deleted
     * @return true if the user is allowed, false if they are not
     */
    boolean validateCudOperation(JobData jobData);

    /**
     * Validate whether the invoking user is allowed to run this job.
     *
     * @param jobDetail the JobDetail describing the job to be run
     * @return true if the user is allowed, false if they are not
     */
    boolean validateRunOperation(JobDetail jobDetail);
}
