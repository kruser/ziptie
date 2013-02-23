package org.ziptie.nio.common.tuple;

import org.ziptie.nio.common.tuple.Pair;

import junit.framework.TestCase;

public class PairTest extends TestCase
{
    // -- fields
    private static final String name = "Rover";

    // -- public methods
    public void testToString()
    {
        assertEquals("(" + name + ", 23)", createPair().toString());
    }

    public void testHashCode()
    {
        assertEquals(-1841249166, createPair().hashCode());
        assertEquals(createPair().hashCode(), createPair().hashCode());
    }

    public void testEquals()
    {
        assertEquals(createPair(), createPair());
        ExamplePair pair = createPair();
        assertEquals(pair, pair);
        assertNotSame(pair, new ExamplePair(name, 47));
    }

    // -- private classes
    private static ExamplePair createPair()
    {
        return new ExamplePair(name, 23);
    }

    // -- inner classes
    static class ExamplePair extends Pair<String, Integer>
    {

        protected ExamplePair(final String name, final Integer count)
        {
            super(name, count);
        }

        String name()
        {
            return a;
        }

        int count()
        {
            return b;
        }

    }

}
