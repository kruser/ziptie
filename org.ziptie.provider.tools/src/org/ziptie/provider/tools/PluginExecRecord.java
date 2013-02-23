package org.ziptie.provider.tools;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.provider.scheduler.ExecutionData;

/**
 * PluginExecRecord
 */
@XmlRootElement
@Entity(name = "PluginExecRecord")
@Table(name = "plugin_exec_record")
public class PluginExecRecord
{
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen",
                    table = "persistent_key_gen",
                    pkColumnName = "seq_name",
                    valueColumnName = "seq_value",
                    pkColumnValue = "Plugin_Exec_Record_seq",
                    initialValue = 1,
                    allocationSize = 1)
    @Column(name = "id")
    private int id;

    @Column(name = "format")
    private String outputFormat;

    @Column(name = "plugin_name")
    private String pluginName;

    @OneToOne
    @JoinColumn(name = "execution_id")
    private ExecutionData executionData;

    /**
     * Default constructor.
     */
    public PluginExecRecord()
    {
        // default constructor
    }

    /**
     * Get the internal execution record id.
     *
     * @return the id
     */
    @XmlTransient
    public int getId()
    {
        return id;
    }

    /**
     * Set the internal execution record id.
     *
     * @param id the id to set
     */
    public void setId(int id)
    {
        this.id = id;
    }

    /**
     * @return the outputFormat
     */
    public String getOutputFormat()
    {
        return outputFormat;
    }

    /**
     * @param outputFormat the outputFormat to set
     */
    public void setOutputFormat(String outputFormat)
    {
        this.outputFormat = outputFormat;
    }

    /**
     * Get the execution id.
     *
     * @return the execution id
     */
    public int getExecutionId()
    {
        return executionData.getId();
    }

    /**
     * THIS SETTER IS NOT SUPPORTED.
     */
    public void setExecutionId()
    {
        throw new UnsupportedOperationException("Setter for execution id is not supported."); //$NON-NLS-1$
    }

    /**
     * Get the name of the plugin that this execution record is for.
     *
     * @return the name of the plugin
     */
    public String getPluginName()
    {
        return pluginName;
    }

    /**
     * Set the name of the plugin that this execution record is for.
     *
     * @param pluginName the name of the plugin
     */
    public void setPluginName(String pluginName)
    {
        this.pluginName = pluginName;
    }

    /**
     * @return the executionData
     */
    @XmlTransient
    public ExecutionData getExecutionData()
    {
        return executionData;
    }

    /**
     * @param executionData the executionData to set
     */
    public void setExecutionData(ExecutionData executionData)
    {
        this.executionData = executionData;
    }
}
