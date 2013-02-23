package org.ziptie.provider.devices;

/**
 * An InventoryNode represents the shallow information for a device or folder in the inventory
 * tree.
 * 
 * Example values of the fields
 *   parent: devices/cisco
 *   label: 10.100.4.8 - cisco2610-LAB.eclyptic.com
 *   isFolder: false
 * 
 */
public class InventoryNode
{
    private final String parent;
    private final String label;
    private final boolean isFolder;

    /**
     * @param parent the parent
     * @param label the label
     * @param isFolder true if this is a folder
     */
    public InventoryNode(final String parent, final String label, final boolean isFolder)
    {
        this.parent = parent;
        this.label = label;
        this.isFolder = isFolder;
    }

    /**
     * @return the isFolder
     */
    public boolean isFolder()
    {
        return isFolder;
    }

    /**
     * @return the label
     */
    public String getLabel()
    {
        return label;
    }

    /**
     * @return the parent
     */
    public String getParent()
    {
        return parent;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return String.format("{parent:%s,label:%s,isFolder:%s}", parent, label, isFolder); //$NON-NLS-1$
    }

}
