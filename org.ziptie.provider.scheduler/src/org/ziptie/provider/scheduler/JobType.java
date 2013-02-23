package org.ziptie.provider.scheduler;

import javax.xml.bind.annotation.XmlTransient;

/**
 * JobType
 */
public class JobType
{
    private String typeName;
    private Class<?> jobClass;
    private String cudPermission;
    private String runPermission;

    /**
     * Default constructor.
     */
    public JobType()
    {
        // default constructor
    }

    /**
     * Constructor.
     *
     * @param name the type name of the job
     * @param cudPermission the permission, if any, required to create/update/delete this job
     * @param runPermission the permission, if any, required to execute this job
     */
    public JobType(String name, String cudPermission, String runPermission)
    {
        this.typeName = name;
        this.cudPermission = cudPermission;
        this.runPermission = runPermission;
    }

    /**
     * Get the job type name.
     *
     * @return the job type name
     */
    public String getTypeName()
    {
        return typeName;
    }

    /**
     * Set the job type name.
     *
     * @param typeName the job type name
     */
    public void setTypeName(String typeName)
    {
        this.typeName = typeName;
    }

    /**
     * Get the permission required to create/update/delete this job type.
     *
     * @return the permission required to create/update/delete this job type,
     *   may be null
     */
    public String getCudPermission()
    {
        return cudPermission;
    }

    /**
     * Set the permission required to create/update/delete this job type.
     *
     * @param permission the permission required to create/update/delete this job
     *    type
     */
    public void setCudPermission(String permission)
    {
        this.cudPermission = permission;
    }

    /**
     * Get the permission required to run this job type.
     *
     * @return the permission required to run this job type, may be null
     */
    public String getRunPermission()
    {
        return runPermission;
    }

    /**
     * Set the permission required to run this job type.
     *
     * @param permission the permission required to run this job type, may be null
     */
    public void setRunPermission(String permission)
    {
        this.runPermission = permission;
    }

    /**
     * Get the implementation class of the job.
     *
     * @return the implementation class of the job
     */
    @XmlTransient
    public Class<?> getJobClass()
    {
        return jobClass;
    }

    /**
     * Set the implementation class of the job.
     *
     * @param jobClass the implementation class of the job
     */
    public void setJobClass(Class<?> jobClass)
    {
        this.jobClass = jobClass;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return typeName;
    }
}
