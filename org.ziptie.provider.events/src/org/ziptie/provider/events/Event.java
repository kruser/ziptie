package org.ziptie.provider.events;

/**
 * Event
 */
public class Event
{
    private String queue;
    private String text;
    private long originTime;
    private String type;

    /**
     * Constructor.
     */
    public Event()
    {
        // empty
    }

    public void setText(String text)
    {
        this.text = text;
    }

    public void setOriginTime(long originTime)
    {
        this.originTime = originTime;
    }

    public void setType(String type)
    {
        this.type = type;
    }

    public void setQueue(String queue)
    {
        this.queue = queue;
    }

    public String getQueue()
    {
        return queue;
    }
    
    public String getText()
    {
        return text;
    }

    public long getOriginTime()
    {
        return originTime;
    }

    public String getType()
    {
        return type;
    }
}
