package org.ziptie.nio.common.tuple;

public abstract class Triple<A, B, C> extends Pair<A, B>
{

    // -- fields
    protected final C c;

    // -- constructors
    protected Triple(final A a, final B b, final C c)
    {
        super(a, b);
        this.c = c;
        fields.add(c);
    }

}
