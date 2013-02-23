package org.ziptie.provider.configstore;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Restrictions;
import org.mozilla.jss.util.Base64OutputStream;
import org.ziptie.provider.configstore.internal.ConfigStoreActivator;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.provider.devices.ZDeviceCore;

/**
 * ConfigStore2
 */
public class ConfigStore implements IConfigStore
{
    private static final String TEXT = "text"; //$NON-NLS-1$

    private static final Logger LOGGER = Logger.getLogger(ConfigStore.class);

    private static final String ASSOCID_FORMAT = "associd%d"; //$NON-NLS-1$

    private static final String ADDED = "A"; //$NON-NLS-1$
    private static final String DELETED = "D"; //$NON-NLS-1$
    private static final String MODIFIED = "M"; //$NON-NLS-1$

    private static final String FAILED_TO_CLOSE_CONNECTION = "Failed to close connection."; //$NON-NLS-1$
    private static final int BUFFER_SIZE = 4096;

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public List<ChangeLog> retrieveChangeLog(String ipAddress, String managedNetwork)
    {
        IDeviceProvider deviceProvider = ConfigStoreActivator.getDeviceProvider();
        ZDeviceCore device = deviceProvider.getDevice(ipAddress, managedNetwork);

        List<ChangeLog> changeLog = new ArrayList<ChangeLog>();
        DataSource dataSource = ConfigStoreActivator.getDataSource();
        Connection connection = null;
        try
        {
            connection = dataSource.getConnection();
            PreparedStatement stmt = connection.prepareStatement("SELECT author, revision_time, prev_revision_time, path, mime_type, type, size FROM "
                    + "revisions WHERE association_id=? ORDER BY revision_time DESC");
            stmt.setInt(1, device.getDeviceId());

            Timestamp currentTS = null;
            ChangeLog currentCL = null;
            ResultSet rs = stmt.executeQuery();
            while (rs.next())
            {
                Timestamp revisionTime = rs.getTimestamp(2);
                if (!revisionTime.equals(currentTS))
                {
                    currentTS = revisionTime;
                    currentCL = new ChangeLog();
                    currentCL.setTimestamp(revisionTime);
                    currentCL.setChanges(new ArrayList<Change>());
                    changeLog.add(currentCL);
                }
                Change change = new Change();
                change.setAuthor(rs.getString(1));
                change.setPreviousChange(rs.getTimestamp(3));
                change.setPath(rs.getString(4));
                change.setMimeType(rs.getString(5));
                change.setType(rs.getString(6).charAt(0));
                change.setSize(rs.getLong(7));
                currentCL.getChanges().add(change);
            }
            rs.close();
            stmt.close();
        }
        catch (SQLException e)
        {
            LOGGER.error("Error retrieving a change log for device " + device, e);
        }
        finally
        {
            if (connection != null)
            {
                try
                {
                    connection.close();
                }
                catch (SQLException e)
                {
                    LOGGER.error(FAILED_TO_CLOSE_CONNECTION, e);
                }
            }
        }

        return changeLog;
    }

    /** {@inheritDoc} */
    public List<RevisionInfo> retrieveCurrentRevisionInfo(String ipAddress, String managedNetwork)
    {
        IDeviceProvider deviceProvider = ConfigStoreActivator.getDeviceProvider();
        ZDeviceCore device = deviceProvider.getDevice(ipAddress, managedNetwork);

        return getLatestRevisionInfos(device.getDeviceId(), true);
    }

