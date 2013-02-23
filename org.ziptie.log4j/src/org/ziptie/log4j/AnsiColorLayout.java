package org.ziptie.log4j;

import org.apache.log4j.Level;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.spi.LoggingEvent;

/**
 * AnsiColorLayout
 */
public class AnsiColorLayout extends PatternLayout
{
    public static final boolean WINDOWS;
    public static final String DEFAULT_COLOR_ALL = "\u001B[0;0m";
    public static final String DEFAULT_COLOR_FATAL = "\u001B[0;31m";
    public static final String DEFAULT_COLOR_ERROR = "\u001B[0;31m";
    public static final String DEFAULT_COLOR_WARN = "\u001B[1;33m";
    public static final String DEFAULT_COLOR_INFO = "\u001B[0;37m";
    public static final String DEFAULT_COLOR_DEBUG = "\u001B[0;36m";

    private String allColor;
    private String fatalColor;
    private String errorColor;
    private String warnColor;
    private String infoColor;
    private String debugColor;
    private String defaultColor;

    // Static initializer.
    static
    {
        WINDOWS = System.getProperty("os.name", "windows").contains("indow");
    }

    // Instance initializer.
    {
        allColor = DEFAULT_COLOR_ALL;
        fatalColor = DEFAULT_COLOR_FATAL;
        errorColor = DEFAULT_COLOR_ERROR;
        warnColor = DEFAULT_COLOR_WARN;
        infoColor = DEFAULT_COLOR_INFO;
        debugColor = DEFAULT_COLOR_DEBUG;
        defaultColor = DEFAULT_COLOR_ALL;
    }

    /**
     * Default constructor.
     */
    public AnsiColorLayout()
    {
        super();
    }

    /**
     * Constructor that takes a format string.
     *
     * @param format a log4j format string
     */
    public AnsiColorLayout(String format)
    {
        super(format);
    }

    /** {@inheritDoc} */
    @Override
    public String format(LoggingEvent event)
    {
        if (WINDOWS)
        {
            return super.format(event);
        }

        StringBuilder sb = new StringBuilder(160);
        switch (event.getLevel().toInt())
        {
        case Level.ALL_INT:
            sb.append(allColor);
            break;
        case Level.FATAL_INT:
            sb.append(fatalColor);
            break;
        case Level.ERROR_INT:
            sb.append(errorColor);
            break;
        case Level.WARN_INT:
            sb.append(warnColor);
            break;
        case Level.INFO_INT:
            sb.append(infoColor);
            break;
        case Level.DEBUG_INT:
            sb.append(debugColor);
            break;
        default:
            sb.append(allColor);
        }

        sb.append(super.format(event)).append(defaultColor);
        return sb.toString();
    }

    /**
     * @param allColor the allColor to set
     */
    public void setAllColor(String allColor)
    {
        this.allColor = allColor;
    }

    /**
     * @param debugColor the debugColor to set
     */
    public void setDebugColor(String debugColor)
    {
        this.debugColor = debugColor;
    }

    /**
     * @param defaultColor the defaultColor to set
     */
    public void setDefaultColor(String defaultColor)
    {
        this.defaultColor = defaultColor;
    }

    /**
     * @param errorColor the errorColor to set
     */
    public void setErrorColor(String errorColor)
    {
        this.errorColor = errorColor;
    }

    /**
     * @param fatalColor the fatalColor to set
     */
    public void setFatalColor(String fatalColor)
    {
        this.fatalColor = fatalColor;
    }

    /**
     * @param infoColor the infoColor to set
     */
    public void setInfoColor(String infoColor)
    {
        this.infoColor = infoColor;
    }

    /**
     * @param warnColor the warnColor to set
     */
    public void setWarnColor(String warnColor)
    {
        this.warnColor = warnColor;
    }
}
