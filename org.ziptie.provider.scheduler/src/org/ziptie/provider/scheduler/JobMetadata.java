package org.ziptie.provider.scheduler;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;

/**
 * JobMetadata
 */
@XmlAccessorType(XmlAccessType.FIELD)
public class JobMetadata
{
    private String jobName;
    private String jobGroup;
    private String jobType;
    private String jobDescription;

    /**
     * Default constructor.
     */
    public JobMetadata()
    {
        // default constructor.
    }

    /**
     * Get the Job group.
     *
     * @return the group name
     */
    public String getJobGroup()
    {
        return jobGroup;
    }

    /**
     * Set the Job group.
     *
     * @param jobGroup the group name
     */
    public void setJobGroup(String jobGroup)
    {
        this.jobGroup = jobGroup;
    }

    /**
     * Get the name of the Job.
     * 
     * @return the job name
     */
    public String getJobName()
    {
        return jobName;
    }

    /**
     * Set the name of the Job.
     *
     * @param jobName the name of the job
     */
    public void setJobName(String jobName)
    {
        this.jobName = jobName;
    }

    /**
     * Get the type of the Job.
     *
     * @return the job type
     */
    public String getJobType()
    {
        return jobType;
    }

    /**
     * Set the type of the Job.
     *
     * @param jobType the job type
     */
    public void setJobType(String jobType)
    {
        this.jobType = jobType;
    }
    
    /**
     * Get the description of the Job.
     *
     * @return the job description
     */
    public String getJobDescription()
    {
        return jobDescription;
    }

    /**
     * Set the description of the Job.
     *
     * @param jobType the description type
     */
    public void setJobDescription(String jobDescription)
    {
        this.jobDescription = jobDescription;
    }
}
