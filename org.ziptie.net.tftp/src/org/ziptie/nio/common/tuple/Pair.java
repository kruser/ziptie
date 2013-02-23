package org.ziptie.nio.common.tuple;

public abstract class Pair<A, B> extends Single<A>
{

    // -- fields
    protected final B b;

    // -- constructors
    protected Pair(final A a, final B b)
    {
        super(a);
        this.b = b;
        fields.add(b);
    }

}
