package org.ziptie.reports.inventory;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import org.eclipse.birt.report.engine.api.script.IReportContext;
import org.eclipse.birt.report.engine.api.script.IUpdatableDataSetRow;
import org.eclipse.birt.report.engine.api.script.ScriptException;
import org.eclipse.birt.report.engine.api.script.eventadapter.ScriptedDataSetEventAdapter;
import org.eclipse.birt.report.engine.api.script.instance.IDataSetInstance;
import org.ziptie.provider.configstore.Change;
import org.ziptie.provider.configstore.ChangeLog;
import org.ziptie.provider.configstore.ConfigStore;
import org.ziptie.provider.devices.ServerDeviceElf;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.reports.inventory.internal.ReportsActivator;

/**
 * ConfigChangeReport.
 */
public class ConfigChangeDataset extends ScriptedDataSetEventAdapter
{
    private static final int ONE_WEEK = 7;
    private static final int ONE_DAY = 24;
    private static final String DEVICE_COLUMN = "device"; //$NON-NLS-1$
    private static final String PATH_COLUMN = "path"; //$NON-NLS-1$
    private static final String TIMESTAMP_COLUMN = "timestamp"; //$NON-NLS-1$
    private static final String UNIFIED_DIFF_COLUMN = "unified_diff"; //$NON-NLS-1$

    private static final String TIMESTAMP_FORMAT = "yyyy-MM-dd'T'HH:mm:ssZ"; //$NON-NLS-1$
    private static final String TIMESTAMP_FORMAT_OLD = "yyyy-MM-dd HH:mm Z"; //$NON-NLS-1$

    private ConfigStore configStore;
    private List<ZDeviceLite> devices;
    private Date startRev;
    private Date endRev;

    private List<ChangeLog> changeLogs;
    private List<Change> changes;
    private int deviceCursor;
    private int changeLogCursor;
    private int configCursor;

    private Date startTime;

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    @Override
    public void afterOpen(IDataSetInstance dataSet, IReportContext reportContext)
    {
        devices = (List<ZDeviceLite>) reportContext.getParameterValue("zdevicelites"); //$NON-NLS-1$

        this.configStore = (ConfigStore) ReportsActivator.getConfigStore();
        try
        {
            SimpleDateFormat formatter = new SimpleDateFormat(TIMESTAMP_FORMAT);
            SimpleDateFormat formatterOld = new SimpleDateFormat(TIMESTAMP_FORMAT_OLD);
            String start = null;
            String end = null;

            String rangeType = (String) reportContext.getParameterValue("input.range_type"); //$NON-NLS-1$
            if (rangeType.contains("24")) //$NON-NLS-1$
            {
                Date startDate = new Date();
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(startDate);
                calendar.add(Calendar.HOUR, -ONE_DAY);
                start = formatter.format(calendar.getTime());
                end = formatter.format(new Date());
            }
            else if (rangeType.contains("week")) //$NON-NLS-1$
            {
                Date startDate = new Date();
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(startDate);
                calendar.add(Calendar.DAY_OF_YEAR, -ONE_WEEK);
                start = formatter.format(calendar.getTime());
                end = formatter.format(new Date());
            }
            else
            {
                start = (String) reportContext.getParameterValue("input.start_date"); //$NON-NLS-1$
                end = (String) reportContext.getParameterValue("input.end_date"); //$NON-NLS-1$
                int ndx = start.lastIndexOf(':');
                start = start.substring(0, ndx) + start.substring(ndx + 1);
                ndx = end.lastIndexOf(':');
                end = end.substring(0, ndx) + end.substring(ndx + 1);
            }

            Date endTime = null;
            try
            {
                startTime = formatter.parse(start);
                endTime = formatter.parse(end);
            }
            catch (ParseException pe)
            {
                startTime = formatterOld.parse(start);
                endTime = formatterOld.parse(end);
            }

            startRev = startTime;
            endRev = endTime;

            changeLogs = new ArrayList<ChangeLog>();
            changes = new ArrayList<Change>();

            deviceCursor = -1;
            changeLogCursor = -1;
            configCursor = -1;
        }
        catch (ParseException e)
        {
            e.printStackTrace();
        }
    }

    /** {@inheritDoc} */
    @Override
    public boolean fetch(IDataSetInstance dataSet, IUpdatableDataSetRow row)
    {
        boolean haveRow = false;

        while (nextChange())
        {
            ZDeviceLite currDevice = devices.get(deviceCursor);
            ChangeLog currChangeLog = changeLogs.get(changeLogCursor);
            if (currChangeLog.getTimestamp().before(startTime))
            {
                continue;
            }

            changes = currChangeLog.getChanges();
            if (changes.size() == 0)
            {
                continue;
            }

            Change currConfig = currChangeLog.getChanges().get(configCursor);

            if (!"text/plain".equals(currConfig.getMimeType())) //$NON-NLS-1$
            {
                continue;
            }

            try
            {
                String path = currConfig.getPath();
                row.setColumnValue(DEVICE_COLUMN, currDevice.toString());
                row.setColumnValue(TIMESTAMP_COLUMN, currChangeLog.getTimestamp());
                row.setColumnValue(PATH_COLUMN, path);

                if (currConfig.getType() == 'D')
                {
                    row.setColumnValue(UNIFIED_DIFF_COLUMN, "Configuration file deleted.");
                }
                else if (currConfig.getType() == 'A')
                {
                    row.setColumnValue(UNIFIED_DIFF_COLUMN, "Configuration file added.");
                }
                else
                {
                    String unifiedDiff = configStore.retrieveRevisionUnifiedDiff(currDevice.getIpAddress(), currDevice.getManagedNetwork(), path,
                                                                                 currChangeLog.getTimestamp(), currConfig.getPreviousChange());

                    row.setColumnValue(UNIFIED_DIFF_COLUMN, unifiedDiff);
                }

                haveRow = true;
                break;
            }
            catch (ScriptException e)
            {
                break;
            }
        }

        return haveRow;
    }

    /**
     * @return
     */
    private boolean nextChange()
    {
        if (configCursor + 1 >= changes.size())
        {
            configCursor = -1;
            boolean haveChangeLog = nextChangeLog();
            if (!haveChangeLog)
            {
                return false;
            }
        }

        configCursor++;
        return true;
    }

    /**
     * @return
     */
    private boolean nextChangeLog()
    {
        if (changeLogCursor + 1 >= changeLogs.size())
        {
            changeLogCursor = -1;
            boolean haveNextDevice = nextDevice();
            if (!haveNextDevice)
            {
                return false;
            }
        }

        changeLogCursor++;
        Collections.sort(changeLogs.get(changeLogCursor).getChanges(), new Comparator<Change>() {
            public int compare(Change chg1, Change chg2)
            {
                return chg1.getPath().compareToIgnoreCase(chg2.getPath());
            }
        });
        return true;
    }

    /**
     * @return
     */
    private boolean nextDevice()
    {
        while (deviceCursor + 1 < devices.size())
        {
            ZDeviceLite currDevice = devices.get(++deviceCursor);

            ZDeviceCore deviceCore = ServerDeviceElf.convertLiteToCore(currDevice);
            changeLogs = configStore.retrieveChangeLog(deviceCore, startRev, endRev);
            if (changeLogs.size() > 0)
            {
                Collections.sort(changeLogs, new Comparator<ChangeLog>()
                {
                    public int compare(ChangeLog log1, ChangeLog log2)
                    {
                        return log1.getTimestamp().compareTo(log2.getTimestamp());
                    }
                });
                return true;
            }
        }

        return false;
    }
}
