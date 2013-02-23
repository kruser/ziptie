package org.ziptie.nio.common;

public class MutableAdapter<T>
{
    public T value;

    // -- constructors
    public MutableAdapter(T value)
    {
        this.value = value;
    }

    // -- public methods
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null)
        {
            return false;
        }
        else if (this == obj)
        {
            return true;
        }
        try
        {
            MutableAdapter other = (MutableAdapter) obj;
            return null == value ? null == other.value : value.equals(other.value);
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    @Override
    public int hashCode()
    {
        return value == null ? 0 : value.hashCode();
    }

    @Override
    public String toString()
    {
        return value.toString();
    }

}
