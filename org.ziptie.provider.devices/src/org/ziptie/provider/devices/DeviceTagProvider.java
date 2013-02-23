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
 * 
 * Contributor(s):
 */
package org.ziptie.provider.devices;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.hibernate.Session;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.provider.devices.internal.DeviceProviderActivator;

/**
 * Provides persistence for device tags.
 */
@SuppressWarnings("nls")
public class DeviceTagProvider implements IDeviceTagProvider
{
    private static final String ATTR_TAG_ID = "tag_id";
    private static final String ATTR_TAG_LOWER = "tag_lower";
    private static final String ATTR_TAG = "tag";

    /**
     * Create the provider.
     */
    public DeviceTagProvider()
    {
    }

    /** {@inheritDoc} */
    public void addTag(String tag)
    {
        if (!doesTagExist(tag))
        {
            Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

            session.createSQLQuery("INSERT INTO tag (tag, tag_lower) VALUES (:tag, :tag_lower)")
                .setString(ATTR_TAG, tag)
                .setString(ATTR_TAG_LOWER, tag.toLowerCase())
                .executeUpdate();
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<String> getAllTags()
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        List<?> result = session.createSQLQuery("SELECT tag FROM tag ORDER BY tag").list(); //$NON-NLS-1$

        return (List<String>) result;
    }

    /** {@inheritDoc} */
    public void renameTag(String oldName, String newName)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        session.createSQLQuery("UPDATE tag t SET t.tag = :new, t.tag_lower = :new_lower WHERE t.tag_lower = :old_lower")
            .setString("new", newName)
            .setString("new_lower", newName.toLowerCase())
            .setString("old_lower", oldName.toLowerCase())
            .executeUpdate();
    }

    /** {@inheritDoc} */
    public void removeTag(String tag)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        // delete the tag, let cascade do it's magic.
        session.createSQLQuery("DELETE FROM tag t WHERE t.tag_lower = :tag_lower ")
            .setString(ATTR_TAG_LOWER, tag.toLowerCase())
            .executeUpdate();
    }

    /** {@inheritDoc} */
    public void tagDevices(String tag, String devicesCsv)
    {
        if (!doesTagExist(tag))
        {
            return;
        }

        LinkedList<Integer> ids = getDeviceIds(devicesCsv);
        if (ids.isEmpty())
        {
            return;
        }

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        List<?> existingIds = session.createSQLQuery("SELECT m.device_id "
                + "FROM device_tag m, tag t "
                + "WHERE t.tag_lower = :tag_lower " + "AND m.tag_id = t.tag_id "
                + "AND m.device_id IN (:ids) ")
            .setString(ATTR_TAG_LOWER, tag.toLowerCase())
            .setParameterList("ids", ids)
            .list();

        if (existingIds.isEmpty())
        {
            // If we don't make a list with _something_ in it, the NOT IN clause below fails
            List<Long> bogusList = new ArrayList<Long>();
            bogusList.add(new Long(-1));
            existingIds = bogusList;
        }

        session.createSQLQuery("INSERT INTO device_tag (tag_id, device_id) "
                + "SELECT t.tag_id, d.device_id "
                + "FROM tag t, device d "
                + "WHERE t.tag_lower = :tag_lower "
                + "AND d.device_id IN (:ids) "
                + "AND d.device_id NOT IN (:existing) ")
            .setString(ATTR_TAG_LOWER, tag.toLowerCase())
            .setParameterList("ids", ids)
            .setParameterList("existing", existingIds)
            .executeUpdate();
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<String> getIntersectionOfTags(String devicesCsv)
    {
        List<Integer> ids = getDeviceIds(devicesCsv);
        if (ids.isEmpty())
        {
            return new ArrayList<String>();
        }

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        return session.createSQLQuery("SELECT t.tag FROM tag t, "
                + "(SELECT tag_id FROM device_tag "
                + " WHERE device_id IN (:ids) "
                + " GROUP BY tag_id HAVING count(*) = :count) dt "
                + "WHERE dt.tag_id = t.tag_id")
            .setParameterList("ids", ids)
            .setInteger("count", ids.size())
            .list();
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<String> getUnionOfTags(String devicesCsv)
    {
        List<Integer> ids = getDeviceIds(devicesCsv);
        if (ids.isEmpty())
        {
            return new ArrayList<String>();
        }

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        return session.createSQLQuery("SELECT DISTINCT t.tag FROM tag t, device_tag m WHERE m.device_id IN (:ids) AND t.tag_id = m.tag_id")
            .setParameterList("ids", ids)
            .list();
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<String> getTags(String ipAddress, String managedNetwork)
    {
        String queryIp = NetworkAddressElf.toDatabaseString(ipAddress);
        String network = managedNetwork == null ? getDefaultManagedNetwork() : managedNetwork;

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        List<?> result = session.createSQLQuery("SELECT tag FROM tag t, device_tag m, device d "
                + "WHERE d.network = :network "
                + "AND d.ip_address = :ip "
                + "AND m.device_id = d.device_id "
                + "AND t.tag_id = m.tag_id ")
            .setString("network", network)
            .setString("ip", queryIp)
            .list();

        return (List<String>) result;
    }

    /** {@inheritDoc} */
    public void untagDevices(String tag, String devicesCsv)
    {
        LinkedList<Integer> ids = getDeviceIds(devicesCsv);
        if (ids.isEmpty())
        {
            return;
        }

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        // Get the tag ID for the tag.
        Integer tagId = (Integer) session.createSQLQuery("SELECT tag_id FROM tag WHERE tag_lower = :tag_lower")
            .setString(ATTR_TAG_LOWER, tag.toLowerCase())
            .uniqueResult();
        if (tagId == null)
        {
            return;
        }

        // Delete the mappings.
        session.createSQLQuery("DELETE FROM device_tag m "
                + "WHERE m.tag_id = :tag_id "
                + "AND m.device_id IN (:ids) ")
            .setInteger(ATTR_TAG_ID, tagId)
            .setParameterList("ids", ids)
            .executeUpdate();
    }

    private boolean doesTagExist(String tag)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        Integer tagId = (Integer) session.createSQLQuery("SELECT tag_id FROM tag WHERE tag_lower = :tag_lower")
            .setString(ATTR_TAG_LOWER, tag.toLowerCase())
            .uniqueResult();

        return tagId != null;
    }

    private LinkedList<Integer> getDeviceIds(String devicesCsv)
    {
        if (devicesCsv == null)
        {
            return new LinkedList<Integer>();
        }

        List<ZDeviceLite> devices = DeviceResolutionElf.resolveDevices("ipCsv", devicesCsv);

        LinkedList<Integer> deviceIds = new LinkedList<Integer>();
        for (ZDeviceLite deviceCore : devices)
        {
            deviceIds.add(deviceCore.getDeviceId());
        }

        return deviceIds;
    }

    private String getDefaultManagedNetwork()
    {
        return DeviceProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName();
    }
}
