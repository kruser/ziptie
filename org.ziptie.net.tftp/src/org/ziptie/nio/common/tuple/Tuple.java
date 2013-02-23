package org.ziptie.nio.common.tuple;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.ziptie.nio.common.AkinFields;
import org.ziptie.nio.common.StringFactory;


public abstract class Tuple
{

    // -- fields
    final List<Object> fields = new LinkedList<Object>();

    // -- constructors
    Tuple()
    {
        // do nothing
    }

    // -- public methods
    @Override
    public String toString()
    {
        // {username: testlab, password: hobbit, authMethod: password, cipher: null, clientVersion: default}
        String string = "(";
        string += listBasedPart(fields, new ToStringFactory(), ")");
        return string;
    }

    @Override
    public int hashCode()
    {
        int hashCode = 1;
        for (Object field : fields)
        {
            hashCode = hashCode * 31 + (field == null ? 0 : field.hashCode());
        }
        return hashCode;
    }

    @Override
    public boolean equals(Object them)
    {
        final boolean areEqual;
        if (them == null)
        {
            areEqual = false;
        }
        else if (this == them)
        {
            areEqual = true;
        }
        else
        {
            areEqual = castAndEqualFields(them);
        }
        return areEqual;
    }

    // -- private methods
    private static String listBasedPart(List list, StringFactory factory, String terminator)
    {
        String string = "";
        final String separator = ", ";
        for (Object elem : list)
        {
            string += factory.create(elem) + separator;
        }
        string = string.substring(0, string.length() - separator.length());
        string += terminator;
        return string;
    }

    private static List<AkinFields> zipFields(Iterator myFields, Iterator theirFields)
    {
        List<AkinFields> list = new LinkedList<AkinFields>();
        while (myFields.hasNext() && theirFields.hasNext())
        {
            list.add(new AkinFields(myFields.next(), theirFields.next()));
        }
        return list;
    }

    private boolean equalFields(List theirFields)
    {
        boolean areEqual = true;
        for (AkinFields akinFields : zipFields(fields.iterator(), theirFields.iterator()))
        {
            if (!(null == akinFields.mine() ? null == akinFields.theirs() : akinFields.mine().equals(akinFields.theirs())))
            {
                areEqual = false;
                break;
            }
        }
        return areEqual;
    }

    private boolean castAndEqualFields(Object them)
    {
        try
        {
            return equalFields(((Tuple) them).fields);
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    // -- inner classes
    private static class ToStringFactory implements StringFactory
    {
        public String create(Object obj)
        {
            return null == obj ? "null" : obj.toString();
        }
    }

}