    /** {@inheritDoc} */
    public Revision retrieveRevision(String ipAddress, String managedNetwork, String configPath, Date timestamp)
    {
        return retrieveRevision(ipAddress, managedNetwork, configPath, timestamp, false);
    }

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    private Revision retrieveRevision(String ipAddress, String managedNetwork, String configPath, Date timestamp, boolean retainFile)
    {
        IDeviceProvider deviceProvider = ConfigStoreActivator.getDeviceProvider();
        ZDeviceCore device = deviceProvider.getDevice(ipAddress, managedNetwork);

        List<File> tmpFiles = new ArrayList<File>();

        Revision revision = null;
        DataSource dataSource = ConfigStoreActivator.getDataSource();
        Connection connection = null;
        try
        {
            connection = dataSource.getConnection();
            Timestamp ts = null;
            PreparedStatement stmt = null;
            if (timestamp != null)
            {
                ts = new Timestamp(timestamp.getTime());
                stmt = connection.prepareStatement("SELECT author, revision_time, path, mime_type, size, revision FROM "
                        + "revisions WHERE association_id=? AND revision_time >= ? AND path=? ORDER BY revision_time DESC");
                stmt.setTimestamp(2, ts);
            }
            else
            {
                stmt = connection.prepareStatement("SELECT author, revision_time, path, mime_type, size, revision FROM "
                        + "revisions WHERE association_id=? AND head=? AND path=? ORDER BY revision_time DESC");
                stmt.setBoolean(2, true);
            }
            stmt.setInt(1, device.getDeviceId());
            stmt.setString(3, configPath);

            File lastFile = null;
            ResultSet rs = stmt.executeQuery();
            while (rs.next())
            {
                Timestamp revTS = rs.getTimestamp(2);
                if (ts == null || revTS.equals(ts))
                {
                    revision = new Revision();
                    revision.setAuthor(rs.getString(1));
                    revision.setLastChanged(revTS);
                    revision.setPath(rs.getString(3));
                    revision.setMimeType(rs.getString(4));
                    revision.setSize((int) rs.getLong(5));
                }

                File patch = File.createTempFile(String.format(ASSOCID_FORMAT, device.getDeviceId()), null);
                patch.deleteOnExit();
                tmpFiles.add(patch);
                OutputStream fos = new BufferedOutputStream(new FileOutputStream(patch), BUFFER_SIZE);

                InputStream content = rs.getBinaryStream(6);
                byte[] buffer = new byte[BUFFER_SIZE];
                while (true)
                {
                    int i = content.read(buffer);
                    if (i <= 0)
                    {
                        break;
                    }
                    fos.write(buffer, 0, i);
                }
                content.close();
                fos.close();

                // If it's not the first file, apply a reverse patch
                if (lastFile != null)
                {
                    File tmpFile = File.createTempFile(String.format(ASSOCID_FORMAT, device.getDeviceId()), ".patched");
                    tmpFiles.add(tmpFile);

                    ProcessBuilder pb = new ProcessBuilder();
                    pb.directory(patch.getParentFile());
                    String diffType = (rs.getString(4).startsWith(TEXT) ? "--patch" : "--bpatch");
                    pb.command(ConfigStoreActivator.getXdiffPath(), diffType, lastFile.getAbsolutePath(), patch.getAbsolutePath(), tmpFile.getAbsolutePath());
                    if (LOGGER.isTraceEnabled())
                    {
                        LOGGER.trace(String.format("xdiff %s %s %s %s", diffType, lastFile.getAbsolutePath(), patch.getAbsolutePath(),
                                                   tmpFile.getAbsolutePath()));
                    }
                    Process process = pb.start();
                    process.waitFor();
                    lastFile = tmpFile;
                }
                else
                {
                    lastFile = patch;
                }
            }
            rs.close();
            stmt.close();

            if (revision == null)
            {
                return null;
            }

            revision.setFile(lastFile);
            if (lastFile != null && !retainFile)
            {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                OutputStream os = new Base64OutputStream(new PrintStream(baos));

                InputStream content = new BufferedInputStream(new FileInputStream(lastFile));
                byte[] buffer = new byte[BUFFER_SIZE];
                while (true)
                {
                    int i = content.read(buffer);
                    if (i <= 0)
                    {
                        break;
                    }
                    os.write(buffer, 0, i);
                }
                content.close();
                os.close();

                revision.setContent(baos.toString());
            }
        }
        catch (Exception e)
        {
            LOGGER.error("Error retrieving a revision for device " + device, e);
        }
        finally
        {
            // Delete the last revisions as temporary files
            for (File tmpFile : tmpFiles)
            {
                if (retainFile && tmpFile.equals(revision.getFile()))
                {
                    continue;
                }

                tmpFile.delete();
                if (LOGGER.isTraceEnabled())
                {
                    LOGGER.trace(String.format("Deleted tmp file %s", tmpFile.getName()));
                }
            }

            if (connection != null)
            {
                try
                {
                    connection.close();
                }
                catch (SQLException e)
                {
                    LOGGER.error(FAILED_TO_CLOSE_CONNECTION, e);
                }
            }
        }

        return revision;
    }

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public String retrieveRevisionUnifiedDiff(String ipAddress, String managedNetwork, String configPath, Date timestamp1, Date timestamp2)
    {
        Revision revision1 = retrieveRevision(ipAddress, managedNetwork, configPath, timestamp1, true);
        Revision revision2 = retrieveRevision(ipAddress, managedNetwork, configPath, timestamp2, true);

        if (!revision1.getMimeType().startsWith(TEXT))
        {
            return null;
        }

        File diff = null;
        try
        {
            diff = File.createTempFile(ASSOCID_FORMAT, ".diff");
            ProcessBuilder pb = new ProcessBuilder();
            pb.directory(revision1.getFile().getParentFile());
            pb.command(ConfigStoreActivator.getXdiffPath(), "--diff", revision1.getFile().getAbsolutePath(), revision2.getFile().getAbsolutePath(),
                       diff.getAbsolutePath());
            Process process = pb.start();
            process.waitFor();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            InputStream content = new BufferedInputStream(new FileInputStream(diff));
            byte[] buffer = new byte[BUFFER_SIZE];
            while (true)
            {
                int i = content.read(buffer);
                if (i <= 0)
                {
                    break;
                }
                baos.write(buffer, 0, i);
            }
            content.close();
            baos.close();

            return baos.toString("UTF-8");
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            if (diff != null)
            {
                diff.delete();
            }
            revision1.getFile().delete();
            revision2.getFile().delete();
        }
    }

    /**
     * A fairly inefficient method of getting a range of change logs.  Should be generalized
     * and then utilized by the public retrieveChangeLog() -- not the other way around (as it
     * is here).
     *
     * @param device a ZDeviceCore
     * @param start the start date of the change range
     * @param end the end date of the change range
     * @return a (possibly empty) list of change logs
     */
    public List<ChangeLog> retrieveChangeLog(ZDeviceCore device, Date start, Date end)
    {
        List<ChangeLog> partialChangeLog = new ArrayList<ChangeLog>();

        List<ChangeLog> fullChangeLog = retrieveChangeLog(device.getIpAddress(), device.getManagedNetwork());
        for (ChangeLog changeLog : fullChangeLog)
        {
            Date ts = changeLog.getTimestamp();
            if ((ts.equals(start) || ts.after(start)) && (ts.equals(end) || ts.before(end)))
            {
                partialChangeLog.add(changeLog);
            }
        }

        return partialChangeLog;
    }

    /**
     * Update the database with the latest revision.
     *
     * @param device a ZDeviceCore
     * @param configs the ConfigHolder objects
     */
    @SuppressWarnings("nls")
    public void updateVersions(ZDeviceCore device, List<ConfigHolder> configs)
    {
        int associationId = device.getDeviceId();

        DataSource dataSource = ConfigStoreActivator.getDataSource();
        Connection connection = null;

        List<ConfigHolder> notificationList = new ArrayList<ConfigHolder>();
        List<File> tmpFiles = new ArrayList<File>();
        try
        {
            Map<String, RevisionInfo> quikMap = new HashMap<String, RevisionInfo>();
            for (RevisionInfo info : getLatestRevisionInfos(associationId, false))
            {
                quikMap.put(info.getPath(), info);
            }

            // Get the last revisions as temporary files and set them into the holders
            for (ConfigHolder holder : configs)
            {
                RevisionInfo revisionInfo = quikMap.get(holder.getFullName());
                if (revisionInfo != null && revisionInfo.getCrc32() != holder.getChecksum().getValue() && !DELETED.equals(revisionInfo.getType()))
                {
                    File tmpFile = getLatestRevisionFile(associationId, holder.getFullName());
                    holder.setLastRevisionFile(tmpFile);
                    tmpFiles.add(tmpFile);
                    if (LOGGER.isTraceEnabled())
                    {
                        LOGGER.trace(String.format("For associd %d created tmp file %s", associationId, tmpFile.getName()));
                    }
                }
            }

            connection = dataSource.getConnection();
            PreparedStatement insert = connection.prepareStatement("INSERT INTO revisions "
                    + "(association_id, author, revision_time, prev_revision_time, path, mime_type, type, head, crc32, size, revision)"
                    + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

            PreparedStatement update = connection.prepareStatement("UPDATE revisions SET head=?, revision=? " + "WHERE association_id=? AND head=? AND path=?");

            ProcessBuilder pb = new ProcessBuilder();
            Calendar calendar = Calendar.getInstance();
            calendar.set(Calendar.MILLISECOND, 0);
            boolean doInsert = false;
            boolean doUpdate = false;
            for (ConfigHolder holder : configs)
            {
                holder.setTimestamp(calendar.getTime());

                File newConfig = holder.getConfigFile();
                String relativePath = holder.getFullName();

                RevisionInfo revisionInfo = quikMap.remove(relativePath);
                if (revisionInfo != null)
                {
                    if (revisionInfo.getCrc32() == holder.getChecksum().getValue())
                    {
                        continue;
                    }

                    holder.setPreviousChange(revisionInfo.getLastChanged());
                }

                if (revisionInfo != null && !DELETED.equals(revisionInfo.getType()) && holder.getLastRevisionFile() != null)
                {
                    holder.setType(MODIFIED); // It's a 'M'odification to an existing config

                    File diffFile = File.createTempFile(newConfig.getName(), ".diff");
                    tmpFiles.add(diffFile);

                    String diffType = (holder.getMediaType().startsWith(TEXT) ? "--diff" : "--bdiff");
                    pb.directory(newConfig.getParentFile());
                    pb.command(ConfigStoreActivator.getXdiffPath(), diffType, newConfig.getAbsolutePath(), holder.getLastRevisionFile().getAbsolutePath(),
                               diffFile.getAbsolutePath());
                    if (LOGGER.isTraceEnabled())
                    {
                        LOGGER.trace(String.format("xdiff %s %s %s", newConfig.getAbsolutePath(), holder.getLastRevisionFile().getAbsolutePath(),
                                                   diffFile.getAbsolutePath()));
                    }
                    Process process = pb.start();
                    process.waitFor();
                    if (process.exitValue() != 0)
                    {
                        LOGGER.warn("xdiff exited with non-zero exit code.");
                    }

                    if (diffFile.length() == 0)
                    {
                        continue;
                    }

                    // Replace the old full config with just the backward diff
                    update.setBoolean(1, false);
                    update.setBinaryStream(2, new BufferedInputStream(new FileInputStream(diffFile), BUFFER_SIZE), (int) diffFile.length());
                    update.setInt(3, associationId);
                    update.setBoolean(4, true);
                    update.setString(5, relativePath);
                    update.addBatch();
                    doUpdate = true;
                }
                else
                {
                    holder.setType(ADDED); // It's an 'A'ddition to the repository
                }

                notificationList.add(holder);

                LOGGER.trace(String.format("Associd(%d) %s", associationId, relativePath));
                insert.setInt(1, associationId);
                insert.setString(2, "author");
                insert.setTimestamp(3, new Timestamp(calendar.getTimeInMillis()));
                insert.setTimestamp(4, (holder.getPreviousChange() == null ? null : new Timestamp(holder.getPreviousChange().getTime())));
                insert.setString(5, relativePath);
                insert.setString(6, holder.getMediaType());
                insert.setString(7, holder.getType());
                insert.setBoolean(8, true);
                insert.setLong(9, holder.getChecksum().getValue());
                if (newConfig.length() == 0)
                {
                    insert.setLong(10, 0);
                    insert.setNull(11, Types.BLOB);
                }
                else
                {
                    insert.setLong(10, newConfig.length());
                    insert.setBinaryStream(11, new BufferedInputStream(new FileInputStream(newConfig), BUFFER_SIZE), (int) newConfig.length());
                }
                insert.addBatch();
                doInsert = true;
            }

            // Any revisions left in the map are deletes
            insert.clearParameters();
            for (RevisionInfo info : quikMap.values())
            {
                info.setType(DELETED);
                notificationList.add(revisionInfo2ConfigHolder(info));

                insert.setInt(1, associationId);
                insert.setString(2, "author");
                insert.setTimestamp(3, new Timestamp(calendar.getTimeInMillis()));
                insert.setTimestamp(4, new Timestamp(info.getLastChanged().getTime()));
                insert.setString(5, info.getPath());
                insert.setString(6, info.getMimeType());
                insert.setString(7, DELETED);
                insert.setBoolean(8, true);
                insert.setLong(9, 0);
                insert.setLong(10, 0);
                insert.setNull(11, Types.BLOB);
                insert.addBatch();
                doInsert = true;
            }

            if (doUpdate)
            {
                update.executeBatch();
            }
            if (doInsert)
            {
                insert.executeBatch();
            }

            update.close();
            insert.close();

            if (notificationList.size() > 0)
            {
                // TODO brettw fix notifiers
                // ConfigStoreActivator.getRevisionNotifier().notifyRevisionObservers(device, notificationList);
                ConfigIndexerRevisionObserver observer = new ConfigIndexerRevisionObserver();
                observer.revisionChange(device, configs);
            }

            connection.close();
        }
        catch (BatchUpdateException bue)
        {
            LOGGER.error("Exception updating the revision store", bue);
            LOGGER.error("  getNextException() reports", bue.getNextException());
        }
        catch (Exception e)
        {
            LOGGER.error("Exception updating the revision store", e);
        }
        finally
        {
            // Delete the last revisions as temporary files
            for (File tmpFile : tmpFiles)
            {
                tmpFile.delete();
                if (LOGGER.isTraceEnabled())
                {
                    LOGGER.trace(String.format("Deleted tmp file %s", tmpFile.getName()));
                }
            }
        }
    }

    /**
     * Delete all history for a device from the inventory.
     *
     * @param device the device whose history to delete
     */
    public void deleteRevisionHistory(ZDeviceCore device)
    {
        // no-op
    }

    @SuppressWarnings( { "nls", "unchecked" })
    private List<RevisionInfo> getLatestRevisionInfos(int associationId, boolean excludeDeleted)
    {
        try
        {
            Session session = ConfigStoreActivator.getSessionFactory().getCurrentSession();

            Criteria criteria = session.createCriteria(RevisionInfo.class);
            criteria.add(Restrictions.eq("associationId", associationId));
            criteria.add(Restrictions.eq("isHead", Boolean.TRUE));
            if (excludeDeleted)
            {
                criteria.add(Restrictions.ne("type", DELETED));
            }

            return (List<RevisionInfo>) criteria.list();
        }
        catch (RuntimeException e)
        {
            LOGGER.error(e);
            throw e;
        }
    }

    @SuppressWarnings("nls")
    private File getLatestRevisionFile(int associationId, String configPath)
    {
        File latestConfig = null;

        DataSource dataSource = ConfigStoreActivator.getDataSource();
        Connection connection = null;
        try
        {
            connection = dataSource.getConnection();
            PreparedStatement stmt = connection.prepareStatement("SELECT revision FROM revisions WHERE association_id=? AND head=? AND path=?");
            stmt.setInt(1, associationId);
            stmt.setBoolean(2, true);
            stmt.setString(3, configPath);
            ResultSet rs = stmt.executeQuery();
            if (rs.next())
            {
                latestConfig = File.createTempFile(String.format(ASSOCID_FORMAT, associationId), null);
                latestConfig.deleteOnExit();

                OutputStream fos = new BufferedOutputStream(new FileOutputStream(latestConfig), BUFFER_SIZE);

                InputStream content = rs.getBinaryStream(1);
                byte[] buffer = new byte[BUFFER_SIZE];
                while (true)
                {
                    int i = content.read(buffer);
                    if (i <= 0)
                    {
                        break;
                    }
                    fos.write(buffer, 0, i);
                }
                content.close();
                fos.close();
            }
            rs.close();
            stmt.close();
        }
        catch (Exception e)
        {
            LOGGER.error("Error retrieving latest revision " + associationId, e);
        }
        finally
        {
            if (connection != null)
            {
                try
                {
                    connection.close();
                }
                catch (SQLException e)
                {
                    LOGGER.error(FAILED_TO_CLOSE_CONNECTION, e);
                }
            }
        }

        return latestConfig;
    }

    private ConfigHolder revisionInfo2ConfigHolder(RevisionInfo info)
    {
        ConfigHolder holder = new ConfigHolder(info.getFile(), info.getPath(), info.getMimeType());
        holder.setType(info.getType());
        holder.setTimestamp(info.getLastChanged());

        return holder;
    }
}
